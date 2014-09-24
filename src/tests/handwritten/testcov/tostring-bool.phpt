--TEST--
converting booleans to string
--FILE--
<?php
	var_dump((string) true);
	var_dump((string) false);
?>
--EXPECT--
string(1) "1"
string(0) ""
