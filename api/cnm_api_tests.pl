#!/usr/bin/perl
#==============================================================================
# cnm_api_tests.pl - Bateria de tests para el API REST de CNM
#==============================================================================
#
# PROPOSITO
#   Validar el API REST de CNM tras la migracion a Debian 13 / PHP 8.
#   Comprueba autenticacion, endpoints GET/POST/PUT, filtrado, paginacion,
#   manejo de errores y casos limite que suelen romper en el salto PHP 7->8.
#
# POR QUE ESTA SUITE
#   Tras migrar PEAR::DB -> PDO y arrancar en PHP 8, los fallos tipicos no son
#   de conexion sino de:
#     - contrato de callbacks de sesion (sessionid vacio, "Failed to decode")
#     - count(null) / Undefined en rutas concretas (fatal 500)
#     - formato de respuesta alterado
#   Esta bateria ejercita las rutas reales para cazar esos fatales de forma
#   sistematica, en vez de descubrirlos en produccion.
#
# DEPENDENCIAS
#   - perl 5.14+ (usa JSON::PP del core, NO requiere instalar JSON)
#   - curl en el PATH (igual que los ejemplos de la documentacion oficial)
#   No requiere LWP ni modulos CPAN: pensado para correr en el propio appliance.
#
# USO
#   ./cnm_api_tests.pl [opciones]
#
#   Opciones:
#     --host HOST     Host del API           (def: localhost)
#     --user USER     Usuario                (def: admin)
#     --pass PASS     Clave                  (def: cnm123)
#     --base PATH     Base del API           (def: /onm/api/1.0)
#     --insecure      Acepta certificados SSL autofirmados (curl -k)  [def: on]
#     --verbose       Muestra peticion/respuesta completas
#     --no-write      Omite tests destructivos (POST/PUT) - solo lectura
#     --keep          No borra los dispositivos de prueba creados
#     --help          Muestra esta ayuda
#
#   Ejemplos:
#     ./cnm_api_tests.pl
#     ./cnm_api_tests.pl --host 10.2.254.222 --pass miclave --verbose
#     ./cnm_api_tests.pl --no-write          # solo lectura, no modifica nada
#
# CODIGO DE SALIDA
#   0  todos los tests pasaron
#   1  algun test fallo
#   2  error de configuracion / no se pudo autenticar
#==============================================================================

use strict;
use warnings;
use JSON::PP;
use Getopt::Long;

#------------------------------------------------------------------------------
# Configuracion por defecto (sobreescribible por linea de comandos)
#------------------------------------------------------------------------------
my %cfg = (
    host     => 'localhost',
    user     => 'admin',
    pass     => 'cnm123',
    base     => '/onm/api/1.0',
    insecure => 1,
    verbose  => 0,
    no_write => 0,
    keep     => 0,
);

GetOptions(
    'host=s'    => \$cfg{host},
    'user=s'    => \$cfg{user},
    'pass=s'    => \$cfg{pass},
    'base=s'    => \$cfg{base},
    'insecure!' => \$cfg{insecure},
    'verbose!'  => \$cfg{verbose},
    'no-write!' => \$cfg{no_write},
    'keep!'     => \$cfg{keep},
    'help'      => sub { usage(); exit 0; },
) or do { usage(); exit 2; };

#------------------------------------------------------------------------------
# Estado global de la suite
#------------------------------------------------------------------------------
my $TOKEN;                 # token de sesion obtenido en auth
my @CREATED_DEVICES;       # ids de dispositivos creados (para limpieza)
my %STATS = (pass => 0, fail => 0, skip => 0);
my @FAILURES;              # detalle de fallos para el resumen final

#==============================================================================
# UTILIDADES DE BAJO NIVEL
#==============================================================================

# Construye la URL completa del endpoint
sub url {
    my ($endpoint) = @_;
    return "https://$cfg{host}$cfg{base}/$endpoint";
}

