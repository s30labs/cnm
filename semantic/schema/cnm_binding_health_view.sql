-- ============================================================================
-- Vista de salud del binding: clasifica cada instancia métrica VIVA por su
-- nivel de fiabilidad de rol. Responde a "¿qué métricas no tienen binding o su
-- binding no es fiable?". Solo lectura; no modifica nada.
--
--   nivel de binding:
--     confirmado   binding human_confirmed (máxima confianza)
--     por_codigo   rol por código KPI propio (relation_type='direct') — fiable
--     heredado     rol heredado del col7 del dispositivo ('derived') — débil
--     SIN_ROL      no tiene binding a ningún rol
--   señales de sospecha (flags):
--     importante_sin_rol   watch/latency PERO sin rol  -> lo más grave
--     identidad_debil      instance_info_source = iid_weak (Fortigate/Cisco HW)
--     col7_unassigned      el dispositivo tiene col7 sin clasificar
-- ============================================================================
CREATE OR REPLACE VIEW v_binding_health AS
SELECT
  i.instance_id,
  i.iddev,
  d.name              AS dispositivo,
  i.subtype,
  i.stable_key,
  i.instance_info_source,
  br.role_id,
  br.relation_type,
  br.confidence,
  -- nivel de fiabilidad del binding
  CASE
    WHEN br.role_id IS NULL                       THEN 'SIN_ROL'
    WHEN br.confidence = 'human_confirmed'        THEN 'confirmado'
    WHEN br.relation_type = 'direct'              THEN 'por_codigo'
    WHEN br.relation_type = 'derived'             THEN 'heredado'
    ELSE 'otro'
  END AS nivel_binding,
  -- ¿es una métrica importante? (watch<>0 OR disp/latency OR tiene código)
  CASE WHEN EXISTS (
     SELECT 1 FROM sem_metric_binding b JOIN metrics m ON m.id_metric=b.idmetric
     WHERE b.instance_id=i.instance_id AND b.status='active'
       AND ( (m.watch IS NOT NULL AND m.watch<>'0' AND m.watch<>'')
          OR m.subtype COLLATE utf8_spanish_ci REGEXP '^(disp_icmp|mon_|w_mon_)'
          OR COALESCE(m.c_label,'') COLLATE utf8_spanish_ci REGEXP '[PWTIBD][0-9]+-SP[0-9]+-KPI[0-9]+'
          OR COALESCE(m.label,'')   COLLATE utf8_spanish_ci REGEXP '[PWTIBD][0-9]+-SP[0-9]+-KPI[0-9]+') )
     THEN 1 ELSE 0 END AS importante,
  -- flags de sospecha
  CASE WHEN i.instance_info_source='iid_weak' THEN 1 ELSE 0 END AS identidad_debil,
  CASE WHEN c.columna7='unassigned'          THEN 1 ELSE 0 END AS col7_unassigned
FROM sem_instance i
JOIN devices d               ON d.id_dev=i.iddev
LEFT JOIN devices_custom_data c ON c.id_dev=i.iddev
LEFT JOIN sem_binding_role br ON br.instance_id=i.instance_id
WHERE i.valid_to IS NULL;

-- ---- consultas de uso frecuente sobre la vista -----------------------------

-- 1) RESUMEN: cuántas instancias en cada nivel de fiabilidad
--    SELECT nivel_binding, COUNT(*) n FROM v_binding_health GROUP BY nivel_binding;

-- 2) LO MÁS GRAVE: importantes SIN rol (importan y no están atadas)
--    SELECT dispositivo, subtype, stable_key FROM v_binding_health
--    WHERE importante=1 AND nivel_binding='SIN_ROL' ORDER BY dispositivo;

-- 3) BINDINGS DÉBILES: heredados de col7 (no por código propio)
--    SELECT dispositivo, subtype, role_id FROM v_binding_health
--    WHERE nivel_binding='heredado' ORDER BY dispositivo;

-- 4) por dispositivo: cuántas métricas sin rol tiene cada uno (para priorizar)
--    SELECT dispositivo, SUM(nivel_binding='SIN_ROL') sin_rol, COUNT(*) total
--    FROM v_binding_health GROUP BY dispositivo HAVING sin_rol>0 ORDER BY sin_rol DESC;
