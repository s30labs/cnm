<?php
/**
 * =============================================================================
 * CNM_DB.impl.php — Implementación moderna (PHP 7.1+) del wrapper PDO
 * =============================================================================
 *
 * NO INCLUIR ESTE FICHERO DIRECTAMENTE.
 * Se carga automáticamente desde CNM_DB.php (el loader) cuando la versión
 * de PHP es >= 7.1. Para PHP 5.6 el loader carga CNM_DB.legacy.php en su lugar.
 *
 * Ambas implementaciones declaran las mismas clases (CNM_DB, CNM_DB_Result,
 * CNM_DB_Error) y la misma función global CNM_isError(), de modo que el resto
 * del código es agnóstico a cuál se haya cargado.
 *
 * Esta versión usa características de PHP 7.1+/8.0 (union types, named
 * arguments, mixed, void, nullable, const con visibilidad). Si se incluye
 * en PHP 5.6 producirá un Parse Error — por eso NUNCA debe incluirse
 * directamente, solo a través del loader.
 *
 * PROPÓSITO
 * ---------
 * Este fichero reemplaza la dependencia de PEAR::DB (pear/DB) en todos los
 * subsistemas de la plataforma de monitorización:
 *
 *   SUBSISTEMA 1 — Motor interno
 *     DB-Scheme-Lib.php, db-manage.php
 *
 *   SUBSISTEMA 2 — Backend web
 *     mysql_session.inc, Store.php, login.php, mod_login.php,
 *     class_cnmdevice.php y demás ficheros funcionales bajo inc/
 *
 * Implementa una capa de compatibilidad sobre PDO que emula exactamente la API
 * de PEAR::DB inventariada en el código existente, minimizando los cambios
 * necesarios en cada fichero.
 *
 * MIGRACIÓN: Debian 11 / PHP 7 / PEAR::DB  →  Debian 13 / PHP 8 / PDO
 * VERSIÓN:   1.1.0
 *
 * INVENTARIO GLOBAL DE MÉTODOS CUBIERTOS
 * (resultado del grep sobre /var/www/html/onm/ --include="*.php")
 * -----------------------------------------------------------------------
 *   $dbc->query()          305 usos  →  CNM_DB::query()
 *   $result->fetchInto()   142 usos  →  CNM_DB_Result::fetchInto()
 *   $dbc->escapeSimple()    49 usos  →  CNM_DB::escapeSimple()
 *   $result->getMessage()   37 usos  →  CNM_DB_Error::getMessage()
 *   $result->getCode()      31 usos  →  CNM_DB_Error::getCode()
 *   $result->getUserInfo()  13 usos  →  CNM_DB_Error::getUserInfo()
 *   $dbc->affectedRows()    13 usos  →  CNM_DB::affectedRows()      [v1.1]
 *   $result->free()          4 usos  →  CNM_DB_Result::free()
 *   $dbc->setFetchMode()     2 usos  →  CNM_DB::setFetchMode()
 *   CNM_DB::Connect()            4 usos  →  CNM_DB::Connect()
 *   CNM_isError()        ~89 usos  →  CNM_isError()               [función global]
 *
 * MÉTODOS EXCLUIDOS DEL SCOPE
 * -----------------------------------------------------------------------
 *   fetch() / fetchAll() — solo aparecen en demos de librerías de terceros
 *   (/libs/jquery/handsontable/, /libs/jquery/datatables/) que ya usan
 *   PDO nativo. No forman parte del código de la aplicación.
 *
 * CAMBIOS MÍNIMOS NECESARIOS EN EL CÓDIGO EXISTENTE
 * -----------------------------------------------------------------------
 *   1. require_once PEAR/DB.php  →  require_once CNM_DB.php
 *   2. CNM_DB::Connect($p, TRUE)     →  CNM_DB::Connect($p, true)
 *   3. CNM_isError($x)        →  CNM_isError($x)
 *   4. $_SESSION['DBC'] = $dbc   →  $_SESSION['DBC_PARAMS'] = get_dbc_params()
 *      (solo en login.php y mod_login.php — PDO no es serializable)
 *
 * DEUDA TÉCNICA DETECTADA (no corregir durante la migración)
 * -----------------------------------------------------------------------
 *   - DB-Scheme-Lib.php línea 521: if($mode=0) — asignación, no comparación
 *   - db-manage.php línea 794: $cred["CNM_DB_PASWORD"] — typo, falta 'S'
 *   - Queries con concatenación directa de variables (sin escapado)
 *
 * NOTAS DE SEGURIDAD
 * -----------------------------------------------------------------------
 *   - escapeSimple() se mantiene por compatibilidad con el código existente.
 *     En código nuevo usar siempre prepared statements con parámetros.
 *   - affectedRows() es fiable en PDO solo tras INSERT/UPDATE/DELETE.
 *     No usar tras SELECT (rowCount() no está garantizado en todos los drivers).
 *
 * =============================================================================
 */


