--TEST--
try-catch and throw
--FILE--
<?php
	try {
		echo "first line\n";
		throw new Exception("Exception!\n");
		echo "second line\n";
	}
	catch (Exception $e) {
		echo $e -> getMessage();
	}
?>
--EXPECT--
first line
Exception!
