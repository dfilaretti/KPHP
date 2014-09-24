--TEST--
display of public static property from top-level context
--FILE--
<?php
	class A {
		public static $x = "success";
	}	
	echo A::$x;
?>
--EXPECT--
success