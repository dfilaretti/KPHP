--TEST--
testing ">" 
--FILE--
<?php
	var_dump(array(1, 2, 3) < array(1, 8, 3));
	var_dump(5.5 < 9.2);
	var_dump(9.2 < 5.5);
	var_dump("abc"  < "abcd");
	var_dump("abcd" < "abc");
?>
--EXPECT--
bool(true)
bool(true)
bool(false)
bool(true)
bool(false)