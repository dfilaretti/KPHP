--TEST--
each on scalar values
--FILE--
<?php
	var_dump(each(0));
?>
--EXPECT--
Fatal error: Only variables can be passed by reference in %s on line %d