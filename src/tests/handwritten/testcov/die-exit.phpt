--TEST--
asdf
--FILE--
<?php
	$x = "This program terminates here!\n";
	die($x);
	echo "should not execute this";
?>
--EXPECT--
This program terminates here!
