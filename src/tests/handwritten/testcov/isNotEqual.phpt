--TEST--
isNotEqual
--FILE--
<?php
	var_dump(3 != 3);
	var_dump(3 != 0);
?>
--EXPECT--
bool(false)
bool(true)
