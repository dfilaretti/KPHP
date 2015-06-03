<?php 
	$x[1] = 1;	// $x[Pos] = Pos
	$x[-1] = -1;	// $x[Neg] = Neg

	// $x[Pos] and $x[Neg] are disjoint

	$x[2] =& $y;

	// Since the keys Pos and Neg are disjointed, the reference
	// assignment only affected Pos. 
	// This coincides with the expected, pre-analyis behaviour.  
?>
