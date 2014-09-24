<?php
	$x = array("a", "b", "c", "d");
	
	$z =& $x; 	// comment and decomment this one!!!
	
	foreach ($x as $v)
			echo current($x);
	echo current($x);

?>
