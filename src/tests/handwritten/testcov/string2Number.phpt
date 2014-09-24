--TEST--
string2Number internal function
--FILE--
<?php
	echo ((int) "123") . "\n";
	echo ((int) "123.5") . "\n";
	echo ((int) "123abc") . "\n";
	echo ((int) "123.5abc") . "\n";
	echo ((int) "abc") . "\n";

	echo ((float) "123") . "\n";
	echo ((float) "123.5") . "\n";
	echo ((float) "123abc") . "\n";
	echo ((float) "123.5abc") . "\n";
	echo ((float) "abc") . "\n";

?>
--EXPECT--