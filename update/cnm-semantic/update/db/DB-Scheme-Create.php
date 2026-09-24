<?php
//--------------------------------------------------------------------------------
// Esquema de la capa semantica de CNM (tablas sem_*)
//
// Se instala como plugin:   /update/db/db-manage.php -p /opt/cnm-sp/cnm-semantic
//
// Convenciones seguidas (ver REF-CNM-01 §9.4 y REV-CNM-02):
//   · Toda columna de texto lleva "character set utf8 collate utf8_spanish_ci"
//     EXPLICITO. db-manage no declara charset de tabla, asi que la tabla hereda
//     el de la base (latin1) y sin esto las columnas saldrian latin1.
//   · Toda columna TIMESTAMP declara su nulabilidad EXPLICITAMENTE. El valor por
//     defecto de explicit_defaults_for_timestamp no es el mismo en MySQL 5.5 que
//     en MariaDB 11.x, y sin declararla el esquema no converge.
//   · El orden del array es el orden de creacion: una tabla con FOREIGN KEY va
//     despues de aquella a la que apunta.
//--------------------------------------------------------------------------------

$DBScheme = array(
	'sem_canonical_concept'=>array(
		'canonical_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'display_name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL",
		'category'=>"enum('availability','performance','capacity','security','business_process') character set utf8 collate utf8_spanish_ci NOT NULL",
		'signal_class'=>"enum('health_sli','saturation','diagnostic','informative') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'diagnostic'",
		'unit'=>"varchar(32) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'direction'=>"enum('higher_is_worse','lower_is_worse','out_of_band') character set utf8 collate utf8_spanish_ci NOT NULL",
		'plausible_min'=>"double DEFAULT NULL",
		'plausible_max'=>"double DEFAULT NULL",
		'needs_instance_capacity'=>"tinyint(1) NOT NULL DEFAULT '0'",
		'is_business'=>"tinyint(1) NOT NULL DEFAULT '0'",
		'created_at'=>"timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP",
		'scope'=>"enum('device','flow','entity') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'device'",
		'PRIMARY KEY  (`canonical_id`)'=>'',
	),

	'sem_metric_concept'=>array(
		'subtype'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'canonical_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'origin'=>"enum('standard','custom') character set utf8 collate utf8_spanish_ci NOT NULL",
		'confidence'=>"enum('human_confirmed','ai_suggested','inherited') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'human_confirmed'",
		'source'=>"enum('manual','onboarding','clustering','llm_batch','rules') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'manual'",
		'value_scale'=>"double NOT NULL DEFAULT '1'",
		'ds_valor'=>"varchar(16) character set utf8 collate utf8_spanish_ci DEFAULT '1'",
		'ds_total'=>"tinyint(4) DEFAULT NULL",
		'PRIMARY KEY  (`subtype`)'=>'',
		'KEY `canonical_id` (`canonical_id`)'=>'',
		'CONSTRAINT `sem_metric_concept_ibfk_1` FOREIGN KEY (`canonical_id`) REFERENCES `sem_canonical_concept` (`canonical_id`)'=>'',
	),

	'sem_instance'=>array(
		'instance_id'=>"bigint(20) NOT NULL AUTO_INCREMENT",
		'iddev'=>"bigint(20) NOT NULL",
		'subtype'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'canonical_override'=>"varchar(64) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'stable_key'=>"varchar(240) character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'ALL'",
		'capacity'=>"double DEFAULT NULL",
		'capacity_source'=>"varchar(32) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'capacity_polled_at'=>"timestamp NULL DEFAULT NULL",
		'instance_info'=>"varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'instance_info_source'=>"varchar(16) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'expected_value'=>"varchar(64) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'valid_from'=>"timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP",
		'valid_to'=>"timestamp NULL DEFAULT NULL",
		'instance_kind'=>"varchar(16) character set utf8 collate utf8_spanish_ci DEFAULT NULL COMMENT 'Que ES la instancia: ethernet, loopback, virtual, tunnel... De ifType. REV-SEM-08'",
		'PRIMARY KEY  (`instance_id`)'=>'',
		'UNIQUE KEY `uq_identity` (`iddev`,`subtype`,`stable_key`(125))'=>'',
		'KEY `ix_subtype` (`subtype`)'=>'',
		'CONSTRAINT `sem_instance_ibfk_1` FOREIGN KEY (`subtype`) REFERENCES `sem_metric_concept` (`subtype`)'=>'',
	),

	'sem_metric_binding'=>array(
		'idmetric'=>"bigint(20) NOT NULL",
		'instance_id'=>"bigint(20) NOT NULL",
		'iid'=>"varchar(240) character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'ALL'",
		'valid_from'=>"timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP",
		'valid_to'=>"timestamp NULL DEFAULT NULL",
		'status'=>"enum('active','stale') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'active'",
		'PRIMARY KEY  (`idmetric`)'=>'',
		'KEY `ix_instance` (`instance_id`)'=>'',
		'KEY `ix_status` (`status`)'=>'',
		'CONSTRAINT `sem_metric_binding_ibfk_1` FOREIGN KEY (`instance_id`) REFERENCES `sem_instance` (`instance_id`)'=>'',
	),

	'sem_business_role'=>array(
		'role_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'role_type'=>"enum('business_process','business_subprocess','application','technical_service','site') character set utf8 collate utf8_spanish_ci NOT NULL",
		'display_name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL",
		'domain'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'parent_role_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'environment'=>"enum('prod','pre','dev') character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'geography'=>"varchar(16) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'criticality'=>"tinyint(4) NOT NULL DEFAULT '3'",
		'owner'=>"varchar(64) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'status'=>"enum('draft','active','deprecated','archived') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'draft'",
		'valid_from'=>"date DEFAULT NULL",
		'valid_to'=>"date DEFAULT NULL",
		'sla'=>"longtext character set utf8 collate utf8_spanish_ci",
		'metadata'=>"longtext character set utf8 collate utf8_spanish_ci",
		'created_at'=>"timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP",
		'created_by'=>"varchar(128) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'deprecated_at'=>"timestamp NULL DEFAULT NULL",
		'deprecated_by'=>"varchar(128) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'deprecated_reason'=>"varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'purge_after'=>"timestamp NULL DEFAULT NULL",
		'archived_at'=>"timestamp NULL DEFAULT NULL",
		'archived_by'=>"varchar(128) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'health_threshold'=>"decimal(4,3) NOT NULL DEFAULT '0.500'",
		'health_threshold_note'=>"varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'PRIMARY KEY  (`role_id`)'=>'',
		'KEY `ix_type` (`role_type`)'=>'',
		'KEY `ix_status` (`status`)'=>'',
		'KEY `ix_domain` (`domain`)'=>'',
		'KEY `ix_geo_env` (`geography`,`environment`)'=>'',
		'KEY `parent_role_id` (`parent_role_id`)'=>'',
		'CONSTRAINT `sem_business_role_ibfk_1` FOREIGN KEY (`parent_role_id`) REFERENCES `sem_business_role` (`role_id`)'=>'',
	),

	'sem_org_unit'=>array(
		'org_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'display_name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL",
		'parent_org_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'kind'=>"enum('team','department','division','company') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'team'",
		'geography'=>"varchar(16) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'contact'=>"varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'PRIMARY KEY  (`org_id`)'=>'',
		'KEY `ix_parent` (`parent_org_id`)'=>'',
		'CONSTRAINT `sem_org_unit_ibfk_1` FOREIGN KEY (`parent_org_id`) REFERENCES `sem_org_unit` (`org_id`)'=>'',
	),

	'sem_binding_role'=>array(
		'instance_id'=>"bigint(20) NOT NULL",
		'role_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'relation_type'=>"enum('direct','shared_dependency','derived') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'direct'",
		'is_primary'=>"tinyint(1) NOT NULL DEFAULT '0'",
		'weight'=>"decimal(3,2) NOT NULL DEFAULT '1.00'",
		'signal_class_override'=>"enum('health_sli','saturation','diagnostic') character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'confidence'=>"enum('human_confirmed','ai_suggested','inherited') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'human_confirmed'",
		'source'=>"enum('manual','onboarding','clustering','llm_batch','rules') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'manual'",
		'status'=>"enum('active','retired') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'active'",
		'retired_at'=>"datetime DEFAULT NULL",
		'PRIMARY KEY  (`instance_id`,`role_id`)'=>'',
		'KEY `ix_role` (`role_id`,`relation_type`)'=>'',
		'KEY `ix_retired` (`status`,`retired_at`)'=>'',
		'CONSTRAINT `sem_binding_role_ibfk_1` FOREIGN KEY (`instance_id`) REFERENCES `sem_instance` (`instance_id`) ON DELETE CASCADE'=>'',
		'CONSTRAINT `sem_binding_role_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `sem_business_role` (`role_id`)'=>'',
	),

	'sem_role_dependency'=>array(
		'source_role_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'target_role_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'dependency_type'=>"enum('hard','soft') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'soft'",
		'propagates_impact'=>"tinyint(1) NOT NULL DEFAULT '1'",
		'propagates_risk'=>"tinyint(1) NOT NULL DEFAULT '1'",
		'note'=>"varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'created_at'=>"timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP",
		'created_by'=>"varchar(128) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'PRIMARY KEY  (`source_role_id`,`target_role_id`)'=>'',
		'KEY `ix_target` (`target_role_id`)'=>'',
		'CONSTRAINT `sem_role_dependency_ibfk_1` FOREIGN KEY (`source_role_id`) REFERENCES `sem_business_role` (`role_id`)'=>'',
		'CONSTRAINT `sem_role_dependency_ibfk_2` FOREIGN KEY (`target_role_id`) REFERENCES `sem_business_role` (`role_id`)'=>'',
	),

	'sem_service_health'=>array(
		'role_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'health_state'=>"enum('healthy','degraded','down','unknown') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'unknown'",
		'saturation_state'=>"enum('ok','warning','critical','unknown') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'unknown'",
		'computed_at'=>"timestamp NULL DEFAULT NULL",
		'evaluator_version'=>"varchar(32) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'PRIMARY KEY  (`role_id`)'=>'',
		'CONSTRAINT `sem_service_health_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `sem_business_role` (`role_id`)'=>'',
	),

	'sem_sla_evaluation'=>array(
		'evaluation_id'=>"bigint(20) NOT NULL AUTO_INCREMENT",
		'role_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'sla_rule_key'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'evaluated_at'=>"timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP",
		'period_start'=>"timestamp NOT NULL DEFAULT '0000-00-00 00:00:00'",
		'period_end'=>"timestamp NOT NULL DEFAULT '0000-00-00 00:00:00'",
		'result'=>"enum('met','violated','no_data','indeterminate') character set utf8 collate utf8_spanish_ci NOT NULL",
		'observed_value'=>"varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'threshold_value'=>"varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'mode'=>"enum('shadow','active') character set utf8 collate utf8_spanish_ci NOT NULL DEFAULT 'shadow'",
		'evaluator_version'=>"varchar(32) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'PRIMARY KEY  (`evaluation_id`)'=>'',
		'KEY `ix_role_time` (`role_id`,`evaluated_at`)'=>'',
		'KEY `ix_result` (`result`,`mode`,`evaluated_at`)'=>'',
		'CONSTRAINT `sem_sla_evaluation_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `sem_business_role` (`role_id`)'=>'',
	),

	'sem_load_audit'=>array(
		'batch_id'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL",
		'ts'=>"timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP",
		'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'operator'=>"varchar(128) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'note'=>"varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'n_insert'=>"int(11) DEFAULT NULL",
		'n_update'=>"int(11) DEFAULT NULL",
		'n_parent'=>"int(11) DEFAULT NULL",
		'n_skipped'=>"int(11) DEFAULT NULL",
		'PRIMARY KEY  (`batch_id`)'=>'',
	),

	'sem_role_change_log'=>array(
		'id'=>"bigint(20) NOT NULL AUTO_INCREMENT",
		'batch_id'=>"varchar(32) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'ts'=>"timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP",
		'role_id'=>"varchar(64) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'action'=>"varchar(8) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'field'=>"varchar(32) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
		'old_val'=>"mediumtext character set utf8 collate utf8_spanish_ci",
		'new_val'=>"mediumtext character set utf8 collate utf8_spanish_ci",
		'PRIMARY KEY  (`id`)'=>'',
		'KEY `ix_batch` (`batch_id`)'=>'',
	),

);

?>
