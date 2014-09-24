--TEST--
evaluating the argument of break
--FILE--
<?php
	for ($i = 0; $i < 10; $i++) {
		for ($j = 0; $j < 10; $j++) {
			echo "*";
			if ($i == 2)
				break($i);
		}
		echo "\n";
	}
?>
--EXPECT--
**********
**********
*