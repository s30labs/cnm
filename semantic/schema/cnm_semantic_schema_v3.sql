-- =====================================================================
-- CNM — Semantic layer v3.7
-- =====================================================================
-- All tables use the sem_ prefix (semantic).
--
-- Changes from v3.6:
--   [Q] Relocated confidence/source OFF sem_metric_binding (a factual mirror of
--       CNM) ONTO sem_metric_concept (the concept-mapping judgment) and
--       sem_binding_role (the role-assignment judgment). Bindings carry only
--       instance facts/params (capacity, expected_value).
--
-- Changes from v3.5:
--   [P] + svc.db.query_status concept (SQL query success/error from return code RC;
--       distinct from svc.db.query_latency = response time).
--
-- Changes from v3.4:
--   [N] Renamed domain host.* -> device.* (neutral: servers, routers, switches).
--   [O] + svc.http.availability concept (cooked HTTP up/down state).
--
-- Changes from v3.3:
--   [K] + valid_from / valid_to on sem_business_role (calendar validity window,
--       distinct from status and from the sla operating window).
--   [L] owner now references an org unit (soft reference to sem_org_unit.org_id);
--       escalation chain documented in metadata.escalation.
--   [M] + sem_org_unit: the organizational hierarchy (third hierarchy, separate
--       from composition and dependency). Optional.
--
-- The three hierarchies around a business_role:
--   composition  (parent_role_id)        -> "is part of"   (process tree)
--   dependency   (sem_role_dependency)   -> "depends on"   (technical graph)
--   organization (owner -> sem_org_unit) -> "responsible / affected" (org tree)
--
-- Changes from v3.2:
--   [I] Removed bound_at / bound_by from sem_metric_binding.
--   [J] All descriptions and comments in English; identifiers never translated.
--
-- Instance-level validation (detectable debt):
--   - needs_instance_capacity=1 AND capacity IS NULL       -> saturation not evaluable
--   - direction='out_of_band'   AND expected_value IS NULL -> state not comparable
--
-- Propagation is OPT-IN: signal_class='diagnostic' by default => no propagation.
-- Multilanguage is a presentation concern, intentionally NOT modeled here.
-- If ever required, use a separate sem_concept_i18n(canonical_id, locale, text)
-- table for the product-controlled concept labels only.
--
-- Adjust ENGINE/CHARSET to the actual installation if needed.
-- =====================================================================


