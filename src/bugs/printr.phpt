--TEST--
print_r
--FILE--
<?php
	class A{
		public $a = "a";
		protected $b = "b";
		private $c = "c";
	}
	$x = 0;
	print_r($x);
	$x = 0.5;
	print_r($x);
	$x = true;
	print_r($x);
	$x = "hello";
	print_r($x);
	$x = array(0);
	print_r($x);
	$x = new A;
	print_r($x);
	$x = NULL;
	print_r($x);
?>
--EXPECTF--
00.51helloArray
(
    [0] => 0
)
A Object
(
    [a] => a
    [b:protected] => b
    [c:A:private] => c
)