// =============================================================================
// CONSTANTES DE COMPATIBILIDAD
// Reemplazan las constantes DB_FETCHMODE_* de PEAR::DB.
// Se definen con if(!defined) para evitar conflictos si el fichero
// se incluye varias veces desde distintos puntos de entrada.
// =============================================================================

if (!defined('DB_FETCHMODE_ASSOC')) {
    define('DB_FETCHMODE_ASSOC', PDO::FETCH_ASSOC);
}
if (!defined('DB_FETCHMODE_NUM')) {
    define('DB_FETCHMODE_NUM', PDO::FETCH_NUM);
}
if (!defined('DB_FETCHMODE_OBJECT')) {
    define('DB_FETCHMODE_OBJECT', PDO::FETCH_OBJ);
}


// =============================================================================
// FUNCIÓN GLOBAL: CNM_isError()
// Reemplaza CNM_isError() y DB::isError() (~89 usos en el código)
// =============================================================================

/**
 * Comprueba si un valor es un error de base de datos.
 *
 * Reemplaza:
 *   CNM_isError($val)
 *   @DB::isError($val)
 *
 * El operador @ puede mantenerse en el código existente aunque ya no
 * es necesario: este wrapper nunca lanza excepciones, las encapsula
 * como CNM_DB_Error.
 *
 * @param  mixed $value  Valor a comprobar (resultado de query, conexión, etc.)
 * @return bool          True si es un error, false en caso contrario
 */
function CNM_isError(mixed $value): bool
{
    return $value instanceof CNM_DB_Error;
}


// =============================================================================
// CLASE: CNM_DB
// Reemplaza el objeto $dbc / $enlace y la clase DB de PEAR
// =============================================================================

class CNM_DB
{
    // -------------------------------------------------------------------------
    // Propiedades privadas
    // -------------------------------------------------------------------------

    /** @var PDO Conexión PDO subyacente */
    private PDO $pdo;

    /**
     * @var string Última query ejecutada.
     * Se almacena para incluirla en el userInfo del error replicando
     * el comportamiento de PEAR::DB, que incluía la query en getMessage().
     */
    private string $lastQuery = '';

    /**
     * @var int Fetch mode por defecto.
     * PEAR::DB lo configuraba con setFetchMode(DB_FETCHMODE_ASSOC).
     * En PDO se aplica por statement en query(); aquí lo almacenamos
     * para propagarlo a cada CNM_DB_Result.
     */
    private int $fetchMode = PDO::FETCH_ASSOC;

    /**
     * @var PDOStatement|null Último statement ejecutado con éxito.
     *
     * Necesario para implementar affectedRows() sobre $dbc.
     * PEAR::DB tenía affectedRows() como método del objeto conexión,
     * pero internamente consultaba el último statement. PDO expone
     * rowCount() en el statement, no en la conexión, por lo que
     * debemos guardar una referencia al último statement ejecutado.
     *
     * IMPORTANTE: solo se actualiza tras ejecuciones exitosas.
     * Si query() devuelve CNM_DB_Error, $lastStmt no se actualiza,
     * por lo que affectedRows() seguirá refiriéndose al statement
     * anterior — mismo comportamiento que tenía PEAR::DB.
     */
    private ?PDOStatement $lastStmt = null;


    // -------------------------------------------------------------------------
    // Constructor privado — instanciar solo a través de Connect()
    // -------------------------------------------------------------------------

