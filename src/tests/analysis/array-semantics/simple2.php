<?php 
	$x[1] = 1;	// $x[Pos] = Pos
	$x[1 - 1] = 1;	// $x[Top] = Pos

	// {$x[Pos], $x[Top]} are now aliased 

	$y =& $x[2];	// $y =& $x[Pos]

	// $y simply aliased to $x[Pos]
?>
