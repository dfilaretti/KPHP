--TEST--
this might be a zend bug.
--FILE--
<?php
	$x = array(0);
	// let the current overflow
	next($x); 	
	// the aliasing here...	
	//$z = &$x;
	// ... forces this assignment to be executed istantly (no copy-on-write)
	$y = $x;	
	// $y was reset, but not $x, which makes sense,
	echo "y: " . current($y) . "\n";
	echo "x: " . current($x) . "\n";	
?>
--EXPECT--