    private function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }


    // -------------------------------------------------------------------------
    // Connect() — Reemplaza CNM_DB::Connect()
    // -------------------------------------------------------------------------

    /**
     * Crea y devuelve una conexión a la base de datos.
     *
     * Reemplaza (4 ocurrencias: abreBD x2, mysql_session_open_cnm x1,
     *            abreBD_old x1 — función obsoleta no activa):
     *   $dbc = CNM_DB::Connect($dsn, TRUE);
     *   if (CNM_isError($dbc)) { depura('error', $dbc->getMessage()); }
     *
     * Acepta el array de parámetros en formato PEAR::DB:
     *   'phptype'  => 'mysqli'    — ignorado, siempre mysql/mariadb
     *   'username' => 'onm'       — usuario de BBDD
     *   'password' => '...'       — contraseña
     *   'hostspec' => 'localhost' — host (alias: 'host')
     *   'database' => 'cnm'      — nombre de BBDD (OPCIONAL — ver nota)
     *
     * NOTA sobre 'database' opcional:
     *   DB-Scheme-Lib.php llama a connectDB() sin 'database' en los casos
     *   donde necesita conectar sin seleccionar BBDD (ej: CREATE DATABASE).
     *   El wrapper construye el DSN sin dbname en ese caso.
     *
     * NOTA sobre conexiones persistentes:
     *   PEAR::DB usaba TRUE como segundo parámetro para activar pconnect.
     *   PDO lo controla con PDO::ATTR_PERSISTENT. El pool de conexiones
     *   persistentes de PHP-FPM hace que la reconexión en cada request
     *   sea de coste mínimo, lo que resuelve el problema de serialización
     *   de PDO en $_SESSION (PDO no es serializable, PEAR::DB sí lo era).
     *
     * @param  array $params      Parámetros de conexión (formato PEAR::DB)
     * @param  bool  $persistent  Si true, usa conexión persistente
     * @return CNM_DB|CNM_DB_Error
     */
    public static function Connect(array $params, bool $persistent = false): CNM_DB|CNM_DB_Error
    {
        try {
            $host    = $params['hostspec'] ?? $params['host'] ?? 'localhost';
            $user    = $params['username'] ?? $params['user'] ?? '';
            $pass    = $params['password'] ?? $params['pass'] ?? '';
            $charset = 'utf8mb4';

            // 'database' es opcional — puede no venir en $db_params
            $dbname = '';
            if (!empty($params['database'])) {
                $dbname = ";dbname={$params['database']}";
            }

            $dsn = "mysql:host={$host}{$dbname};charset={$charset}";

            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::ATTR_PERSISTENT         => $persistent,
                // Necesario para queries multi-sentencia como CREATE PROCEDURE
                // usadas en ProcedureInit() de DB-Scheme-Lib.php
                PDO::MYSQL_ATTR_MULTI_STATEMENTS => true,
            ];

            $pdo = new PDO($dsn, $user, $pass, $options);
            return new self($pdo);

        } catch (PDOException $e) {
            return new CNM_DB_Error(
                message:  $e->getMessage(),
                code:     $e->getCode(),
                userInfo: "Connect failed: " . $e->getMessage(),
                query:    ''
            );
        }
    }


    // -------------------------------------------------------------------------
    // setFetchMode() — Reemplaza $dbc->setFetchMode()
    // -------------------------------------------------------------------------

    /**
     * Establece el fetch mode por defecto para las queries subsiguientes.
     *
     * Inventario de usos (2 en total):
     *   mysql_session.inc líneas 78, 128, 257: $dbc->setFetchMode(DB_FETCHMODE_ASSOC)
     *
     * En PDO el fetch mode ASSOC ya es el default configurado en Connect(),
     * pero se mantiene este método para no tener que modificar el código.
     *
     * Constantes de compatibilidad definidas en este fichero:
     *   DB_FETCHMODE_ASSOC   = PDO::FETCH_ASSOC
     *   DB_FETCHMODE_NUM     = PDO::FETCH_NUM
     *   DB_FETCHMODE_OBJECT  = PDO::FETCH_OBJ
     *
     * @param  int  $mode  Fetch mode (DB_FETCHMODE_* o PDO::FETCH_*)
     * @return void
     */
    public function setFetchMode(int $mode): void
    {
        $this->fetchMode = $mode;
    }


    // -------------------------------------------------------------------------
    // query() — Reemplaza $dbc->query()
    // -------------------------------------------------------------------------

    /**
     * Ejecuta una query SQL y devuelve un objeto resultado o un error.
     *
     * Inventario de usos: 305 ocurrencias en el código de la aplicación.
     *
     * Patrones habituales:
     *   // Con comprobación de error:
     *   $result = $dbc->query($sql);
     *   if (CNM_isError($result)) { ... $result->getUserInfo() ... }
     *   while ($result->fetchInto($r)) { ... }
     *
     *   // Sin comprobación (queries de escritura):
     *   $dbc->query($sql);
     *   $rows = $dbc->affectedRows();
     *
     * NOTA sobre prepared statements:
     *   El código existente construye las queries por concatenación de strings.
     *   Este método acepta opcionalmente un array $params para prepared
     *   statements, disponible para uso en código nuevo.
     *
     * NOTA sobre el operador @:
     *   El código original usa CNM_isError(). Con este wrapper el @
     *   sobre query() no es necesario (los errores PDO se capturan en el
     *   catch), pero tampoco causa problemas si se mantiene.
     *
     * @param  string  $sql     Query SQL
     * @param  array   $params  Parámetros para prepared statement (opcional)
     * @return CNM_DB_Result|CNM_DB_Error
     */
    public function query(string $sql, array $params = []): CNM_DB_Result|CNM_DB_Error
    {
        $this->lastQuery = $sql;

        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            $stmt->setFetchMode($this->fetchMode);

            // Guardar referencia para affectedRows()
            $this->lastStmt = $stmt;

            return new CNM_DB_Result(
                stmt:      $stmt,
                lastQuery: $sql,
                fetchMode: $this->fetchMode
            );

        } catch (PDOException $e) {
            // lastStmt NO se actualiza en caso de error —
            // affectedRows() seguirá devolviendo el valor del último
            // statement exitoso, igual que hacía PEAR::DB
            return new CNM_DB_Error(
                message:  $e->getMessage(),
                code:     $e->getCode(),
                // Formato PEAR::DB: "query [nativecode=X ** mensaje]"
                // Preservado para no romper los logs existentes
                userInfo: "{$sql} [nativecode={$e->getCode()} ** {$e->getMessage()}]",
                query:    $sql
            );
        }
    }


    // -------------------------------------------------------------------------
    // affectedRows() — Reemplaza $dbc->affectedRows()
    // -------------------------------------------------------------------------

    /**
     * Devuelve el número de filas afectadas por la última query ejecutada.
     *
     * Inventario de usos: 13 ocurrencias en Store.php + 1 en mysql_session.inc.
     *
     * Patrones encontrados:
     *   // Patrón A — lectura directa tras query (10 casos):
     *   $result = $dbc->query($sql);
     *   $rows   = $dbc->affectedRows();
     *
     *   // Patrón B — condición compuesta (3 casos en Store.php):
     *   if ( CNM_isError($result) || $dbc->affectedRows() == 0 ) { $RC = 10; }
     *
     *   // Patrón C — valor de retorno de función (mysql_session.inc línea 409):
     *   return $dbc->affectedRows();
     *
     * IMPLEMENTACIÓN:
     *   PEAR::DB tenía affectedRows() como método del objeto conexión, pero
     *   internamente consultaba al driver el recuento de la última operación.
     *   En PDO, rowCount() es un método de PDOStatement, no de PDO.
     *   La solución es guardar el último PDOStatement exitoso en $lastStmt
     *   (se actualiza en query() solo tras ejecuciones sin excepción).
     *
     * ADVERTENCIA:
     *   PDO::rowCount() para SELECT no está garantizado en todos los drivers.
     *   En MariaDB funciona correctamente, pero el uso semánticamente correcto
     *   es solo tras INSERT, UPDATE o DELETE — que es exactamente cómo se usa
     *   en el código existente.
     *
     * @return int  Filas afectadas. -1 si no se ha ejecutado ninguna query aún.
     */
    public function affectedRows(): int
    {
        if ($this->lastStmt === null) {
            return -1;
        }
        return $this->lastStmt->rowCount();
    }


    // -------------------------------------------------------------------------
    // escapeSimple() — Reemplaza $dbc->escapeSimple()
    // -------------------------------------------------------------------------

    /**
     * Escapa una cadena para uso seguro en queries construidas por concatenación.
     *
     * Inventario de usos: 49 ocurrencias (Store.php, DB-Scheme-Lib.php,
     *                     class_cnmdevice.php y otros ficheros funcionales).
     *
     * DIFERENCIA CRÍTICA con PDO::quote():
     *   escapeSimple()  →  valor\'escapado        (SIN comillas externas)
     *   PDO::quote()    →  'valor\'escapado'      (CON comillas externas)
     *
     * El código existente añade las comillas manualmente:
     *   $a_Vals[] = "'" . $dbc->escapeSimple($valor) . "'";
     *   $sql .= '"' . $dbc->escapeSimple($param) . '"';
     *
     * Por tanto NO podemos usar PDO::quote() directamente — hay que extraer
     * el interior quitando la comilla inicial y final.
     *
     * NOTA DE SEGURIDAD: Este método existe por compatibilidad. En código
     * nuevo usar siempre prepared statements con parámetros vinculados.
     *
     * @param  mixed  $value  Valor a escapar
     * @return string         Valor escapado sin comillas delimitadoras
     */
    public function escapeSimple(mixed $value): string
    {
        if (is_null($value)) {
            return '';
        }

        if (is_int($value) || is_float($value)) {
            return (string) $value;
        }

        // PDO::quote() devuelve 'valor' — quitamos las comillas externas
        $quoted = $this->pdo->quote((string) $value);
        return substr($quoted, 1, -1);
    }


    // -------------------------------------------------------------------------
    // lastInsertId() — Equivalente a mysql_insert_id()
    // -------------------------------------------------------------------------

    /**
     * Devuelve el ID generado en el último INSERT con AUTO_INCREMENT.
     *
     * No inventariado explícitamente en el grep (puede estar bajo otro nombre
     * o en ficheros no analizados), pero se incluye como método estándar
     * esperado en cualquier capa de acceso a BBDD.
     *
     * @return string  PDO siempre devuelve string para lastInsertId()
     */
    public function lastInsertId(): string
    {
        return $this->pdo->lastInsertId();
    }


    // -------------------------------------------------------------------------
    // Gestión de transacciones
    // -------------------------------------------------------------------------

    /**
     * Inicia una transacción explícita.
     * No inventariado en el grep pero disponible para uso en código nuevo.
     */
    public function beginTransaction(): void { $this->pdo->beginTransaction(); }

    /** Confirma la transacción activa. */
    public function commit(): void { $this->pdo->commit(); }

    /** Deshace la transacción activa. */
    public function rollback(): void { $this->pdo->rollBack(); }


    // -------------------------------------------------------------------------
    // getPDO() — Acceso de emergencia al PDO subyacente
    // -------------------------------------------------------------------------

    /**
     * Devuelve la instancia PDO subyacente.
     *
     * Solo usar si el wrapper no cubre algún caso concreto.
     * La política correcta es extender el wrapper en lugar de bypassarlo,
     * pero este método queda disponible para situaciones excepcionales.
     *
     * @return PDO
     */
    public function getPDO(): PDO
    {
        return $this->pdo;
    }
}


