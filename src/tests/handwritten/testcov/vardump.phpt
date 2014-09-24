--TEST--
var_dump
--FILE--
<?php

	class A{
		public $a = "a";
		protected $b = "b";
		private $c = "c";
	}
	$x = 0;
	var_dump($x);
	$x = 0.5;
	var_dump($x);
	$x = true;
	var_dump($x);
	$x = "hello";
	var_dump($x);
	$x = array(0);
	var_dump($x);
	$x = new A;
	var_dump($x);
	$x = NULL;
	var_dump($x);
?>
--EXPECTF--
int(0)
float(0.5)
bool(true)
string(5) "hello"
array(1) {
  [0]=>
  int(0)
}
object(A)#%d (3) {
  ["a"]=>
  string(1) "a"
  ["b":protected]=>
  string(1) "b"
  ["c":"A":private]=>
  string(1) "c"
}
NULL