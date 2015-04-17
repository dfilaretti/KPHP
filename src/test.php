<?php


	// may aliasing {x, y, z}
	$x = array(1,2,3);
	if (2 == 3) {
		$y =& $x;
	} else
	{
		$y =& $x;
	}
	echo "DONE";

/*
	// may aliasing {x, y, z}
	$x = 0;
	if (2 ==3) {
		$y =& $x;
		$z = 1;
	} else
	{
		$y = 2;
		$z =& $y; 
	}
	echo "DONE";
*/

?>
