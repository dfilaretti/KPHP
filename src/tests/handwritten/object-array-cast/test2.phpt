--TEST--
when casting object to array, current is preserved (if was not false)
--FILE--
<?php	
	unset($a);
	$a -> a = 1; $a -> b = 2;
	next($a); 
	$b = (array) $a;
	echo current($b) . "\n";
?>
--EXPECT--
2
