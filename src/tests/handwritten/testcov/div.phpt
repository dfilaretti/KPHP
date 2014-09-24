--TEST--
Division of two ints is always performed as float division, but floats results
with decimal part equals to 0 (e.g. 5.0) are casted back to int. 
Instead, division between floats always returns a float.

Note that vardump should print floats as int when they have decimal parts 
of all 0s (but the type is still float).
--FILE--
<?php
	$n = 3;
	$d = 2;
	var_dump($n / $d);	// 1.5 (float)
	$n = 4;
	$d = 2;
	$d /= 2;
	var_dump($n / $d); // 4 (int)
	$n = 4.0;
	$d = 1.0;
	var_dump($n / $d); // 4 (float)
	$n = 4;
	$d = 1.0;
	var_dump($n / $d); // 4 (float)
?>
--EXPECT--
float(1.5)
int(4)
float(4)
float(4)