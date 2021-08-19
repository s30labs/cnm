<?php
$text="'CCGRFASS'IP01'";
print "$text\n";
$text1 = preg_replace('/^(\'(.*)\'|"(.*)")$/', '$2$3', $text);
print "$text1\n";
?>