// =============================================================================
// CLASE: CNM_DB_Result
// Reemplaza el objeto resultado devuelto por $dbc->query() en PEAR::DB
// =============================================================================

class CNM_DB_Result
{
    /** @var PDOStatement Statement PDO subyacente */
    private PDOStatement $stmt;

    /**
     * @var string Query que generó este resultado.
     * Guardada como guardia defensiva en getUserInfo() si se llama
     * sobre un resultado válido en lugar de sobre un error.
     */
    private string $lastQuery;

    /** @var int Fetch mode heredado de CNM_DB al crear el resultado */
    private int $fetchMode;


    // Constructor — solo llamado desde CNM_DB::query()
    public function __construct(PDOStatement $stmt, string $lastQuery, int $fetchMode)
    {
        $this->stmt      = $stmt;
        $this->lastQuery = $lastQuery;
        $this->fetchMode = $fetchMode;
    }


    // -------------------------------------------------------------------------
    // fetchInto() — Reemplaza $result->fetchInto($var)
    // -------------------------------------------------------------------------

    /**
     * Obtiene la siguiente fila y la almacena en $var por referencia.
     *
     * Inventario de usos: 142 ocurrencias. El método más usado del resultado.
     *
     * Variante A — bucle (uso dominante):
     *   while ($result->fetchInto($r)) {
     *       // $r['campo'] disponible aquí
     *   }
     *
     * Variante B — fila única:
     *   $result->fetchInto($r);
     *   $val = $r['campo'];
     *
     * DIFERENCIA con PEAR::DB:
     *   PEAR devolvía DB_OK (=1) en éxito y DB_ERROR en fallo.
     *   Este wrapper devuelve bool, que es lo que necesita el patrón while().
     *   Ambos valores son truthy/falsy de forma compatible.
     *
     * NOTA sobre $var tras fin de resultados:
     *   PEAR::DB dejaba $var sin modificar al acabar el cursor.
     *   Este wrapper la pone a null explícitamente, comportamiento más
     *   predecible y compatible con PHP 8 (evita warnings de offset en null).
     *
     * @param  mixed &$var  Variable que recibirá la fila
     * @param  int    $mode Fetch mode (0 = usar el configurado en la conexión)
     * @return bool         True si se obtuvo una fila, false si no hay más
     */
    public function fetchInto(mixed &$var, int $mode = 0): bool
    {
        $fetchMode = ($mode !== 0) ? $mode : $this->fetchMode;
        $row = $this->stmt->fetch($fetchMode);

        if ($row === false) {
            $var = null;
            return false;
        }

        $var = $row;
        return true;
    }


