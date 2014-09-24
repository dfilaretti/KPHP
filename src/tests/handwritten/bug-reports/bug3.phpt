--TEST--
The value returned by 'current($x)' immediately after the loop seems to 
be the value 'current($x)' returned the first time it was called inside the loop.
--FILE--
<?php
	$x = array(1, 2, 3);
	//$ref =& $x; // decommenting this line makes it work fine
	foreach ($x as $v) {
		if ($v == $x[1])
			current($x);
	}
	var_dump(current($x)); // prints int(3)
?>
--EXPECT--
bool(false)