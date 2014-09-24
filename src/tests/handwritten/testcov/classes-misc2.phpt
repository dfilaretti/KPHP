--TEST--
--FILE--
<?php
	class A {
		public $x, $y;
		function &foo() {
			$x = "foo";
			return $x;
		}
	}

	$o = new A;
	$o -> foo();
?>
--EXPECT--
foo