--TEST--
count
--FILE--
<?php
	$x[] = 0;
	$y -> foo = "bar";
	var_dump(count($x));
	var_dump(count($y));
	var_dump(count(0));
?>
--EXPECT--
int(1)
int(1)
int(1)
