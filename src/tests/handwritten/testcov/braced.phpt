--TEST--
braced
--FILE--
<?php
	$z = "Message: ";
	$x = array("Daniele");
	$y -> name = "Filaretti";
	echo "hello {$x[0]} {$y -> name}!\n";
?>
--EXPECT--
hello Daniele Filaretti!
