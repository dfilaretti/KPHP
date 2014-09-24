--TEST--
Trying to reference assing on a function which returns a value
--FILE--
<?php
	function foo () {
		return 123;
	}
	$x =& foo();
	var_dump($x);	
?>
--EXPECTF--
Warning: Only variables should be assigned by reference in %s on line %d
int(123)