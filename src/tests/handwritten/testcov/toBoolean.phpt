--TEST--
toBoolean
--FILE--
<?php
	var_dump((bool) 0.0);
	var_dump((bool) NULL);
	var_dump((bool) "");
	var_dump((bool) 4.4);
	var_dump((bool) array());
	var_dump((bool) true);
	var_dump((bool) false);
	var_dump((bool) "0");
	var_dump((bool) true);
	var_dump((bool) "hello");
	$x = "hello";
	var_dump((bool) $x);
?>
--EXPECT--
bool(false)
bool(false)
bool(false)
bool(true)
bool(false)
bool(true)
bool(false)
bool(false)
bool(true)
bool(true)
bool(true)

