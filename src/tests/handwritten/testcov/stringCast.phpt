--TEST--
stringCast
--FILE--
<?php
	var_dump((string) 123);
	var_dump((string) array(1));	
	var_dump((string) true);	
	var_dump((string) false);	
?>
--EXPECT--