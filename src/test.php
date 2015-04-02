<?php

// test passing parameters by ref
// this was challenging 

function foo() {
	static $bubu = 0;
	echo "hello";
	if (2 == 2) {
		$bubu = 1;
	}
	else {
		$bubu = -1;
	}
}

foo();

?>
