--TEST--
--FILE--
<?php
	var_dump(!false);
	var_dump(!true);
	var_dump(!"hello");
	var_dump(!0);
	$x = 0;
	var_dump(!$x);
?>
--EXPECT--
bool(true)
bool(false)
bool(false)
bool(true)
bool(true)