# Ejecuta una peticion curl y devuelve (http_code, body)
#   $method : GET | POST | PUT | DELETE
#   $endpoint: ruta relativa, ej: 'devices.json'
#   %opts   : auth => bool (incluir token), form => [..], data => [..], raw_auth => str
sub http_request {
    my ($method, $endpoint, %opts) = @_;

    my @cmd = ('curl', '-s', '-i');     # -s silencioso, -i incluye cabeceras
    push @cmd, '-k' if $cfg{insecure};  # acepta SSL autofirmado
    push @cmd, ('-X', $method);

    # Cabecera de autenticacion
    if ($opts{auth}) {
        my $tok = defined $opts{raw_auth} ? $opts{raw_auth} : $TOKEN;
        push @cmd, ('-H', "Authorization: $tok") if defined $tok;
    }

    # Parametros -F (multipart, usado en POST /devices segun doc)
    if ($opts{form}) {
        push @cmd, ('-F', $_) for @{$opts{form}};
    }
    # Parametros -d (urlencoded, usado en PUT segun doc)
    if ($opts{data}) {
        push @cmd, ('-d', $_) for @{$opts{data}};
    }

    push @cmd, url($endpoint);

    if ($cfg{verbose}) {
        print "    >> ", join(' ', map { /\s/ ? "'$_'" : $_ } @cmd), "\n";
    }

    # Ejecutar de forma segura (lista, no shell) para evitar inyeccion de shell
    my $raw = capture_cmd(@cmd);

    # Separar cabeceras del cuerpo. curl -i puede emitir varios bloques de
    # cabeceras (100 Continue, redirecciones); nos quedamos con el ultimo body.
    my ($code, $body) = parse_http_response($raw);

    if ($cfg{verbose}) {
        print "    << HTTP $code\n";
        my $preview = length($body) > 300 ? substr($body,0,300)."...[truncado]" : $body;
        print "    << $preview\n";
    }

    return ($code, $body);
}

# Ejecuta un comando como lista y captura stdout (sin pasar por shell)
sub capture_cmd {
    my @cmd = @_;
    my $pid = open(my $fh, '-|');
    die "No se pudo hacer fork: $!" unless defined $pid;
    if ($pid == 0) {
        # hijo
        open(STDERR, '>', '/dev/null');
        exec { $cmd[0] } @cmd or exit 127;
    }
    local $/;
    my $out = <$fh>;
    close($fh);
    return defined $out ? $out : '';
}

# Parsea la respuesta cruda de curl -i en (codigo_http, cuerpo)
sub parse_http_response {
    my ($raw) = @_;
    # Normalizar saltos de linea
    $raw =~ s/\r\n/\n/g;

    my $code = 0;
    my $body = $raw;

    # Puede haber varios bloques cabecera\n\n cuerpo. Recorremos todos los
    # status lines y nos quedamos con el ultimo, y con el cuerpo tras la
    # ultima cabecera en blanco.
    while ($raw =~ /^HTTP\/\d\.\d\s+(\d{3})/mg) {
        $code = $1;
    }
    # El cuerpo es lo que va tras la ultima linea en blanco que separa
    # cabeceras de cuerpo.
    if ($raw =~ /\n\n(.*)\z/s) {
        $body = $1;
    }
    # Limpiar posible bloque de cabeceras residual de un 100 Continue
    $body =~ s/^HTTP\/\d\.\d.*?\n\n//s if $body =~ /^HTTP\//;

    $body =~ s/^\s+//;
    $body =~ s/\s+\z//;
    return ($code, $body);
}

# Intenta decodificar JSON. Devuelve (ok, estructura_o_error)
sub try_json {
    my ($body) = @_;
    my $data = eval { JSON::PP->new->utf8->decode($body) };
    if ($@) {
        return (0, "JSON invalido: $@");
    }
    return (1, $data);
}

#==============================================================================
# FRAMEWORK DE ASSERTS
#==============================================================================

my $CURRENT_GROUP = '';

sub group {
    my ($name) = @_;
    $CURRENT_GROUP = $name;
    print "\n", '=' x 70, "\n";
    print "  $name\n";
    print '=' x 70, "\n";
}

