--TEST--
this might be a zend bug.
--FILE--
<?php
	$x = array(0);
	// let the current overflow
	next($x); 	
	// $x is not really copied, but a reference assign is made
	$y = $x;	
	// now a copy(-on-write) is made. $y is reset (since it is the one named in the instruction)
	$x[0] = 123;
	// ...
	echo "x: " . current($x) . "\n";	
	echo "y: " . current($y) . "\n";
?>
--EXPECT--