-- =====================================================================
-- Level 1: abstract canonical concept
-- =====================================================================
CREATE TABLE sem_canonical_concept (
  canonical_id    VARCHAR(64) PRIMARY KEY,        -- grammar: domain.subdomain.name
  display_name    VARCHAR(255) NOT NULL,
  category        ENUM('availability','performance','capacity',
                       'security','business_process') NOT NULL,

  -- Role in upward propagation:
  --   health_sli : defines whether the service does its job. Propagates IMPACT.
  --   saturation : leading indicator (resource near its limit). Propagates RISK.
  --   diagnostic : pure context. Does NOT propagate. (conservative default)
  --   informative: recorded/labeled for completeness (e.g. inventory/config).
  --                Never alerts, never propagates, excluded from health rollups.
  signal_class    ENUM('health_sli','saturation','diagnostic','informative')
                       NOT NULL DEFAULT 'diagnostic',

  unit            VARCHAR(32),
  direction       ENUM('higher_is_worse','lower_is_worse',
                       'out_of_band') NOT NULL,

  -- Physical bound of the concept (mis-mapping detection). NULL = no canonical bound.
  plausible_min   DOUBLE NULL,
  plausible_max   DOUBLE NULL,

  -- Saturation is not evaluable without the instance capacity (traffic, disk bytes).
  needs_instance_capacity BOOLEAN NOT NULL DEFAULT 0,

  is_business     BOOLEAN NOT NULL DEFAULT 0,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- =====================================================================
-- Level 2: CNM subtype -> canonical concept mapping
-- =====================================================================
CREATE TABLE sem_metric_concept (
  subtype         VARCHAR(64) PRIMARY KEY,        -- = CNM subtype
  canonical_id    VARCHAR(64) NOT NULL,
  -- origin drives the kind of debt and the responsible party:
  --   standard : catalog metric (maintained by product). Unmapped = bug.
  --   custom   : ad-hoc metric for a specific customer problem, under a
  --              specific parameterization (created by integrator/developer).
  --              Unmapped = pending integrator work (normal).
  origin          ENUM('standard','custom') NOT NULL,
  -- AI safety gate: the concept mapping is a JUDGMENT (esp. for custom subtypes).
  -- ai_suggested mappings must NOT reach production until a human confirms them.
  -- Manual onboarding defaults to human_confirmed; AI pipelines MUST set ai_suggested.
  -- 'inherited' = adopted from a cluster representative / sibling subtype.
  confidence      ENUM('human_confirmed','ai_suggested','inherited')
                       NOT NULL DEFAULT 'human_confirmed',
  -- Provenance (for ML-ops: compare clustering vs llm_batch performance).
  source          ENUM('manual','onboarding','clustering','llm_batch','rules')
                       NOT NULL DEFAULT 'manual',
  -- Per-subtype multiplier from the raw/graphed value to the concept's
  -- canonical unit. The RRD/graph is NOT modified; the semantic layer
  -- converts on read. Examples: flow.job.exec_time canonical=minutes ->
  -- seconds source uses 0.016667, hours uses 60; device.uptime.days from
  -- SNMP timeticks (1/100 s) uses ~1/8640000. Default 1.0 (already canonical).
  value_scale     DOUBLE NOT NULL DEFAULT 1.0,
  FOREIGN KEY (canonical_id) REFERENCES sem_canonical_concept(canonical_id)
) ENGINE=InnoDB;


-- =====================================================================
-- Level 3: instance IDENTITY (stable) vs INCARNATION (volatile)
--
-- Key problem this solves: in CNM the idmetric and the SNMP iid (ifIndex,
-- storage index) are VOLATILE. A reconfiguration can renumber them, so the
-- same logical thing ("disk C of serv1", "eth2 of rtr1") may surface under a
-- new idmetric. We therefore separate:
--   sem_instance        -> the STABLE identity + its enrichment (capacity,
--                          expected_value, and later the role). Anchored on a
--                          stable label (ifAlias/ifDescr/volume), NOT the iid.
--   sem_metric_binding  -> the current INCARNATION: which idmetric/iid is that
--                          identity right now, with a valid_from/valid_to life.
-- The reconciliation job (see cnm_fase3_reconciliacion.sql) keeps these in sync
-- across churn WITHOUT losing the enrichment.
-- =====================================================================
CREATE TABLE sem_instance (
  instance_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  iddev           BIGINT      NOT NULL,
  subtype         VARCHAR(64) NOT NULL,
  -- Stable identity within (device, subtype): the RESOLVED label
  -- (ifAlias/ifDescr/ifName for interfaces; volume label/mount for disks).
  -- NEVER the numeric iid. For single-instance metrics use 'ALL'.
  stable_key      VARCHAR(240) NOT NULL DEFAULT 'ALL',

  -- Instance-level concept override for HETEROGENEOUS subtypes (one CNM subtype
  -- carrying more than one concept, e.g. disk_mibhost = disk volumes + memory
  -- rows). Effective concept = COALESCE(canonical_override, subtype's concept).
  -- NULL for the vast majority; set only for the exceptions.
  canonical_override VARCHAR(64) NULL,

  -- Enrichment lives on the IDENTITY, so it survives idmetric/iid churn:
  capacity        DOUBLE       NULL,        -- needs_instance_capacity concepts
  capacity_source VARCHAR(32)  NULL,        -- how capacity was obtained (e.g. ifHighSpeed)
  capacity_polled_at TIMESTAMP NULL DEFAULT NULL, -- when capacity was last polled
  -- Human-readable description of the instance. Two sources, never mixed up:
  --   'ifAlias' = captured by the poller (interface alias); may be refreshed.
  --   'user'    = provided by a person; the poller NEVER overwrites it.
  --   'none'    = poller looked, this concept has no text source.
  instance_info        VARCHAR(255) CHARACTER SET latin1 NULL,
  instance_info_source VARCHAR(16)  NULL,
  expected_value  VARCHAR(64)  NULL,        -- out_of_band concepts

  valid_from      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  valid_to        TIMESTAMP    NULL,        -- set when no live incarnation; kept, not deleted

  -- stable_key prefix-indexed (125) to respect MariaDB 10.0's 767-byte limit
  -- (iddev 8 + subtype 64*4 + stable_key 125*4 = 764 < 767).
  UNIQUE KEY uq_identity (iddev, subtype, stable_key(125)),
  KEY ix_subtype (subtype),
  FOREIGN KEY (subtype) REFERENCES sem_metric_concept(subtype)
) ENGINE=InnoDB;

CREATE TABLE sem_metric_binding (
  idmetric        BIGINT      PRIMARY KEY,         -- = CNM idmetric (the incarnation)
  instance_id     BIGINT      NOT NULL,            -- -> stable identity
  iid             VARCHAR(240) NOT NULL DEFAULT 'ALL',  -- current numeric iid/ifIndex
  valid_from      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  valid_to        TIMESTAMP    NULL,
  status          ENUM('active','stale') NOT NULL DEFAULT 'active',
  -- This table is a FACTUAL MIRROR of CNM (which idmetric exists right now). It
  -- carries no enrichment and no mapping judgment: the concept mapping lives in
  -- sem_metric_concept; the enrichment/role on sem_instance.
  KEY ix_instance (instance_id),
  KEY ix_status   (status),
  FOREIGN KEY (instance_id) REFERENCES sem_instance(instance_id)
) ENGINE=InnoDB;


-- =====================================================================
-- Business role: typed functional node
-- =====================================================================
CREATE TABLE sem_business_role (
  role_id            VARCHAR(64)  PRIMARY KEY,
  role_type          ENUM('business_process','business_subprocess',
                          'application','technical_service','site') NOT NULL,
  display_name       VARCHAR(255) NOT NULL,
  domain             VARCHAR(64)  NOT NULL,
  parent_role_id     VARCHAR(64)  NULL,            -- COMPOSITION ("is part of")
  environment        ENUM('prod','pre','dev') NULL,
  geography          VARCHAR(16) NULL,
  criticality        TINYINT      NOT NULL DEFAULT 3,
  -- owner = responsible org unit. By convention matches sem_org_unit.org_id
  -- when the org tree is used (soft reference; no hard FK to avoid forcing
  -- org population). The escalation chain (operator/responsible/director, as in
  -- the source spreadsheet) lives in metadata.escalation for now, e.g.:
  --   {"escalation": {"operator":"...","responsible":"...","director":"..."}}
  -- Promote to a dedicated table only when the alert engine routes by it.
  owner              VARCHAR(64),
  status             ENUM('draft','active','deprecated','archived')
                          NOT NULL DEFAULT 'draft',   -- LIFECYCLE state (not dates)
  -- Validity WINDOW = calendar lifespan during which this role is meaningful
  -- (e.g. a process retired on a date, a seasonal process). Distinct from:
  --   - status        (a state, not dates)
  --   - sla operating window (recurring schedule when the SLA applies, e.g.
  --     09:00-22:00 Mon-Fri) which lives inside the sla JSON, NOT here.
  valid_from         DATE NULL,
  valid_to           DATE NULL,
  -- JSON stored as LONGTEXT for portability down to MariaDB 10.0 (Debian 8),
  -- which lacks the native JSON type (MySQL 5.7+ / MariaDB 10.2+). On newer
  -- engines JSON is itself an alias of LONGTEXT, so this loads everywhere.
  -- Validation/parsing is done application-side.
  sla                LONGTEXT NULL,
  metadata           LONGTEXT NULL,
  created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(128),
  deprecated_at      TIMESTAMP NULL,
  deprecated_by      VARCHAR(128) NULL,
  deprecated_reason  VARCHAR(255) NULL,
  purge_after        TIMESTAMP NULL,
  archived_at        TIMESTAMP NULL,
  archived_by        VARCHAR(128) NULL,
  KEY ix_type        (role_type),
  KEY ix_status      (status),
  KEY ix_domain      (domain),
  KEY ix_geo_env     (geography, environment),
  FOREIGN KEY (parent_role_id) REFERENCES sem_business_role(role_id)
) ENGINE=InnoDB;


-- =====================================================================
-- Organizational hierarchy (OPTIONAL): the THIRD hierarchy.
-- Separate from composition (parent_role_id) and dependency (sem_role_dependency).
-- Answers "who is responsible / who is affected up the org chain".
-- Populate only if you need impact roll-up to org units; business_role.owner
-- references org_id by convention. Do NOT model org units as business_role
-- parents (that would mix the process tree with the org tree).
-- =====================================================================
CREATE TABLE sem_org_unit (
  org_id         VARCHAR(64) PRIMARY KEY,         -- e.g. 'finance.invoicing_team'
  display_name   VARCHAR(255) NOT NULL,
  parent_org_id  VARCHAR(64) NULL,                -- org "reports to" chain
  kind           ENUM('team','department','division','company') NOT NULL DEFAULT 'team',
  geography      VARCHAR(16) NULL,
  contact        VARCHAR(255) NULL,
  KEY ix_parent  (parent_org_id),
  FOREIGN KEY (parent_org_id) REFERENCES sem_org_unit(org_id)
) ENGINE=InnoDB;


-- =====================================================================
-- Instance <-> role association (N:M)
-- Attached to the STABLE identity (sem_instance), NOT to idmetric, so role
-- assignments survive idmetric/iid churn (a reconfiguration no longer drops
-- the role the way a CASCADE on idmetric would).
-- =====================================================================
CREATE TABLE sem_binding_role (
  instance_id     BIGINT       NOT NULL,
  role_id         VARCHAR(64)  NOT NULL,
  relation_type   ENUM('direct','shared_dependency','derived')
                       NOT NULL DEFAULT 'direct',
                       -- 'shared_dependency' DISCOURAGED: use sem_role_dependency.
  is_primary      BOOLEAN      NOT NULL DEFAULT 0,
  weight          DECIMAL(3,2) NOT NULL DEFAULT 1.00,
  signal_class_override ENUM('health_sli','saturation','diagnostic') NULL,
  -- The role assignment is also a JUDGMENT (which business role an instance serves),
  -- so it carries its own confidence/source, independent of the concept mapping.
  confidence      ENUM('human_confirmed','ai_suggested','inherited')
                       NOT NULL DEFAULT 'human_confirmed',
  source          ENUM('manual','onboarding','clustering','llm_batch','rules')
                       NOT NULL DEFAULT 'manual',
  PRIMARY KEY (instance_id, role_id),
  KEY ix_role     (role_id, relation_type),
  FOREIGN KEY (instance_id) REFERENCES sem_instance(instance_id) ON DELETE CASCADE,
  FOREIGN KEY (role_id)     REFERENCES sem_business_role(role_id)
) ENGINE=InnoDB;


-- =====================================================================
-- Role -> role dependency graph ("source DEPENDS ON target")
-- =====================================================================
CREATE TABLE sem_role_dependency (
  source_role_id    VARCHAR(64) NOT NULL,
  target_role_id    VARCHAR(64) NOT NULL,
  dependency_type   ENUM('hard','soft') NOT NULL DEFAULT 'soft',
  propagates_impact BOOLEAN NOT NULL DEFAULT 1,    -- degraded health -> IMPACT
  propagates_risk   BOOLEAN NOT NULL DEFAULT 1,    -- saturation -> RISK
  note              VARCHAR(255) NULL,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by        VARCHAR(128),
  PRIMARY KEY (source_role_id, target_role_id),
  KEY ix_target     (target_role_id),
  FOREIGN KEY (source_role_id) REFERENCES sem_business_role(role_id),
  FOREIGN KEY (target_role_id) REFERENCES sem_business_role(role_id)
) ENGINE=InnoDB;


-- =====================================================================
-- Derived health state per service (technical_service / application)
-- =====================================================================
CREATE TABLE sem_service_health (
  role_id           VARCHAR(64) PRIMARY KEY,
  health_state      ENUM('healthy','degraded','down','unknown')   -- from health_sli
                          NOT NULL DEFAULT 'unknown',
  saturation_state  ENUM('ok','warning','critical','unknown')     -- from saturation
                          NOT NULL DEFAULT 'unknown',
  computed_at       TIMESTAMP NULL,
  evaluator_version VARCHAR(32),
  FOREIGN KEY (role_id) REFERENCES sem_business_role(role_id)
) ENGINE=InnoDB;


-- =====================================================================
-- SLA evaluation: shadow mode from day one
-- =====================================================================
CREATE TABLE sem_sla_evaluation (
  evaluation_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  role_id           VARCHAR(64) NOT NULL,
  sla_rule_key      VARCHAR(64) NOT NULL,
  evaluated_at      TIMESTAMP NOT NULL,
  period_start      TIMESTAMP NOT NULL,
  period_end        TIMESTAMP NOT NULL,
  result            ENUM('met','violated','no_data','indeterminate') NOT NULL,
  observed_value    VARCHAR(255),
  threshold_value   VARCHAR(255),
  mode              ENUM('shadow','active') NOT NULL DEFAULT 'shadow',
  evaluator_version VARCHAR(32),
  KEY ix_role_time  (role_id, evaluated_at),
  KEY ix_result     (result, mode, evaluated_at),
  FOREIGN KEY (role_id) REFERENCES sem_business_role(role_id)
) ENGINE=InnoDB;


-- =====================================================================
-- CATALOG (sem_canonical_concept) is maintained in a separate file:
--   cnm_semantic_catalog.sql   (49 concepts, consolidated from human review)
-- Grammar: domain.subdomain.name  (the unit goes in the name when the same
-- measure exists in several units: disk.pct vs disk.bytes).
--
-- LOAD ORDER:
--   1) this file  (DDL)
--   2) cnm_semantic_catalog.sql          (sem_canonical_concept)
--   3) cnm_metric_concept_mappings.sql   (sem_metric_concept, human_confirmed)
--   4) per-deployment roles/bindings     (illustrative example below)
-- =====================================================================


