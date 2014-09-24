--TEST--
asd
--FILE--
<?php
	$a1 = array(1, 2, 3);
	$a2 = array(3, 2, 3);
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
bool(true)
bool(true)
