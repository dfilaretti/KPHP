--TEST--
reset with scalar argument
--FILE--
<?php
	reset(0);
?>
--EXPECTF--
Fatal error: Only variables can be passed by reference in %s on line %d