# Registra el resultado de un test
sub result {
    my ($ok, $name, $detail) = @_;
    if ($ok) {
        $STATS{pass}++;
        printf "  [ OK ] %s\n", $name;
    } else {
        $STATS{fail}++;
        printf "  [FAIL] %s\n", $name;
        printf "         -> %s\n", $detail if defined $detail && $detail ne '';
        push @FAILURES, "[$CURRENT_GROUP] $name :: " . (defined $detail ? $detail : '');
    }
    return $ok;
}

sub skip {
    my ($name, $reason) = @_;
    $STATS{skip}++;
    printf "  [SKIP] %s (%s)\n", $name, $reason;
}

# Asserts concretos -----------------------------------------------------------

sub assert_http {
    my ($code, $expected, $name) = @_;
    return result($code == $expected, $name,
                  "esperado HTTP $expected, recibido HTTP $code");
}

sub assert_http_in {
    my ($code, $expected_aref, $name) = @_;
    my $ok = grep { $_ == $code } @$expected_aref;
    return result($ok, $name,
                  "esperado HTTP [".join('/',@$expected_aref)."], recibido $code");
}

sub assert_json {
    my ($body, $name) = @_;
    my ($ok, $data) = try_json($body);
    result($ok, $name, $ok ? '' : $data);
    return $ok ? $data : undef;
}

sub assert_no_php_error {
    my ($body, $name) = @_;
    # Detecta fugas de errores/warnings de PHP en el cuerpo de la respuesta,
    # que es exactamente lo que aparece con los fallos PHP 8 (count(null),
    # Undefined, TypeError, "Failed to decode session object", etc.)
    my @patterns = (
        qr/Fatal error/i,
        qr/Parse error/i,
        qr/Uncaught\s+\w*Error/i,
        qr/TypeError/i,
        qr/Undefined (variable|array key|index)/i,
        qr/Failed to decode session object/i,
        qr/count\(\):/i,
        qr/Trying to access array offset/i,
        qr/PEAR/i,
        qr/Call to undefined function/i,
        qr/on line \d+/i,
    );
    for my $p (@patterns) {
        if ($body =~ $p) {
            (my $snippet = $body) =~ s/\s+/ /g;
            $snippet = substr($snippet, 0, 200);
            return result(0, $name, "fuga de error PHP detectada: $snippet");
        }
    }
    return result(1, $name);
}

#==============================================================================
# GRUPOS DE TESTS
#==============================================================================

#------------------------------------------------------------------------------
# AUTENTICACION
#------------------------------------------------------------------------------
sub test_auth {
    group('AUTH /auth/token.json');

    # 1. Login correcto
    my ($code, $body) = http_request('GET',
        "auth/token.json?u=$cfg{user}&p=$cfg{pass}");
    assert_http($code, 200, 'login devuelve HTTP 200');
    assert_no_php_error($body, 'login sin fugas de error PHP');
    my $data = assert_json($body, 'login devuelve JSON valido');

    if ($data) {
        result(defined $data->{status} && $data->{status} == 0,
               'status == 0 en login correcto',
               'status='.(defined $data->{status}?$data->{status}:'undef'));
        # Este es el test que destapaba el bug de mysql_session_select:
        # sessionid vacio = contrato de callback read roto.
        my $sid = $data->{sessionid} // '';
        result($sid ne '',
               'sessionid NO vacio (regresion contrato callback read)',
               "sessionid='$sid' (vacio indica fallo en mysql_session_select/session_start)");
        $TOKEN = $sid if $sid ne '';
    }

    # 2. Login con credenciales incorrectas -> NO debe autenticar
    my ($code2, $body2) = http_request('GET',
        "auth/token.json?u=$cfg{user}&p=clave_incorrecta_xyz");
    assert_no_php_error($body2, 'login fallido sin fugas de error PHP');
    my ($okj, $d2) = try_json($body2);
    if ($okj && ref $d2 eq 'HASH') {
        # status distinto de 0, o codigo HTTP de error
        my $denied = (defined $d2->{status} && $d2->{status} != 0)
                     || ($code2 != 200)
                     || (defined $d2->{success} && !$d2->{success});
        result($denied, 'credenciales incorrectas son rechazadas',
               "code=$code2 status=".(defined $d2->{status}?$d2->{status}:'-'));
    } else {
        # Tambien valido: devolver un error HTTP 400/401
        assert_http_in($code2, [400,401,403], 'credenciales incorrectas dan error HTTP');
    }

    # 3. Falta de parametros obligatorios
    my ($code3, $body3) = http_request('GET', "auth/token.json");
    assert_no_php_error($body3, 'auth sin parametros sin fugas de error PHP');
    assert_http_in($code3, [400,401], 'auth sin usuario/clave da HTTP 400/401');
}

