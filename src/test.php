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



?>
