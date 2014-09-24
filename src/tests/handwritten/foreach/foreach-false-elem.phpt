--TEST--
foreach must not stop when there are array elements set to 'false'
(which may happens if one adopts, when implementing foreach, a naive
loop condition which makes use of the fact that when the current pointer
has past the last element, the value of 'current' is 'false')
--FILE--
<?php	
	$x = array(1, 2, false, 3, 4);
	foreach ($x as $v) 
		echo $v;
?>
--EXPECT--
1234