--TEST--
exercise some type juggling rules
--FILE--
<?php
	var_dump(3 + "3");
	var_dump("1" + 5.5);
?>
--EXPECT--
int(6)
float(6.5)
