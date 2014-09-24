--TEST--
plus
--FILE--
<?php
	echo 3 + 3 . "\n";
	echo 3.1 + 3.4 . "\n";
	echo 3 + 3.5 . "\n";
	echo 3.5 + 3 . "\n";
?>
--EXPECT--
6
6.5
6.5
6.5
