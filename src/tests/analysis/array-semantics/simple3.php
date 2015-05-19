<?php 
	$x[1] = 1;	// $x[Pos] = Pos
	$x[1 - 1] = 1;	// $x[Top] = Pos

	// {$x[Pos], $x[Top]} are now aliased 

	$y = "hello";

	$x[2] =& $y;	// $x[Pos] =& $y

	// $x[Pos] is now aliased to $y. 
	// However, also $x[Top] now is part of the aliased set,
	// to preserve the initial relationship between 
	// $x[Pos] and $x[Top]
?>
