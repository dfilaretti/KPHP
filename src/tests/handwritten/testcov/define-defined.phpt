--TEST--
define and defined
--FILE--
<?php
	define(c, "c");
	define(c, 4);
	var_dump(c);
	var_dump(defined("c"));
	var_dump(defined("d"));
?>
--EXPECT--
string(1) "c"
bool(true)
bool(false)