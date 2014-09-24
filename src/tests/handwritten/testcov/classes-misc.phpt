--TEST--
--FILE--
<?php
	class A {
		static $x;
		function foo() {
			echo "foo\n";
		}
	}
	$o = new A;
	$o -> foo();
?>
--EXPECT--
foo