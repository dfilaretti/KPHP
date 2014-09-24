--TEST--
and
--FILE--
<?php
	$x = 0;
	if ($x && true)
		echo "yes\n";
	else
		echo "no\n";		
	$x = 1;
	if ($x and true)
		echo "yes\n";
	$y = true;
	$y &= true;
	var_dump($y);

?>
--EXPECT--
no
yes
int(1)
