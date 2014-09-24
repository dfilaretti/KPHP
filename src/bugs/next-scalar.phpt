--TEST--
next with scalar argument
--FILE--
<?php
	next(0);
?>
--EXPECT--
Fatal error: Only variables can be passed by reference in %s on line %d