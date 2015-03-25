<?php

// This drove me crazy but now works

function f($n) {
	if (1 == 1) {
		return 1;
		//return $n * f($n - 1);
	}
	else {
		return $n * f($n - 1);
		//return 1;
	}
}


$result = f(10);

?>
