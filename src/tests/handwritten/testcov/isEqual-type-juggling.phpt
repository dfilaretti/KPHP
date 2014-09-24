--TEST--
Exercising some type juggling rules
--FILE--
<?php
	var_dump($x == "test");
	var_dump("test" == $x);	
	
	var_dump(true == "asd");	
	var_dump("asd" == true);	
	
	
?>
--EXPECT--