    // -------------------------------------------------------------------------
    // fetchAll() — Método de conveniencia
    // -------------------------------------------------------------------------

    /**
     * Devuelve todas las filas del resultado como array.
     *
     * No existía en PEAR::DB (requería bucle con fetchInto).
     * Se incluye para facilitar refactorizaciones futuras del código existente
     * y para uso en código nuevo que no necesite compatibilidad con PEAR::DB.
     *
     * @param  int  $mode  Fetch mode (0 = usar el configurado en la conexión)
     * @return array
     */
    public function fetchAll(int $mode = 0): array
    {
        $fetchMode = ($mode !== 0) ? $mode : $this->fetchMode;
        return $this->stmt->fetchAll($fetchMode);
    }


    // -------------------------------------------------------------------------
    // getUserInfo() — Guardia defensiva
    // -------------------------------------------------------------------------

    /**
     * Devuelve información extendida sobre el error.
     *
     * NOTA: Este método tiene su implementación real en CNM_DB_Error.
     * Si se llama sobre un CNM_DB_Result (resultado válido, no un error),
     * significa que el código que llama no está comprobando CNM_isError()
     * antes de llamar a getUserInfo(). Se devuelve un mensaje descriptivo
     * para facilitar la depuración en lugar de lanzar una excepción.
     *
     * El flujo correcto siempre es:
     *   $result = $dbc->query($sql);
     *   if (CNM_isError($result)) {
     *       log($result->getUserInfo());  // aquí $result ES CNM_DB_Error
     *   }
     *
     * @return string
     */
    public function getUserInfo(): string
    {
        return "[CNM_DB_Result::getUserInfo() llamado sobre resultado válido. Query: {$this->lastQuery}]";
    }


