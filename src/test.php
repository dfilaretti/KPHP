<?php

/*
	function bar($x) {
		return $x + 1;
	}
	function foo($x) {
		bar($x);
	}
	$z = foo(4);

*/


	function fact($n) {
		echo "[[ABA]]";
		if ($n == 0) {
			return 1;
		}
		else {
			return $n * fact($n - 1);
		}
	}


	$y = fact(5);

?>
