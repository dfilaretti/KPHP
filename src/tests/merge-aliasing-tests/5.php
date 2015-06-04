<?php

// Results in a MAY aliasing

	$x = 0;	
	if (2 ==3) {
		$y =& $x;
	}
	else {
		if (1 == 1) {
			$y =& $x;
		}
		else {
		}
	}

?>
