--TEST--
constants
--FILE--
<?php
	const a = 10;
	echo a;
	echo b . "\n";
?>
--EXPECT--
10b
