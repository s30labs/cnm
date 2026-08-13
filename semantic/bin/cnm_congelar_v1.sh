#!/bin/bash
# =============================================================================
# cnm_congelar_v1.sh — congela la línea base v1 de la capa semántica.
# Ejecutar SOLO después de: aplicar cnm_normaliza_pais_v4.sql en la BD, recargar
# el maestro v4, y confirmar control de integridad = 0.
# Copia los ficheros de entrada + un volcado del estado real de la BD.
# =============================================================================
set -e
DATA=/opt/data/semantic
TS=$(date +%Y%m%d_%H%M)
DEST=$DATA/historico/v1_$TS
DB=onm

mkdir -p "$DEST"
echo "Congelando v1 en $DEST"

# 1) ficheros de entrada que produjeron esta v1
for f in cnm_roles_maestro_areas_v4.csv cnm_roles_maestro_areas_v4.xlsx \
         cnm_col1_crosswalk_DEFINITIVO.csv cnm_sitemap_DEFINITIVO.csv \
         cnm_org_unit_propuesta_v2.csv; do
  [ -f "$DATA/$f" ] && cp "$DATA/$f" "$DEST/" && echo "  copiado $f" || echo "  (falta $f, revisar)"
done

# 2) volcado de las tablas semánticas tal como quedaron
mysqldump $DB sem_business_role sem_org_unit sem_load_audit sem_role_change_log \
  > "$DEST/sem_tables_v1.sql"
echo "  volcado sem_tables_v1.sql"

# 3) estado de col7 (RoleID por dispositivo) en el momento del congelado
mysql $DB -N -e "SELECT id_dev, columna7 FROM devices_custom_data WHERE COALESCE(columna7,'-')<>'-' ORDER BY id_dev" \
  > "$DEST/col7_v1.tsv"
echo "  volcado col7_v1.tsv ($(wc -l < "$DEST/col7_v1.tsv") dispositivos con rol)"

# 4) foto de cobertura (las consultas clave) guardada como texto
{
  echo "=== COBERTURA v1 ($(date)) ==="
  echo "--- dispositivos con/sin rol ---"
  mysql $DB -t -e "SELECT SUM(CASE WHEN COALESCE(c.columna7,'-')<>'-' THEN 1 ELSE 0 END) AS con_rol, SUM(CASE WHEN COALESCE(c.columna7,'-')='-' THEN 1 ELSE 0 END) AS sin_rol, COUNT(*) AS total FROM devices d LEFT JOIN devices_custom_data c ON c.id_dev=d.id_dev WHERE COALESCE(d.status,0) IN (0,2)"
  echo "--- reparto por clase de rol ---"
  mysql $DB -t -e "SELECT CASE WHEN c.columna7 LIKE 'site.%' THEN 'site' WHEN c.columna7 LIKE 'svc.%' THEN 'technical_service' WHEN c.columna7 LIKE 'app.%' THEN 'application' ELSE 'otro' END AS clase, COUNT(*) n FROM devices d JOIN devices_custom_data c ON c.id_dev=d.id_dev WHERE COALESCE(d.status,0) IN (0,2) AND COALESCE(c.columna7,'-')<>'-' GROUP BY clase ORDER BY n DESC"
  echo "--- control integridad (debe ser 0 filas) ---"
  mysql $DB -t -e "SELECT DISTINCT c.columna7 FROM devices d JOIN devices_custom_data c ON c.id_dev=d.id_dev WHERE COALESCE(c.columna7,'-')<>'-' AND c.columna7 NOT IN (SELECT role_id FROM sem_business_role)"
  echo "--- roles por tipo/status ---"
  mysql $DB -t -e "SELECT role_type, status, COUNT(*) FROM sem_business_role GROUP BY role_type, status"
} > "$DEST/cobertura_v1.txt"
echo "  foto de cobertura -> cobertura_v1.txt"

# 5) sello: qué es esta v1
cat > "$DEST/README_v1.txt" <<EOF
Línea base v1 de la capa semántica CNM — congelada $TS
CONTIENE: roles (sem_business_role), org_units, col7 (RoleID por dispositivo),
          y los ficheros de entrada que la produjeron.
NO CONTIENE: binding (métricas->roles). El binding es fase posterior.
USO: punto de comparación para la iteración con el cliente. Ante cambios,
     comparar el maestro/col7 nuevos contra esta carpeta (diff).
EOF
echo "Congelado v1 COMPLETO en $DEST"
