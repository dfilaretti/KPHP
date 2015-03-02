<?php
	$x = 1;
	$y =& $x;
	//unset($x);


	function foo($x) {
		return $x + 1;
	}

	$z = foo(123);

?>
