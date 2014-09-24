--TEST--
self
--FILE--
<?php
	class A {
		public static function sayHi() {
			return "Hi!\n";
		}
		public function sayHello() {
			echo self::sayHi();
		}
	}
	$a = new A;
	$a -> sayHello();
?>
--EXPECT--
Hi!
