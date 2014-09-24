--TEST--
trying to iterate a scalar
--FILE--
<?php
	foreach (5 as $v) {}
	$x = 0;
	foreach ($x as $v) {}
	foreach ($y as $v) {}
?>
--EXPECTF--
Warning: Warning: Invalid argument supplied for foreach() in %s on line %d

Warning: Warning: Invalid argument supplied for foreach() in %s on line %d

Notice: Undefined variable: %s in %s on line %d

Warning: Warning: Invalid argument supplied for foreach() in %s on line %d
