--TEST--
arithmetic assignment ops
--FILE--
<?php
	$a = 4;
	var_dump($a += 2);
	var_dump($a -= 2);
	var_dump($a /= 2);
	var_dump($a %= 2);
?>
--EXPECT--
int(6)
int(4)
int(2)
int(0)
