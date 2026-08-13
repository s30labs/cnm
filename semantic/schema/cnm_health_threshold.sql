-- =============================================================================
-- REV-SEM-03 accion 4 · health_threshold en sem_business_role
--
-- SE EJECUTA EN CNM (MariaDB/MySQL 5.5, base onm), NO en Timescale.
--
-- QUE HACE: anade la politica de agregacion de salud del rol. Una sola columna
--   numerica: no hace falta un ENUM porque las cuatro politicas que se plantearon
--   resultaron ser la misma regla con distinto umbral.
--
--     down     si  dispositivos_caidos > health_threshold * total
--     degraded si  hay alguno caido pero no supera el umbral
--     healthy  si  ninguno caido
--     unknown  si  no hay dato
--
--   | comportamiento                  | health_threshold |
--   |---------------------------------|------------------|
--   | cae si cae CUALQUIERA           | 0                |
--   | cae si cae MAS DE LA MITAD      | 0.500  <- defecto|
--   | cae solo si caen TODOS          | 0.990            |
--
-- ADITIVO Y SIN CAMBIO DE COMPORTAMIENTO: el defecto 0.500 es el criterio
--   uniforme acordado, y para los 224 roles de un solo dispositivo se comporta
--   exactamente igual que hoy (1 de 1 = 100% > 50% -> down). NO hace falta
--   ningun UPDATE inicial.
--
-- MySQL 5.5: no existe 'ADD COLUMN IF NOT EXISTS'. Si se reejecuta dara
--   "Duplicate column name"; es inofensivo, significa que ya estaba aplicado.
-- =============================================================================

ALTER TABLE sem_business_role
  ADD COLUMN health_threshold      DECIMAL(4,3) NOT NULL DEFAULT 0.500,
  ADD COLUMN health_threshold_note VARCHAR(255) NULL;

-- health_threshold_note: NULL = criterio uniforme por defecto. Cualquier valor
-- distinto de 0.500 DEBE llevar justificacion, para que dentro de unos meses se
-- sepa si fue una decision meditada o un experimento olvidado.

-- --- Verificacion ---
-- SHOW COLUMNS FROM sem_business_role LIKE 'health_%';
-- SELECT health_threshold, COUNT(*) FROM sem_business_role
--  WHERE status='active' GROUP BY 1;      -- debe dar todo 0.500
--
-- --- Gobernanza: desviaciones sin justificar ---
-- SELECT role_id, role_type, health_threshold, health_threshold_note
--   FROM sem_business_role
--  WHERE status='active' AND health_threshold <> 0.500
--  ORDER BY health_threshold_note IS NOT NULL, role_id;
