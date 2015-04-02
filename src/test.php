<?php

// expecting MUST aliasing but getting MAY

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


?>
