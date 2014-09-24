--TEST--
substr
--FILE--
<?php
	$string = "hello";
	$start = 1;
	$len = 2;
	echo substr($string, $start, $len) . "\n";
?>
--EXPECT--
el

