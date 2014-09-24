<?php
	
	// manually inspecting the memory/configuration shows that 
	// the array associated with the object created by the cast 
	// has a ref count of 2. However, this seems not to happen when 
	// decommenting the last line 

	$boo = array(1);
	$xxx = (object) $boo;
	$xxx -> {0} = 123;
	var_dump($xxx);			// comment me
?>