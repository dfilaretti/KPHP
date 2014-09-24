--TEST--
mod, conversion of arguments to integer
--FILE--
<?php
	var_dump(6.2 % 2.5);
	var_dump(6 % 2.5);
	var_dump(6.2 % 2);
	var_dump(6 % 2);	
?>
--EXPECT--
int(0)
int(0)
int(0)
int(0)
