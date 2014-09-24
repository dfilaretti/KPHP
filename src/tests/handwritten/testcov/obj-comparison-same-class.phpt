--TEST--
asd
--FILE--
<?php
	class A{};
	$a1 = new A();
	$a2 = new A();
	var_dump($a1 == $a2);
	$a1 -> x = 123;
	var_dump($a1 == $a2);
	var_dump($a1 >  $a2);
	var_dump($a1 >= $a2);
	var_dump($a1 <  $a2);
	var_dump($a1 <= $a2);
?>
--EXPECT--
bool(true)
bool(false)
bool(true)
bool(true)
bool(false)
bool(false)
