<?php


// Just to check that it doesn't go crazy 

function foo() {
	echo "foo";
	$foo = 1;
	return bar() + 1;
}

function bar() {
	echo "bar";
	$bar = 1;
	return baz() + 1;
}

function baz() {
	echo "baz";
	$baz = 1;
	if (2 == 2) {1;} else {1;}
	return xuf() + 1;
}

function xuf() {
	echo "xuf";
	$xuf = 1;
	if (2 == 2) {1;} else {1;}
	return 0;
}

$x = foo();

?>
