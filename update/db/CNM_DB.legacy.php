<?php
/**
 * =============================================================================
 * CNM_DB.legacy.php - Implementacion compatible PHP 5.6 del wrapper PDO
 * =============================================================================
 *
 * NO INCLUIR ESTE FICHERO DIRECTAMENTE.
 * Se carga automaticamente desde CNM_DB.php (el loader) cuando la version
 * de PHP es < 7.1. Para PHP 7.1+ el loader carga CNM_DB.impl.php en su lugar.
 *
 * PROPOSITO
 * ---------
 * Replica exactamente la API publica de CNM_DB.impl.php pero escrita en el
 * subconjunto de PHP compatible con la version 5.6.7 (Debian 8 Jessie).
 *
 * DIFERENCIAS DE SINTAXIS RESPECTO A LA VERSION MODERNA
 * ------------------------------------------------------
 * PHP 5.6 NO soporta y por tanto NO se usan aqui:
 *   - Return type declarations        (: CNM_DB_Result)        -> PHP 7.0
 *   - Scalar type hints en parametros (string $sql, int $mode) -> PHP 7.0
 *   - Union types                     (CNM_DB|CNM_DB_Error)    -> PHP 8.0
 *   - Named arguments                 (new X(message: ...))    -> PHP 8.0
 *   - mixed / void                                             -> PHP 8.0 / 7.1
 *   - Nullable types                  (?PDOStatement)          -> PHP 7.1
 *   - Constantes de clase con visibilidad (private const)      -> PHP 7.1
 *
 * En su lugar:
 *   - Sin anotaciones de tipo en firmas; validacion manual donde aplica.
 *   - Argumentos posicionales en constructores.
 *   - Constantes de clase sin visibilidad (const, publicas por defecto).
 *   - El comportamiento funcional es IDENTICO al de la version moderna.
 *
 * COMPATIBILIDAD CON LA API
 * -------------------------
 * Declara los mismos simbolos que la version moderna:
 *   - class CNM_DB         (Connect, setFetchMode, query, affectedRows,
 *                           escapeSimple, lastInsertId, begin/commit/rollback,
 *                           getPDO)
 *   - class CNM_DB_Result  (fetchInto, fetchAll, getUserInfo, getCode,
 *                           getMessage, free)
 *   - class CNM_DB_Error   (getMessage, getCode, getUserInfo, toString, __toString)
 *   - function CNM_isError()
 *   - constantes DB_FETCHMODE_ASSOC / _NUM / _OBJECT
 *
 * NOTA SOBRE PDO EN PHP 5.6
 * -------------------------
 * - PDO::MYSQL_ATTR_MULTI_STATEMENTS existe desde PHP 5.3, disponible.
 * - PDO::ATTR_EMULATE_PREPARES => false puede dar problemas con algunas
 *   versiones antiguas de MySQL en queries complejas. Se mantiene false
 *   por coherencia con la version moderna; si surgieran problemas en el
 *   equipo Debian 8 concreto, cambiar a true SOLO en este fichero legacy.
 * - utf8mb4 esta soportado en el cliente MySQL de Debian 8, pero verificar
 *   que la version de MariaDB/MySQL del servidor tambien lo soporta.
 *
 * VERSION: 1.1.0 (legacy)
 * =============================================================================
 */


// =============================================================================
// CONSTANTES DE COMPATIBILIDAD (reemplazan DB_FETCHMODE_* de PEAR::DB)
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
// FUNCION GLOBAL: CNM_isError()  (reemplaza PEAR::isError / DB::isError)
// =============================================================================

/**
 * Comprueba si un valor es un error de base de datos.
 *
 * @param  mixed $value
 * @return bool
 */
function CNM_isError($value)
{
    return ($value instanceof CNM_DB_Error);
}


// =============================================================================
// CLASE: CNM_DB  (reemplaza el objeto $dbc / $enlace y la clase DB de PEAR)
// =============================================================================

class CNM_DB
{
    /** @var PDO */
    private $pdo;

    /** @var string Ultima query ejecutada */
    private $lastQuery = '';

    /** @var int Fetch mode por defecto */
    private $fetchMode = PDO::FETCH_ASSOC;

    /** @var PDOStatement|null Ultimo statement ejecutado con exito (para affectedRows) */
    private $lastStmt = null;


