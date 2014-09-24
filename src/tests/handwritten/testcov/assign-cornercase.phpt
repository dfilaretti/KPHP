--TEST--
corner case
--FILE--
<?php
	$x = $y;
?>
--EXPECT--
Notice: Undefined variable: %s in %s on line %d
