--TEST--
testing "==="
--FILE--
<?php
	$a = array(1, 2);
	$b = array(3, 2);	
	var_dump("a" === "a");
	var_dump("a" === "b");
	var_dump(1 === 1);
	var_dump(0 === 1);
	var_dump($a === $b);
	var_dump($a === $a);
?>
--EXPECT--
bool(true)
bool(false)
bool(true)
bool(false)
bool(false)
bool(true)
