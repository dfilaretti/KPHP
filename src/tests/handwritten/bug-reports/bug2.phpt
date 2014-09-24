--TEST--
'current($x)' is evaluated only once, and returns the same value when 
called again.
--FILE--
<?php

	$x = array(1, 2, 3);
	//$ref =& $x; // decommenting this line makes it work fine
	foreach ($x as $v) {
		if ($v >= $x[1])
		echo current($x);
	} // prints 33
?>
--EXPECT--
3