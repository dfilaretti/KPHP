--TEST--
when casting object to array and the current of the object was 'false', 
the created array is reset (i.e. current set to 1st element). 
The current of the object remains false.
--FILE--
<?php
	$a -> a = 1; $a -> b = 2;
	next($a); next($a);
	$b = (array) $a;
	var_dump(current($a)); 	 
	echo current($b) . "\n";
?>
--EXPECT--
bool(false)
1
