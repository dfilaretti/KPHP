--TEST--
'current($x)' is evaluated only once, and returns the same value when 
called again.
--FILE--
<?php
	$x = array(1, 2, 3);
	//$ref =& $x; // decommenting this line makes it work fine
	foreach ($x as $v) {
		echo current($x);
	} // prints 222
?>
--EXPECT--
23