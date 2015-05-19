<?php 
	$x[1]  = 1;
	$x[0]  = 2;
	$x[-1] = 3;

	$x[2 - 2] =& $x[0];
	
	// The attempt to resolve $x[Top] resulted in
	// {Pos,Zero,Zeg,Top} to be collapsed/aliased together. 
	// Aliasing then performed as notmal

?>
