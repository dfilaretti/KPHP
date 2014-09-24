--TEST--
lget, error case (accessing a scalar as an array)
--FILE--
<?php
	$x = 0;
	$x[3] = 1;
	var_dump($x);
	var_dump($x[3]);
?>
--EXPECT--
Warning: Cannot use a scalar value as an array in %s on line %d
int(0)
NULL