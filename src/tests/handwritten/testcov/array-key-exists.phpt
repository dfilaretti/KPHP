--TEST--
array_key_exists
--FILE--
<?php
	$x -> a = 0; $x -> b = 1;
	var_dump(array_key_exists(a, $x));
	$x = array(1, 2, 3);
	var_dump(array_key_exists(3, $x));
	
?>
--EXPECT--
bool(true)
bool(false)
