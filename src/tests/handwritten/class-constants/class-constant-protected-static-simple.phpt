--TEST--
fatal error when accessing protected static property from top-level context
--FILE--
<?php
	class A {
		protected static $x = "A";
	}
	echo A::$x;
?>
--EXPECT--
Fatal error: Cannot access protected property A::$x in %s on line %d