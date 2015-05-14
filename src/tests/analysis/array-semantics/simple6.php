<?php 
	$x[1]  = 1;
	$x[0]  = 2;
	$x[-1] = 3;

	$x[2] =& $x[0];
	
	// Should observe standard aliasing

?>
