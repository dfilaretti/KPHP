--TEST--
xor
--FILE--
<?php
	var_dump(false xor false);
	var_dump(false xor true);
	var_dump(true xor false);
	var_dump(true xor true);
	$y = true;
	$x = false;
	$x ^= $y;
	var_dump($x);
?>
--EXPECT--
bool(false)
bool(true)
bool(true)
bool(false)
int(1)