#------------------------------------------------------------------------------
# ACCESO SIN TOKEN / TOKEN INVALIDO
#------------------------------------------------------------------------------
sub test_auth_required {
    group('AUTH requerido en endpoints protegidos');

    # Peticion a devices SIN token
    my ($code, $body) = http_request('GET', 'devices.json', auth => 0);
    assert_no_php_error($body, 'devices sin token sin fugas de error PHP');
    assert_http_in($code, [401,403], 'devices sin token da HTTP 401/403');

    # Peticion con token invalido
    my ($code2, $body2) = http_request('GET', 'devices.json',
        auth => 1, raw_auth => 'token_invalido_0000000000000000');
    assert_no_php_error($body2, 'devices con token invalido sin fugas de error PHP');
    assert_http_in($code2, [401,403], 'devices con token invalido da HTTP 401/403');
}

#------------------------------------------------------------------------------
# GET /devices (lectura, filtrado, paginacion)
#------------------------------------------------------------------------------
sub test_get_devices {
    group('GET /devices');

    unless ($TOKEN) { skip('GET /devices', 'sin token'); return; }

    # 1. Lista completa
    my ($code, $body) = http_request('GET', 'devices.json', auth => 1);
    assert_http($code, 200, 'lista de dispositivos HTTP 200');
    assert_no_php_error($body, 'lista de dispositivos sin fugas de error PHP');
    my $data = assert_json($body, 'lista de dispositivos es JSON valido');
    result(ref $data eq 'ARRAY', 'lista de dispositivos es un array JSON',
           'tipo='.(ref $data || 'escalar'));

    # Guardar un id real para tests de detalle
    my $sample_id;
    if (ref $data eq 'ARRAY' && @$data) {
        $sample_id = $data->[0]{id};
    }

    # 2. Filtrado por campos (cnm_fields) y orden (cnm_sort)
    my ($code2, $body2) = http_request('GET',
        'devices.json?cnm_fields=id,ip,name&cnm_sort=-id&cnm_page_size=5',
        auth => 1);
    assert_http($code2, 200, 'devices con cnm_fields/cnm_sort HTTP 200');
    assert_no_php_error($body2, 'devices filtrado sin fugas de error PHP');
    my $data2 = assert_json($body2, 'devices filtrado es JSON valido');
    if (ref $data2 eq 'ARRAY' && @$data2) {
        my $first = $data2->[0];
        # Solo deberian venir los campos pedidos
        result((exists $first->{id} && exists $first->{ip} && exists $first->{name}),
               'cnm_fields devuelve los campos solicitados',
               'campos: '.join(',', sort keys %$first));
        # Paginacion: no mas de 5
        result(scalar(@$data2) <= 5, 'cnm_page_size limita el numero de resultados',
               'recibidos '.scalar(@$data2));
    }

    # 3. Detalle por id (si hay alguno)
    if (defined $sample_id) {
        my ($code3, $body3) = http_request('GET', "devices/$sample_id.json", auth => 1);
        assert_http($code3, 200, "detalle de dispositivo id=$sample_id HTTP 200");
        assert_no_php_error($body3, 'detalle de dispositivo sin fugas de error PHP');
        assert_json($body3, 'detalle de dispositivo es JSON valido');
    } else {
        skip('detalle de dispositivo por id', 'no hay dispositivos');
    }

    # 4. Filtro que no devuelve resultados (no debe ser error)
    my ($code4, $body4) = http_request('GET',
        'devices.json?ip=255.255.255.255', auth => 1);
    assert_http($code4, 200, 'filtro sin coincidencias HTTP 200 (no error)');
    assert_no_php_error($body4, 'filtro sin coincidencias sin fugas de error PHP');
    my $data4 = assert_json($body4, 'filtro sin coincidencias es JSON valido');
    result(ref $data4 eq 'ARRAY', 'filtro sin coincidencias devuelve array (vacio)',
           'tipo='.(ref $data4 || 'escalar'));
}

