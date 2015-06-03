<?php 
	$x = "hello world";
	$y =& $x;

	// standard behaviour 'till now...

	$v[0] =& $y;

	// standard behaviour too... 

	$t[1] =& $v[0];

	// this also looks ok 

	$v[1 - 2] = 123;

	// now this "destroys" the array a little bit. 
	// But looks ok

	// MINOR BUG: should also update refcound! 









?>
