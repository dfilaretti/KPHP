--TEST--
zend returns "222" while we return "23"
--FILE--
<?php
	$x = array(1, 2, 3);
	foreach ($x as $v)
		echo current($x); 
	$y = 0;
	var_dump(current($y));
?>
--EXPECT--
23NULL