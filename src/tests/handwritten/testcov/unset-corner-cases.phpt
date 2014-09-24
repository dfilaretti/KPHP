--TEST--
corner cases of unset
--FILE--
<?php
	// unsetting nonexistent reference
	unset($x);
	// unsetting array with current set to none
	$x = array(1); next($x);
	unset($x[0]);

?>
--EXPECT--