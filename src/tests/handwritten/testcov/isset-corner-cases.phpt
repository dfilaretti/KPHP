--TEST--
corner cases of isset
--FILE--
<?php
	$x = 5;
	var_dump(isset($x[0]));
	var_dump(isset($y[0])); // this should *NOT* create $y
?>
--EXPECT--
bool(false)
bool(false)