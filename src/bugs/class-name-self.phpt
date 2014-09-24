--TEST--
self
--FILE--
<?php
	class A {
		static $x = "test\n";
		public static function sayHello() {
			echo self::$x;
		}
	}
	A::sayHello();
?>
--EXPECT--
test