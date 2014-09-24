--TEST--
toString
--FILE--
<?php
	var_dump((string) array(1,2,3));
	var_dump((string) 7.5);
?>
--EXPECT--
string(5) "Array"
string(3) "7.5"

