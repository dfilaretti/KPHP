--TEST--
preDec
--FILE--
<?php
	$x = 0;
	var_dump(--$x);	
?>
--EXPECT--
int(-1)