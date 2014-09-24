--TEST--
method lookup - not found
--FILE--
<?php
	class A {};
	$a = new A;
	$a -> foo();
?>
--EXPECTF--