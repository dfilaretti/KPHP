<?php

	// kphp run init-config.xml test.php --config

	$x = 123;
	// Computation will get stuck here. 
	// If we want to resume it later, we need 
	// to save the state on a file, and resume it later on.
	breakpoint();
	$y = 1;
?>