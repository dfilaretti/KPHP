--TEST--
testing the 'gettype' internal function
--FILE--
<?php
	$x = 0;
	echo gettype($x) . "\n";
	$x = 0.0;
	echo gettype($x) . "\n";
	$x = "0";
	echo gettype($x) . "\n";
	$x = true;
	echo gettype($x) . "\n";
	$x = array("foo");
	echo gettype($x) . "\n";
	unset($x);
	$x -> foo = "bar" . "\n";
	echo gettype($x) . "\n";
	echo gettype(NULL) . "\n";
?>
--EXPECT--
integer
double
string
boolean
array
object
NULL
