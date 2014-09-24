--TEST--
and
--FILE--
<?php
	$x = 0;
	if ($x || false)
		echo "yes\n";
	else
		echo "no\n";		
	$x = 1;
	if ($x or false)
		echo "yes\n";
	$y = true;
	$y |= true;
	var_dump($y);

?>
--EXPECT--
no
yes
int(1)
