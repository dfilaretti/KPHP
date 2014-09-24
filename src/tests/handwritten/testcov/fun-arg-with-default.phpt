--TEST--
default values for function parameters
--FILE--
<?php
	function foo($x = 0, $y = 0) {
		return $x + $y;
	}
	
	$x = 3;
	$y = 2;
	echo foo($x, $y);
?>
--EXPECT--
5