#------------------------------------------------------------------------------
# GET /metrics/info y /metrics/data
#------------------------------------------------------------------------------
sub test_get_metrics {
    group('GET /metrics');

    unless ($TOKEN) { skip('GET /metrics', 'sin token'); return; }

    # metrics/info
    my ($code, $body) = http_request('GET', 'metrics/info.json?cnm_page_size=5', auth => 1);
    assert_http($code, 200, 'metrics/info HTTP 200');
    assert_no_php_error($body, 'metrics/info sin fugas de error PHP');
    my $data = assert_json($body, 'metrics/info es JSON valido');
    result(ref $data eq 'ARRAY', 'metrics/info devuelve array',
           'tipo='.(ref $data || 'escalar'));

    # Si hay metricas, probar metrics/data sobre la primera
    if (ref $data eq 'ARRAY' && @$data && defined $data->[0]{metricid}) {
        my $mid = $data->[0]{metricid};
        my ($code2, $body2) = http_request('GET', "metrics/data.json?metricid=$mid", auth => 1);
        assert_http_in($code2, [200], "metrics/data metricid=$mid HTTP 200");
        assert_no_php_error($body2, 'metrics/data sin fugas de error PHP');
        assert_json($body2, 'metrics/data es JSON valido');
    } else {
        skip('metrics/data', 'no hay metricas para consultar');
    }
}

#------------------------------------------------------------------------------
# GET endpoints de solo lectura: alerts, views, tickets, users
#------------------------------------------------------------------------------
sub test_get_readonly {
    group('GET endpoints de lectura (alerts, views, tickets, users)');

    unless ($TOKEN) { skip('GET lectura', 'sin token'); return; }

    for my $ep (qw(alerts views tickets users)) {
        my ($code, $body) = http_request('GET', "$ep.json", auth => 1);
        assert_http_in($code, [200], "GET /$ep HTTP 200");
        assert_no_php_error($body, "GET /$ep sin fugas de error PHP");
        my $data = assert_json($body, "GET /$ep es JSON valido");
        # La mayoria devuelven array; algunos podrian devolver hash. Aceptamos ambos
        # pero verificamos que sea estructura, no escalar.
        result(ref $data eq 'ARRAY' || ref $data eq 'HASH',
               "GET /$ep devuelve estructura JSON",
               'tipo='.(ref $data || 'escalar'));
    }
}

