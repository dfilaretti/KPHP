--TEST--
asdf
--FILE--
<?php
	var_dump(3 == "asd");
	var_dump("asd" == 3);
?>
--EXPECT--
bool(false)
bool(false)