<?php


$x = array("foo" => 1);
$y =& $x;
$z =& $y;
$p =& $z;

unset($y);
unset($z);
unset($p);
unset($x);

/*
class A{
	public $foo = 1;
}

$o = new A;


if (2 == 2) {
	$x =& $o;
	//$o -> foo = -1;
}
else {
	$x =& $o;
	//$o -> bar = 0;
}
*/

/*

if (2 == 2) {
	$x -> foo = 1;
	//$y =& $x;
}
else {
	$x -> foo = 2;
	//$y =& $x;
}

*/


/*
$y = 1;

if (2 == 2) {
	$x =& $y;	
}
else {
	$x =& $y;
	$z =& $x;
}
*/



?>
