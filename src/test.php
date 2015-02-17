<?php
// This causes issues with refcounting

if (2 == 4) {
	$x = 1;
	$y = 88;
}
else {
	$x = -1;
	$y = &$x;
}

/*
$x = 123;
function &foo() {
	global $x;
	$y = 1;
	if (2 == 4)  {
		return $x;
	} 
	else {
		return $y;
	}
}
$result = &foo();
*/

/*
$val = 123;
function &foo(&$x) {
	$y = 1;
	if (2 == 4)  {
		return $x;
	} 
	else {
		return $y;
	}
}
$result = &foo($val);
*/

/*
function &foo() {
	$x = -1;
	$y = 1;
	if (2 == 4)  {
		return $x;
	} 
	else {
		return $y;
	}
}
$result = &foo();
*/