    /**
     * Constructor privado. Instanciar solo a traves de Connect().
     *
     * @param PDO $pdo
     */
    private function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }


    /**
     * Crea y devuelve una conexion a la base de datos.
     * Reemplaza DB::Connect().
     *
     * @param  array $params       Parametros de conexion (formato PEAR::DB)
     * @param  bool  $persistent   Si true, conexion persistente
     * @return CNM_DB|CNM_DB_Error
     */
    public static function Connect($params, $persistent = false)
    {
        try {
            $host = isset($params['hostspec']) ? $params['hostspec']
                  : (isset($params['host']) ? $params['host'] : 'localhost');
            $user = isset($params['username']) ? $params['username']
                  : (isset($params['user']) ? $params['user'] : '');
            $pass = isset($params['password']) ? $params['password']
                  : (isset($params['pass']) ? $params['pass'] : '');
            $charset = 'utf8mb4';

            // 'database' es opcional
            $dbname = '';
            if (!empty($params['database'])) {
                $dbname = ';dbname=' . $params['database'];
            }

            $dsn = 'mysql:host=' . $host . $dbname . ';charset=' . $charset;

            $options = array(
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::ATTR_PERSISTENT         => $persistent,
                PDO::MYSQL_ATTR_MULTI_STATEMENTS => true,
            );

            $pdo = new PDO($dsn, $user, $pass, $options);
            return new self($pdo);

        } catch (PDOException $e) {
            return new CNM_DB_Error(
                $e->getMessage(),
                $e->getCode(),
                'Connect failed: ' . $e->getMessage(),
                ''
            );
        }
    }


    /**
     * Establece el fetch mode por defecto.
     * Reemplaza $dbc->setFetchMode().
     *
     * @param  int $mode
     * @return void
     */
    public function setFetchMode($mode)
    {
        $this->fetchMode = $mode;
    }


    /**
     * Ejecuta una query SQL.
     * Reemplaza $dbc->query().
     *
     * @param  string $sql
     * @param  array  $params  Parametros para prepared statement (opcional)
     * @return CNM_DB_Result|CNM_DB_Error
     */
    public function query($sql, $params = array())
    {
        $this->lastQuery = $sql;

        try {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            $stmt->setFetchMode($this->fetchMode);

            // Guardar referencia para affectedRows()
            $this->lastStmt = $stmt;

            return new CNM_DB_Result($stmt, $sql, $this->fetchMode);

        } catch (PDOException $e) {
            // lastStmt NO se actualiza en caso de error (igual que PEAR::DB)
            return new CNM_DB_Error(
                $e->getMessage(),
                $e->getCode(),
                $sql . ' [nativecode=' . $e->getCode() . ' ** ' . $e->getMessage() . ']',
                $sql
            );
        }
    }


    /**
     * Numero de filas afectadas por la ultima query exitosa.
     * Reemplaza $dbc->affectedRows().
     *
     * ADVERTENCIA: rowCount() sobre SELECT no esta garantizado en todos los
     * drivers. Uso correcto solo tras INSERT/UPDATE/DELETE (asi se usa en
     * el codigo existente).
     *
     * @return int  Filas afectadas, -1 si no hay query previa
     */
    public function affectedRows()
    {
        if ($this->lastStmt === null) {
            return -1;
        }
        return $this->lastStmt->rowCount();
    }


    /**
     * Escapa una cadena SIN comillas externas.
     * Reemplaza $dbc->escapeSimple().
     *
     * DIFERENCIA con PDO::quote(): quote() anade comillas, escapeSimple() no.
     * El codigo existente anade las comillas manualmente.
     *
     * @param  mixed $value
     * @return string
     */
    public function escapeSimple($value)
    {
        if (is_null($value)) {
            return '';
        }
        if (is_int($value) || is_float($value)) {
            return (string) $value;
        }
        // PDO::quote() devuelve 'valor' - quitamos las comillas externas
        $quoted = $this->pdo->quote((string) $value);
        return substr($quoted, 1, -1);
    }


    /**
     * ID del ultimo INSERT con AUTO_INCREMENT.
     *
     * @return string
     */
    public function lastInsertId()
    {
        return $this->pdo->lastInsertId();
    }


    /** Inicia transaccion. @return void */
    public function beginTransaction()
    {
        $this->pdo->beginTransaction();
    }

    /** Confirma transaccion. @return void */
    public function commit()
    {
        $this->pdo->commit();
    }

    /** Deshace transaccion. @return void */
    public function rollback()
    {
        $this->pdo->rollBack();
    }


    /**
     * Devuelve la instancia PDO subyacente (uso excepcional).
     *
     * @return PDO
     */
    public function getPDO()
    {
        return $this->pdo;
    }
}


// =============================================================================
// CLASE: CNM_DB_Result  (reemplaza el objeto resultado de PEAR::DB)
// =============================================================================

class CNM_DB_Result
{
    /** @var PDOStatement */
    private $stmt;

    /** @var string Query que genero este resultado */
    private $lastQuery;

    /** @var int Fetch mode heredado */
    private $fetchMode;


    /**
     * @param PDOStatement $stmt
     * @param string       $lastQuery
     * @param int          $fetchMode
     */
    public function __construct(PDOStatement $stmt, $lastQuery, $fetchMode)
    {
        $this->stmt      = $stmt;
        $this->lastQuery = $lastQuery;
        $this->fetchMode = $fetchMode;
    }


    /**
     * Obtiene la siguiente fila y la almacena en $var por referencia.
     * Reemplaza $result->fetchInto($var).
     *
     * Patron de uso dominante:
     *   while ($result->fetchInto($r)) { ... }
     *
     * Devuelve bool (PEAR::DB devolvia DB_OK/DB_ERROR; bool es compatible
     * con el patron while()).
     *
     * @param  mixed &$var  Variable que recibe la fila
     * @param  int    $mode 0 = usar el fetch mode de la conexion
     * @return bool
     */
    public function fetchInto(&$var, $mode = 0)
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