    // -------------------------------------------------------------------------
    // getCode() — Guardia defensiva
    // -------------------------------------------------------------------------

    /**
     * Devuelve el código de error.
     *
     * Implementación real en CNM_DB_Error. Aquí devuelve 0 (sin error)
     * ya que un CNM_DB_Result representa una query exitosa.
     *
     * El único uso funcional de getCode() sobre el objeto resultado
     * es cuando éste es en realidad un CNM_DB_Error (comprobado con
     * CNM_isError() previamente), por lo que este método actúa
     * exclusivamente como guardia defensiva.
     *
     * @return int|string  0 — sin error
     */
    public function getCode(): int|string
    {
        return 0;
    }


    // -------------------------------------------------------------------------
    // getMessage() — Guardia defensiva
    // -------------------------------------------------------------------------

    /**
     * Devuelve el mensaje de error.
     *
     * Implementación real en CNM_DB_Error.
     * Aquí devuelve string vacío ya que es un resultado válido.
     *
     * @return string
     */
    public function getMessage(): string
    {
        return '';
    }


    // -------------------------------------------------------------------------
    // free() — Reemplaza $result->free()
    // -------------------------------------------------------------------------

    /**
     * Libera los recursos del cursor de la query.
     *
     * Inventario de usos: 4 ocurrencias en el código de la aplicación.
     *
     * En PDO es buena práctica llamar a closeCursor() cuando se va a
     * reutilizar el objeto conexión para otra query en la misma petición,
     * especialmente con drivers que no soportan múltiples cursores abiertos.
     *
     * @return void
     */
    public function free(): void
    {
        $this->stmt->closeCursor();
    }
}


// =============================================================================
// CLASE: CNM_DB_Error
// Reemplaza PEAR_Error / DB_Error de PEAR::DB
// =============================================================================

class CNM_DB_Error
{
    // -------------------------------------------------------------------------
    // Tabla de mapeo: códigos nativos MariaDB → códigos PEAR::DB negativos
    // -------------------------------------------------------------------------

