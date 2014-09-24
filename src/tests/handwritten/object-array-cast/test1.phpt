--TEST--
when casting array to object, current is preserved (if was not false)
--FILE--
<?php
	$a = array(1, 2);
	next($a);
	$b = (object) $a;
	echo current($b) . "\n";
?>
--EXPECT--
2