-- =====================================================================
-- ILLUSTRATIVE EXAMPLE: AD (technical_service) and a dependent process.
-- Shows capacity (traffic) and expected_value (out_of_band port).
-- subtype/idmetric are illustrative; use the real CNM ones.
-- =====================================================================
INSERT INTO sem_metric_concept (subtype, canonical_id, origin, confidence, source) VALUES
('ldap_auth',         'svc.auth.latency',      'standard', 'human_confirmed','onboarding'),
('cpu_host',          'device.cpu.pct',        'standard', 'human_confirmed','onboarding'),
('port_tcp389',       'svc.service.status',    'standard', 'human_confirmed','onboarding'),
('iface_traffic_in',  'net.iface.traffic_bps', 'standard', 'human_confirmed','onboarding');

-- The stable identity (enrichment lives here) ...
INSERT INTO sem_instance
  (instance_id, iddev, subtype, stable_key, capacity, expected_value) VALUES
(900001, 501, 'ldap_auth',        'ALL',  NULL,       NULL),
(900002, 501, 'port_tcp389',      'ALL',  NULL,       '1'),         -- out_of_band: expected port up
(900003, 501, 'cpu_host',         'ALL',  NULL,       NULL),
(900010, 501, 'iface_traffic_in', 'GE0/1',1000000000, NULL);       -- 1 Gbps; stable_key = ifAlias/ifName

