--TEST--
strlen
--FILE--
<?php
	$x = "hello";
	var_dump(strlen($x));
	$x = 12345;
	var_dump(strlen($x));
?>
--EXPECT--
int(5)
int(5)