    /**
     * Devuelve todas las filas como array (metodo de conveniencia).
     *
     * @param  int $mode  0 = usar el fetch mode de la conexion
     * @return array
     */
    public function fetchAll($mode = 0)
    {
        $fetchMode = ($mode !== 0) ? $mode : $this->fetchMode;
        return $this->stmt->fetchAll($fetchMode);
    }


    /**
     * Guardia defensiva. La implementacion real esta en CNM_DB_Error.
     *
     * @return string
     */
    public function getUserInfo()
    {
        return '[CNM_DB_Result::getUserInfo() llamado sobre resultado valido. Query: '
             . $this->lastQuery . ']';
    }


    /**
     * Guardia defensiva. Devuelve 0 (sin error) en un resultado valido.
     *
     * @return int|string
     */
    public function getCode()
    {
        return 0;
    }


    /**
     * Guardia defensiva. Devuelve string vacio en un resultado valido.
     *
     * @return string
     */
    public function getMessage()
    {
        return '';
    }


    /**
     * Libera el cursor.
     * Reemplaza $result->free().
     *
     * @return void
     */
    public function free()
    {
        $this->stmt->closeCursor();
    }
}


// =============================================================================
// CLASE: CNM_DB_Error  (reemplaza PEAR_Error / DB_Error)
// =============================================================================

class CNM_DB_Error
{
    /**
     * Mapa de codigos nativos MariaDB -> codigos PEAR::DB negativos.
     *
     * En PHP 5.6 las constantes de clase NO admiten visibilidad (private),
     * por lo que se declara como const publica (comportamiento por defecto).
     * La version moderna la declara como private const.
     *
     * Referencia de $a_global_sql_error en Store.php (lineas 16-44):
     *   '-2'  DB_ERROR_SYNTAX        | '-3'  DB_ERROR_CONSTRAINT
     *   '-5'  DB_ERROR_ALREADY_EXISTS| '-18' DB_ERROR_NOSUCHTABLE / CANNOT_ALTER
     *   '-19' DB_ERROR_NOSUCHFIELD   | '-24' DB_ERROR_CONNECT_FAILED
     *   '-26' DB_ERROR_ACCESS_VIOLATION | '-27' DB_ERROR_NOSUCHDB
     *   '-29' DB_ERROR_CONSTRAINT_NOT_NULL
     */
    const MARIADB_TO_PEAR = array(
        1064 => '-2',   // SQL syntax error
        1062 => '-5',   // Duplicate entry
        1451 => '-3',   // FK constraint (parent)
        1452 => '-3',   // FK constraint (child)
        1048 => '-29',  // Column cannot be null
        1146 => '-18',  // Table doesn't exist
        1054 => '-19',  // Unknown column
        1044 => '-26',  // Access denied to database
        1045 => '-26',  // Access denied (user)
        1049 => '-27',  // Unknown database
        2002 => '-24',  // Can't connect
        1060 => '-18',  // Duplicate column (ALTER)
        1061 => '-18',  // Duplicate key (ALTER)
        1091 => '-18',  // Can't DROP (ALTER)
        1101 => '-18',  // BLOB/TEXT default (ALTER)
    );

    /** Codigo PEAR::DB para errores ALTER TABLE */
    const PEAR_CANNOT_ALTER = '-18';


    /** @var string */
    private $message;

    /** @var int|string */
    private $code;

    /** @var string */
    private $userInfo;

    /** @var string */
    private $query;


    /**
     * @param string     $message
     * @param int|string $code
     * @param string     $userInfo
     * @param string     $query
     */
    public function __construct($message, $code, $userInfo = '', $query = '')
    {
        $this->message  = $message;
        $this->code     = $code;
        $this->userInfo = ($userInfo !== '') ? $userInfo : $message;
        $this->query    = $query;
    }


    /**
     * Mensaje de error del driver.
     *
     * @return string
     */
    public function getMessage()
    {
        return $this->message;
    }


    /**
     * Codigo de error mapeado al espacio PEAR::DB.
     *
     * USO CRITICO en DB-Scheme-Lib.php linea 1808:
     *   if ($resultAlterTabla->getCode() == '-18') { ... }
     *
     * @return int|string
     */
    public function getCode()
    {
        $nativeCode = (int) $this->code;

        $map = self::MARIADB_TO_PEAR;
        if (isset($map[$nativeCode])) {
            return $map[$nativeCode];
        }

        return $this->code;
    }


    /**
     * Informacion extendida del error (formato PEAR::DB).
     *
     * @return string
     */
    public function getUserInfo()
    {
        return $this->userInfo;
    }


    /**
     * Representacion string del error.
     *
     * @return string
     */
    public function toString()
    {
        return '[CNM_DB Error: ' . $this->code . '] ' . $this->message;
    }


    /**
     * @return string
     */
    public function __toString()
    {
        return $this->toString();
    }
}
