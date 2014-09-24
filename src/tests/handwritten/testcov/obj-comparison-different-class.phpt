--TEST--
asd
--FILE--
<?php
	class A{};
	class B{};
	$a1 = new A();
	$a2 = new B();
	var_dump($a1 == $a2);
	var_dump($a1 >  $a2);
	var_dump($a1 >= $a2);
	var_dump($a1 <  $a2);
	var_dump($a1 <= $a2);
?>
--EXPECT--
bool(false)
bool(false)
bool(false)
bool(false)
bool(false)
