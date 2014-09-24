--TEST--
define and defined
--FILE--
<?php
	define(c, 2);
	define(c, 4);
	var_dump(c);
	var_dump(defined("c"));
	var_dump(defined("d"));
?>
--EXPECT--
int(2)
bool(true)
bool(false)
