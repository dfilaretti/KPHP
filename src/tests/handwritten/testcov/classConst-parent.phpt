--TEST--
lookup of class static property in parent class
--FILE--
<?php
	class A { static $x = "A"; }
	class B extends A {}
	var_dump(B::$x);
?>
--EXPECT--
string(1) "A"