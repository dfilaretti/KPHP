--TEST--
comparison involving undefined variable
--FILE--
<?php
	var_dump(3 > $x);
	var_dump(null == 3);
	var_dump(3 == NULL);
	var_dump(true == false);
	var_dump(false == true);
	var_dump(true == true);
	var_dump(false == false);
	var_dump(4.4 == 4.4);
	var_dump(4.2 == 4.4);
	var_dump(4 == 5.0);
	
?>
--EXPECT--
Notice: Undefined variable: %s in %s on line %d
bool(true)
bool(false)
bool(false)
bool(false)
bool(false)
bool(true)
bool(true)
bool(true)
bool(false)
bool(false)