--TEST--
When trying to compare 
--FILE--
<?php
	$x = array(1, 2, 3);
	var_dump($x == $x);
?>
--EXPECT--
bool(true)