#------------------------------------------------------------------------------
# POST /devices + PUT /devices (escritura) - solo si no --no-write
#------------------------------------------------------------------------------
sub test_write_devices {
    group('POST/PUT /devices (escritura)');

    if ($cfg{no_write}) { skip('escritura de dispositivos', '--no-write activo'); return; }
    unless ($TOKEN) { skip('escritura de dispositivos', 'sin token'); return; }

    # Nombre/ip unicos para no colisionar con datos reales
    my $suffix = sprintf('%d_%d', time(), $$);
    my $name   = "apitest_$suffix";
    my $ip     = '10.250.250.' . (($$ % 250) + 1);

    # 1. POST: crear dispositivo
    my ($code, $body) = http_request('POST', 'devices.json',
        auth => 1,
        form => [
            "name=$name",
            "domain=apitest.local",
            "ip=$ip",
            "type=apitest",
            "snmpversion=0",
            "critic=25",
        ],
    );
    assert_http($code, 200, 'POST /devices HTTP 200');
    assert_no_php_error($body, 'POST /devices sin fugas de error PHP');
    my $data = assert_json($body, 'POST /devices es JSON valido');

    my $new_id;
    if (ref $data eq 'HASH') {
        # Formato documentado: {"rc":0,"rcstr":"","id":"N"}
        result(exists $data->{rc}, 'POST /devices devuelve campo rc',
               'claves: '.join(',', sort keys %$data));
        result((defined $data->{rc} && $data->{rc} == 0),
               'POST /devices rc == 0 (creacion correcta)',
               'rc='.(defined $data->{rc}?$data->{rc}:'undef').
               ' rcstr='.(defined $data->{rcstr}?$data->{rcstr}:''));
        if (defined $data->{id} && $data->{id} ne '') {
            $new_id = $data->{id};
            push @CREATED_DEVICES, $new_id;
            result(1, "POST /devices devuelve id del nuevo dispositivo (id=$new_id)");
        } else {
            result(0, 'POST /devices devuelve id del nuevo dispositivo', 'sin id en respuesta');
        }
    }

    # 2. Verificar que el dispositivo existe (GET por id)
    if (defined $new_id) {
        my ($cg, $bg) = http_request('GET', "devices/$new_id.json", auth => 1);
        assert_http($cg, 200, "GET del dispositivo creado id=$new_id HTTP 200");
        assert_no_php_error($bg, 'GET dispositivo creado sin fugas de error PHP');
        my $dg = assert_json($bg, 'GET dispositivo creado es JSON valido');
        if (ref $dg eq 'ARRAY' && @$dg) {
            result($dg->[0]{name} eq $name,
                   'el dispositivo creado tiene el nombre correcto',
                   "esperado '$name', recibido '".($dg->[0]{name}//'')."'");
        }

        # 3. PUT: modificar la criticidad del dispositivo
        my ($cp, $bp) = http_request('PUT', "devices/$new_id.json",
            auth => 1,
            data => [ "critic=100" ],
        );
        assert_http($cp, 200, "PUT /devices id=$new_id HTTP 200");
        assert_no_php_error($bp, 'PUT /devices sin fugas de error PHP');
        my $dp = assert_json($bp, 'PUT /devices es JSON valido');
        if (ref $dp eq 'HASH') {
            result((defined $dp->{rc} && $dp->{rc} == 0),
                   'PUT /devices rc == 0 (modificacion correcta)',
                   'rc='.(defined $dp->{rc}?$dp->{rc}:'undef'));
        }

        # 4. Verificar que la modificacion se aplico
        my ($cv, $bv) = http_request('GET', "devices/$new_id.json", auth => 1);
        my $dv = assert_json($bv, 'GET tras PUT es JSON valido');
        if (ref $dv eq 'ARRAY' && @$dv) {
            result($dv->[0]{critic} eq '100',
                   'la modificacion (critic=100) se aplico correctamente',
                   "critic='".($dv->[0]{critic}//'')."'");
        }
    } else {
        skip('verificacion/PUT del dispositivo', 'no se obtuvo id en POST');
    }
}

#------------------------------------------------------------------------------
# POST /events (escritura no destructiva de un evento)
#------------------------------------------------------------------------------
sub test_post_events {
    group('POST /events');

    if ($cfg{no_write}) { skip('POST /events', '--no-write activo'); return; }
    unless ($TOKEN) { skip('POST /events', 'sin token'); return; }

    # Un evento de prueba. El formato exacto depende de la version; se
    # comprueba sobre todo que NO haya fuga de error PHP y que el codigo
    # HTTP sea de la familia esperada.
    my ($code, $body) = http_request('POST', 'events.json',
        auth => 1,
        form => [
            "device=apitest.local",
            "subject=apitest_event",
            "message=evento de prueba de la bateria de tests",
            "severity=4",
        ],
    );
    assert_no_php_error($body, 'POST /events sin fugas de error PHP');
    assert_http_in($code, [200,400], 'POST /events responde HTTP 200/400 (no 500)');
    # Si es 200, debe ser JSON con rc
    if ($code == 200) {
        my $data = assert_json($body, 'POST /events es JSON valido');
        result((ref $data eq 'HASH' && exists $data->{rc}),
               'POST /events devuelve estructura con rc',
               'respuesta inesperada');
    }
}

#------------------------------------------------------------------------------
# Limpieza: borrar los dispositivos de prueba creados
#------------------------------------------------------------------------------
sub cleanup {
    return if $cfg{keep};
    return unless @CREATED_DEVICES;

    group('LIMPIEZA (borrado de dispositivos de prueba)');

    # NOTA: la documentacion indica que DELETE no esta soportado todavia
    # (solo GET/POST/PUT). Si DELETE no existe, este bloque lo reportara
    # como SKIP en vez de fallo, y se avisa para limpieza manual.
    for my $id (@CREATED_DEVICES) {
        my ($code, $body) = http_request('DELETE', "devices/$id.json", auth => 1);
        if ($code == 200) {
            result(1, "dispositivo de prueba id=$id borrado");
        } elsif ($code == 405 || $code == 501 || $code == 400) {
            skip("borrado de dispositivo id=$id",
                 "DELETE no soportado por el API (HTTP $code) - BORRAR MANUALMENTE");
        } else {
            result(0, "borrado de dispositivo id=$id", "HTTP $code");
        }
    }

    if (@CREATED_DEVICES && $cfg{no_write} == 0) {
        print "\n  AVISO: dispositivos de prueba creados (ids): ",
              join(', ', @CREATED_DEVICES), "\n";
        print "  Si DELETE no esta soportado, eliminarlos manualmente desde la GUI.\n";
    }
}

#==============================================================================
# RESUMEN Y AYUDA
#==============================================================================
sub summary {
    print "\n", '#' x 70, "\n";
    print "# RESUMEN\n";
    print '#' x 70, "\n";
    printf "  PASS: %d\n", $STATS{pass};
    printf "  FAIL: %d\n", $STATS{fail};
    printf "  SKIP: %d\n", $STATS{skip};

    if (@FAILURES) {
        print "\n  Detalle de fallos:\n";
        print "    - $_\n" for @FAILURES;
    }
    print "\n";
    return $STATS{fail} == 0 ? 0 : 1;
}

sub usage {
    print <<"END";
cnm_api_tests.pl - Bateria de tests para el API REST de CNM

USO:
  \$0 [opciones]

OPCIONES:
  --host HOST     Host del API           (def: $cfg{host})
  --user USER     Usuario                (def: $cfg{user})
  --pass PASS     Clave                  (def: $cfg{pass})
  --base PATH     Base del API           (def: $cfg{base})
  --insecure      Acepta SSL autofirmado (def: activado)
  --no-insecure   Exige SSL valido
  --verbose       Muestra peticiones y respuestas
  --no-write      Solo lectura (omite POST/PUT)
  --keep          No borra los dispositivos de prueba creados
  --help          Esta ayuda

EJEMPLOS:
  \$0
  \$0 --host 10.2.254.222 --pass miclave --verbose
  \$0 --no-write
END
}

#==============================================================================
# MAIN
#==============================================================================
sub main {
    print "#" x 70, "\n";
    print "# CNM API - Bateria de tests\n";
    print "# Host: https://$cfg{host}$cfg{base}\n";
    print "# Usuario: $cfg{user}\n";
    print "# Modo: ", ($cfg{no_write} ? 'SOLO LECTURA' : 'lectura + escritura'), "\n";
    print "#" x 70, "\n";

    # Comprobar que curl existe
    my $curl_check = capture_cmd('curl', '--version');
    unless ($curl_check =~ /curl/) {
        print "ERROR: curl no esta disponible en el PATH. Abortando.\n";
        return 2;
    }

    test_auth();

    unless ($TOKEN) {
        print "\nERROR: no se pudo obtener token de autenticacion.\n";
        print "Revisar credenciales, conectividad y el log de Apache.\n";
        summary();
        return 2;
    }

    test_auth_required();
    test_get_devices();
    test_get_metrics();
    test_get_readonly();
    test_write_devices();
    test_post_events();
    cleanup();

    return summary();
}

exit main();
