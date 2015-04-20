<?php
// test passing parameters by ref
// this was challenging 

$v = 1;
function foo(&$x) {
	// conditional does nothing but forces state merge
	if (2 == 1) {1;} else {2;};
	$x = 0;
}
foo($v);

/*
	// may aliasing {x, y, z}
	$x = 0;
	if (2 ==3) {
		$y =& $x;
		$z = 1;
	} else
	{
		$y = 2;
		$z =& $y; 
	}
	echo "DONE";
*/

?>
