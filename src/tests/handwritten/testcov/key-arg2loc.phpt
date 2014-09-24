--TEST-- 
key argument to location
--FILE--
<?php
	$x = array(1, 2 ,3);
	echo key($x);
?>
--EXPECT--
0
