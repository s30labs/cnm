<?php
include_once( "./class.TemplatePower.inc.php" );

$tpl = new TemplatePower( "../thtml/test.thtml" );
$tpl->prepare();

$tpl->assign( "name", "Ron" );

$tpl->printToScreen();
?>
