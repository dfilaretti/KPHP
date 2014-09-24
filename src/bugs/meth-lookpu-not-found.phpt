--TEST--
method lookup - not found
--FILE--
<?php
	class A {};
	$a = new A;
	$a -> foo();
?>
--EXPECTF--
Fatal error: Call to undefined method A::foo() in %s on line %d