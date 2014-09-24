--TEST--
fatal error when accessing private static property from top-level context
--FILE--
<?php
	class A {
		private static $x = "A";
	}
	echo A::$x;
?>
--EXPECT--
Fatal error: Cannot access private property A::$x in %s on line %d