<?php 
	$x[1] = 1;	// $x[Pos] = Pos
	$x[1 - 1] = 1;	// $x[Top] = Pos

	// {$x[Pos], $x[Top]} are now aliased 

	// NOTE: what value do we expect? 
	// here, we get Top, because on the 1st assignment
	// Pos is merged with NULL, the initial value. 
?>
