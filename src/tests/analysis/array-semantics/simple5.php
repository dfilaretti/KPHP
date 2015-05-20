<?php 
	$x[1] = 1;	// $x[Pos] = Pos
	$x[-1] = -1;	// $x[Neg] = Neg

	// $x[Pos] and $x[Neg] are disjoint

	$y = $x[1 - 1]; // $y = $x[Top]

	// $x[Top] has been created as a side-effect of 
	// reading it. This caused the aliasing of the existing
	// keys Top and Neg. 

	$x[2] =& $y;

	// The reference assign causes ALL array fields to be aliased
	// as well....

	
?>
