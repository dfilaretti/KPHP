--TEST--
string access
--FILE--
<?php
	$x = "hello";
	var_dump($x[0]);
	var_dump($x["foo"]);
?>
--EXPECT--
string(1) "h"
string(1) "h"