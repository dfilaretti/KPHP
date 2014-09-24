--TEST--
testing ">" 
--FILE--
<?php
	var_dump(5.5 >= 9.2);
	var_dump(9.2 >= 5.5);
	var_dump("abc"  >= "abcd");
	var_dump("abcd" >= "abc");
?>
--EXPECT--
bool(false)
bool(true)
bool(false)
bool(true)
