--TEST--
asdf
--FILE--
<?php
	$x = 0;
	var_dump((string)$x);
?>
--EXPECT--
string(1) "0"
