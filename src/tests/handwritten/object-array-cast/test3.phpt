--TEST--
when casting array to object and the current of the array was 'false', 
the created object is reset (i.e. current set to 1st element). 
The current of the arrays remains false.
--FILE--
<?php
	$a = array(1, 2);
	next($a); next($a);
	$b = (object) $a;
	var_dump(current($a)); 	 
	echo current($b) . "\n";
?>
--EXPECT--
bool(false)
1
