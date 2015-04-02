<?php

	if (2 ==3) {
		$x = array("foo" => 0, "bar" => 2);	
		$y =& $x;		
	}
	else {
		$x = array("foo" => 0, "bar" => -2);	
		$y = "hello";
	}
?>