    /**
     * PEAR::DB usaba códigos negativos propios para clasificar los errores.
     * El código existente en Store.php usa estos códigos en $a_global_sql_error
     * para mostrar mensajes descriptivos al cliente en responseJSON/responseXML.
     *
     * PDO usa SQLSTATE (string de 5 chars) y el código nativo del driver (int).
     * Este wrapper mapea los códigos nativos de MariaDB a los códigos PEAR::DB
     * para que $a_global_sql_error siga funcionando correctamente.
     *
     * Referencia completa de $a_global_sql_error (Store.php líneas 16-44):
     *   '-1'  → DB_ERROR              (error genérico)
     *   '-2'  → DB_ERROR_SYNTAX       (error de sintaxis SQL)
     *   '-3'  → DB_ERROR_CONSTRAINT   (violación de foreign key)
     *   '-5'  → DB_ERROR_ALREADY_EXISTS (entrada duplicada)
     *   '-17' → DB_ERROR_CANNOT_DROP  (no se puede eliminar tabla/índice)
     *   '-18' → DB_ERROR_NOSUCHTABLE  (tabla no encontrada) ← también CANNOT_ALTER
     *   '-19' → DB_ERROR_NOSUCHFIELD  (columna desconocida)
     *   '-26' → DB_ERROR_ACCESS_VIOLATION (sin permisos)
     *   '-27' → DB_ERROR_NOSUCHDB     (base de datos desconocida)
     *   '-29' → DB_ERROR_CONSTRAINT_NOT_NULL (columna NOT NULL sin valor)
     *
     * Mapeo MariaDB nativo → PEAR::DB:
     *   1064 → '-2'  SQL syntax error
     *   1062 → '-5'  Duplicate entry (UNIQUE constraint)
     *   1451 → '-3'  FK constraint (parent row exists)
     *   1452 → '-3'  FK constraint (child row missing)
     *   1048 → '-29' Column cannot be null
     *   1146 → '-18' Table doesn't exist
     *   1054 → '-19' Unknown column
     *   1044 → '-26' Access denied to database
     *   1045 → '-26' Access denied (user/password)
     *   1049 → '-27' Unknown database
     *   2002 → '-24' Can't connect to server
     *   1060 → '-18' Duplicate column name       (ALTER TABLE)
     *   1061 → '-18' Duplicate key name          (ALTER TABLE)
     *   1091 → '-18' Can't DROP; column not found (ALTER TABLE)
     *   1101 → '-18' BLOB/TEXT can't have default (ALTER TABLE)
     *
     * NOTA: Los códigos de ALTER TABLE se mapean a '-18' para mantener
     * compatibilidad con la comprobación en DB-Scheme-Lib.php línea 1808:
     *   if ($resultAlterTabla->getCode() == '-18') { ... }
     */
    private const MARIADB_TO_PEAR = [
        1064 => '-2',
        1062 => '-5',
        1451 => '-3',
        1452 => '-3',
        1048 => '-29',
        1146 => '-18',
        1054 => '-19',
        1044 => '-26',
        1045 => '-26',
        1049 => '-27',
        2002 => '-24',
        1060 => '-18',
        1061 => '-18',
        1091 => '-18',
        1101 => '-18',
    ];

    /** Código PEAR::DB para errores ALTER TABLE */
    const PEAR_CANNOT_ALTER = '-18';


    // -------------------------------------------------------------------------
    // Propiedades
    // -------------------------------------------------------------------------

    /** @var string Mensaje de error del driver de MariaDB */
    private string $message;

    /**
     * @var int|string Código de error nativo del driver.
     * Se almacena el código nativo; getCode() aplica el mapeo al devolver.
     */
    private int|string $code;

    /**
     * @var string Información extendida.
     * Formato replicado de PEAR::DB:
     * "SELECT * FROM t [nativecode=1146 ** Table 'db.t' doesn't exist]"
     */
    private string $userInfo;

    /** @var string Query que provocó el error (incluida en userInfo) */
    private string $query;


    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    public function __construct(
        string     $message,
        int|string $code,
        string     $userInfo = '',
        string     $query    = ''
    ) {
        $this->message  = $message;
        $this->code     = $code;
        $this->userInfo = $userInfo ?: $message;
        $this->query    = $query;
    }


    // -------------------------------------------------------------------------
    // getMessage()
    // -------------------------------------------------------------------------

    /**
     * Devuelve el mensaje de error del driver.
     *
     * Inventario de usos: 37 ocurrencias sobre objetos resultado.
     * Además 3 usos sobre el objeto conexión $dbc cuando Connect() falla
     * (en mysql_session.inc) — cubiertos porque $dbc es CNM_DB_Error
     * cuando la conexión falla.
     *
     * @return string
     */
    public function getMessage(): string
    {
        return $this->message;
    }


    // -------------------------------------------------------------------------
    // getCode()
    // -------------------------------------------------------------------------

    /**
     * Devuelve el código de error mapeado al espacio de PEAR::DB.
     *
     * Inventario de usos: 31 ocurrencias en Store.php y otros ficheros.
     *
     * USO CRÍTICO en DB-Scheme-Lib.php línea 1808:
     *   if ($resultAlterTabla->getCode() == '-18') { ... }
     *
     * USO en Store.php para $a_global_sql_error:
     *   $response['rc'] = $result->getCode();
     *   // ... más adelante en responseJSON():
     *   $value .= " (RC = {$data['rc']} || {$a_global_sql_error[$data['rc']]})";
     *
     * El mapeo en MARIADB_TO_PEAR cubre los errores más frecuentes.
     * Para códigos no mapeados se devuelve el código nativo tal cual,
     * lo que puede resultar en que $a_global_sql_error no encuentre
     * la clave — comportamiento tolerable (mensaje sin descripción textual).
     *
     * @return int|string  Código PEAR::DB negativo, o código nativo si no mapeado
     */
    public function getCode(): int|string
    {
        $nativeCode = (int) $this->code;

        if (isset(self::MARIADB_TO_PEAR[$nativeCode])) {
            return self::MARIADB_TO_PEAR[$nativeCode];
        }

        return $this->code;
    }


