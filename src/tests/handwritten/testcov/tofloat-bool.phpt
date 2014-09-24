--TEST--
converting booleans to string
--FILE--
<?php
	var_dump((float) true);
	var_dump((float) false);
?>
--EXPECT--
float(1)
float(0)
