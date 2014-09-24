--TEST--
this might be a zend bug.
--FILE--
<?php
	$x = array(0);
	next($x); 	
	//$z = & $x;
	$y = $x;	
	
	//unset($z);
	
	echo "x: " . current($x) . "\n";	
	echo "y: " . current($y) . "\n";
	
?>
--EXPECT--
