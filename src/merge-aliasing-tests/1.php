<?php
	// may aliasing {x,y}
	$x = 0;
	if (2 ==3) {
		$y =& $x;
	};
	echo "DONE";
?>
