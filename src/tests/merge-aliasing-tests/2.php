<?php
	// may aliasing {x, y}
	if (2 ==3) {
		$x = 0;
		$y =& $x;
	} else
	{
		$x = 0;
		$y = 12; 
	}
	echo "DONE";
?>
