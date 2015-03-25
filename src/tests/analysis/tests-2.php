<?php

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


/*
function fact($n) {
    if (!($n == 0)) {
        return $n * fact($n - 1);
    }
    else {
        return 1;
    }
}

$q = fact(5);
*/







/*
function fact($n) {
	echo "[[ABA]]";
	if ($n == 0) {
		return 1;
	}
	else {
		return $n * fact($n - 1);
	}
}

$y = fact(1);

*/


/*
function bar($x) {
	return $x + 1;
}
function foo($x) {
	bar($x);
}
$z = foo(4);
*/


/*
if (2 == 9) {
	$y = 1;
}
else {
	$y = -1;
}
*/





?>
