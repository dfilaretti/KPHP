<?php

// here the algo get confused: it reports a MUST alias {x,y}
// while it should in fact be a may alias. 
// It doesn't seem to be a bug, but part of the current algo itself.
// NOTE: this may be a problem in the algo design. 
// It may have to do with how the CODOMAIN is computed. 
// Do example on paper


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
