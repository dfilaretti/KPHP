<?php 
	$x[1] = 1;	// $x[Pos] = Pos
	$x[-1] = -1;	// $x[Neg] = Neg

	// $x[Pos] and $x[Neg] are disjoint

	$y = $x[1 - 1]; // $y = $x[Top]

	// $x[Top] has been created as a side-effect of 
	// reading it. This caused the aliasing of the existing
	// keys Top and Neg. 

	$x[2] =& $y;

	// BUG! The reference assignment causes the "intersecting keys"
	// to be aliased as well, that is {Pos, Top}. 
	// But unfortunately, Neg doesn't get updated, while it should! 	
?>
