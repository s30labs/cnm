<?php
/**
 * =============================================================================
 * CNM_DB.php — LOADER del wrapper de base de datos
 * =============================================================================
 *
 * PROPÓSITO
 * ---------
 * Este fichero es el ÚNICO punto de entrada que el resto del código debe
 * incluir. Selecciona en tiempo de ejecución la implementación adecuada
 * del wrapper según la versión de PHP del entorno:
 *
 *   PHP >= 7.1   →  CNM_DB.impl.php    (implementación moderna, con tipos)
 *   PHP <  7.1   →  CNM_DB.legacy.php  (implementación compatible PHP 5.6)
 *
 * Ambas implementaciones declaran exactamente las mismas clases y función:
 *   - class CNM_DB
 *   - class CNM_DB_Result
 *   - class CNM_DB_Error
 *   - function CNM_isError()
 *   - constantes DB_FETCHMODE_*
 *
 * Por tanto, todo el código de la aplicación (Store.php, mysql_session.inc,
 * y los ~30 ficheros del backend) sigue incluyendo 'CNM_DB.php' sin cambios
 * y es completamente agnóstico a cuál implementación se cargue.
 *
 * REGLA CRÍTICA
 * -------------
 * NINGÚN otro fichero debe incluir CNM_DB.impl.php ni CNM_DB.legacy.php
 * directamente. Solo este loader los carga. Si se incluyera CNM_DB.impl.php
 * directamente en PHP 5.6, se produciría un Parse Error al encontrar los
 * type hints modernos (union types, named arguments, etc.).
 *
 * CONTEXTO DE LA SITUACIÓN
 * ------------------------
 * Este loader existe para soportar una situación TEMPORAL en la que conviven
 * equipos en distintas versiones:
 *
 *   Debian 8  -> PHP 5.6.7  -> usa CNM_DB.legacy.php
 *   Debian 11 -> PHP 7.4    -> usa CNM_DB.impl.php
 *   Debian 13 -> PHP 8.x    -> usa CNM_DB.impl.php
 *
 * Cuando el equipo Debian 8 se migre, CNM_DB.legacy.php podra eliminarse
 * y este loader simplificarse o eliminarse (haciendo que CNM_DB.php pase
 * a ser de nuevo la implementacion directa).
 *
 * El umbral de version es 70100 (PHP 7.1.0) porque la implementacion moderna
 * usa constantes de clase con visibilidad (private const), introducidas en
 * PHP 7.1. Aunque PHP 7.0 soporta la mayoria del resto, no soporta esto.
 *
 * VERSION: 1.1.0
 * =============================================================================
 */

if (PHP_VERSION_ID >= 70100) {
    require_once __DIR__ . '/CNM_DB.impl.php';
} else {
    require_once __DIR__ . '/CNM_DB.legacy.php';
}
