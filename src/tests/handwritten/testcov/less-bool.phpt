--TEST--
testing ">" on booleans
--FILE--
<?php
	var_dump(false < false);
	var_dump(false < true);
	var_dump(true  < false);
	var_dump(true  < true);
?>
--EXPECT--
bool(false)
bool(true)
bool(false)
bool(false)
