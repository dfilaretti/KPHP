--TEST--
trying to advance the internal pointer of the object or array being iterated 
in a foreach is not possible (i.e. the command seems to be ignored).
--FILE--
<?php	
	$x = array(1, 2, 3, 4);
	foreach ($x as $v)  {
		next($x);
		echo $v;
	}
?>
--EXPECT--
1234