    // -------------------------------------------------------------------------
    // getUserInfo()
    // -------------------------------------------------------------------------

    /**
     * Devuelve información extendida del error incluyendo la query fallida.
     *
     * Inventario de usos: 13 ocurrencias en Store.php y DB-Scheme-Lib.php.
     *
     * Formato replicado de PEAR::DB:
     *   "SELECT * FROM tabla [nativecode=1146 ** Table 'db.tabla' doesn't exist]"
     *
     * Uso típico:
     *   CNMUtils::error_log(__FILE__, __LINE__, "Error || USERINFO=" . $result->getUserInfo());
     *
     * @return string
     */
    public function getUserInfo(): string
    {
        return $this->userInfo;
    }


    // -------------------------------------------------------------------------
    // toString() / __toString()
    // -------------------------------------------------------------------------

    /**
     * Representación string del error.
     * Permite usar el objeto en contextos de concatenación de strings.
     *
     * @return string
     */
    public function toString(): string
    {
        return "[CNM_DB Error: {$this->code}] {$this->message}";
    }

    public function __toString(): string
    {
        return $this->toString();
    }
}


// =============================================================================
// GUÍA DE MIGRACIÓN RÁPIDA
// =============================================================================
/*

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SUBSISTEMA 1 — Motor interno
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DB-Scheme-Lib.php:
  1. require_once('/usr/share/pear/DB.php')
     → require_once('/opt/cnm/update/db/CNM_DB.php')

  2. $enlace = CNM_DB::Connect($db_params, TRUE)
     → $enlace = CNM_DB::Connect($db_params, true)

  3. CNM_isError($x)  →  CNM_isError($x)   [~30 ocurrencias]
     grep -n "CNM_isError" DB-Scheme-Lib.php
     sed -i 's/CNM_isError/CNM_isError/g' DB-Scheme-Lib.php

  4. Sin cambios en: query, fetchInto, escapeSimple, getUserInfo,
     getCode, setFetchMode, DB_FETCHMODE_ASSOC

db-manage.php:
  - Sin cambios obligatorios ('phptype' en $db_params se ignora)
  - Deuda: typo 'CNM_DB_PASWORD' en d_drop_table() línea 794

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SUBSISTEMA 2 — Backend web
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mysql_session.inc:
  1. require_once('DB.php')  →  require_once('CNM_DB.php')
  2. CNM_DB::Connect($dsn, TRUE)  →  CNM_DB::Connect($dsn, true)
  3. CNM_isError($x)  →  CNM_isError($x)   [9 ocurrencias]
  4. Añadir función get_dbc_params()
  5. Sustituir recuperación de $_SESSION['DBC'] por reconexión
     desde $_SESSION['DBC_PARAMS'] (PDO no es serializable)

Store.php:
  1. Eliminar require_once('/usr/share/pear/DB.php') línea 2
     (CNM_DB.php ya se carga transitivamente desde mysql_session.inc)
  2. CNM_isError($x)  →  CNM_isError($x)   [50 ocurrencias]
     sed -i 's/CNM_isError/CNM_isError/g' Store.php
  3. affectedRows() — sin cambio de código (ya cubierto en wrapper)

login.php y mod_login.php:
  1. Eliminar require_once('/usr/share/pear/DB.php') línea 3
  2. $_SESSION['DBC'] = $dbc  →  $_SESSION['DBC_PARAMS'] = get_dbc_params()
     (4 ocurrencias en total: open() y register() de cada fichero)

Resto de ficheros funcionales (class_cnmdevice.php, etc.):
  - Solo necesitan el require de CNM_DB.php si no lo cargan
    transitivamente desde Store.php o mysql_session.inc
  - Sin cambios en llamadas a métodos

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 VERIFICACIÓN GLOBAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  # Confirmar que no quedan referencias a PEAR en código activo:
  grep -rn "PEAR::\|CNM_DB::Connect\|require.*pear\|require.*DB\.php" \
    /var/www/html/onm/ /opt/cnm/update/db/ --include="*.php" \
    | grep -v "/libs/"   # excluir librerías de terceros

  # Resultado esperado: sin resultados (o solo en comentarios)

*/
