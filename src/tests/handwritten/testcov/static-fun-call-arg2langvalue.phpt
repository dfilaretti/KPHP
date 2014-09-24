--TEST--
--FILE--
<?php
	class A{
		static function foo() {
			echo "foo";
		}
	}
	
	$fun = "foo";
	A::$fun();
?>
--EXPECT--
fun