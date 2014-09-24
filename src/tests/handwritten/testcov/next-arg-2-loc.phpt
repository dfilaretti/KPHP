--TEST--
asdf
--FILE--
<?php
	$x["foo"] = "bar";
	var_dump(next($x));
?>
--EXPECT--
bool(false)
