--TEST--
switch
--TEST--
<?php
	$x = 0;
	switch ($x) {
		case 0:
			echo "0\n";
		case 1:
			echo "1\n";
		case 2:
			echo "2\n";
	}
?>
--EXPECT--
0
1
2
