--TEST--
accessing a non visible class static variable
--FILE--
<?php
	class A {
		public static $a = 123;
		protected static $b = 123;
	}
	var_dump(A::$a);
	A::$c;
?>
--EXPECT--
int(123)

Fatal error: Cannot access protected property A::$b in %s on line %d