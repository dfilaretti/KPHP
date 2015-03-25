<?php

$v = 1;


function foo(&$x) {
	if (2 == 1) {1;} else {2;};
	$x = 0;
}

foo($v);



?>
