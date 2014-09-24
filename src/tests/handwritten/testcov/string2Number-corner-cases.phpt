--TEST--
corner cases of internal function string2Number
--FILE--
<?php
	var_dump((int) "");
	var_dump((int) "a");
?>
--EXPECT--
int(0)
int(0)