-- ... and its CURRENT incarnation (the volatile idmetric/iid mirrored from CNM)
INSERT INTO sem_metric_binding (idmetric, instance_id, iid, status) VALUES
(700001, 900001, 'ALL', 'active'),
(700002, 900002, '389', 'active'),
(700003, 900003, 'ALL', 'active'),
(700010, 900010, '2',   'active');   -- iid=2 (ifIndex) today; may renumber tomorrow

-- Organizational hierarchy (the third hierarchy)
INSERT INTO sem_org_unit (org_id, display_name, parent_org_id, kind, geography, contact) VALUES
('it', 'IT', NULL, 'division', 'global', NULL),
('it.infra_team', 'Infrastructure team', 'it', 'team', 'global', 'infra@corp'),
('finance', 'Finance', NULL, 'division', 'global', NULL),
('finance.invoicing_es', 'Invoicing team Spain', 'finance', 'team', 'ES', 'fact.es@corp');

-- owner -> org_id ; valid_from/valid_to = calendar validity ; escalation in metadata
INSERT INTO sem_business_role
  (role_id, role_type, display_name, domain, parent_role_id,
   environment, geography, criticality, owner, status, valid_from, valid_to,
   metadata, created_by) VALUES
('infra.identity.ad', 'technical_service', 'Corporate Active Directory',
   'infra', NULL, 'prod', 'global', 5, 'it.infra_team', 'active', '2022-01-01', NULL,
   NULL, 'integrator'),
('sales.invoicing.es', 'business_subprocess', 'Sales invoicing (Spain)',
   'sales', NULL, 'prod', 'ES', 5, 'finance.invoicing_es', 'active', '2023-03-01', NULL,
   '{"escalation": {"operator":"fact.es@corp","responsible":"finance.lead@corp","director":"cfo@corp"}}',
   'integrator');

INSERT INTO sem_binding_role (instance_id, role_id, relation_type, is_primary, weight) VALUES
(900001, 'infra.identity.ad', 'direct', 1, 1.00),
(900002, 'infra.identity.ad', 'direct', 1, 1.00),
(900003, 'infra.identity.ad', 'direct', 0, 0.00),
(900010, 'infra.identity.ad', 'direct', 0, 0.00);

-- sales.invoicing.es depends on AD (hard). Geography ES is an attribute, not part
-- of the concept: the invoice-count metric maps to biz.doc.throughput_count.
INSERT INTO sem_role_dependency
  (source_role_id, target_role_id, dependency_type,
   propagates_impact, propagates_risk, note, created_by) VALUES
('sales.invoicing.es', 'infra.identity.ad', 'hard', 1, 1,
 'Invoicing authenticates against SAP, which validates against AD', 'integrator');
