--TEST--
Echo behaves similar to var_dump. 
When a result is a float like "x.0", the 0s are 
not displayed (but note that the type is still float).
--FILE--
<?php
	echo 3 - 3;
	echo "\n";
	echo 3.0 - 3.0;
	echo "\n";
	echo 1 - 3;
	echo "\n";
	echo 3 - 1;
	echo "\n";
	echo 1.0 - 3;
	echo "\n";
?>
--EXPECT--
0
0
-2
2
-2
