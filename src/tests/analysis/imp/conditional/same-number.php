<?php
	$x = 2;
	$y = 2;
	$z = 2;

	if ($x == $y) {
    		if ($y == $z) {
        		$same = 1;
    		}
    		else {
        		$same = -1;
    		}
	}	
	else {
    		$same = -1;
	}

	if ($same == 1) {
    		echo("Same numbers!");
	}
	else {
    		echo("Fail...");
}	
?>
