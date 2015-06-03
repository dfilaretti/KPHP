<?php 
	$x[1]  = 1;	// $x[Pos]  = Pos
	$x[0]  = 2;	// $x[Zero] = Pos
	$x[-1] = 3;	// $x[Neg]  = Pos

	if (2 == 2) {
		$x[2 - 2] = 3;		// $x[Top] = Pos
	}
	else {
		$x[1] = 2;		// $x[Pos] = Pos
	}



?>
