<?php
	function foo() {
		echo "foo";
		return 1;
	}

	function bar() {
		echo "bar";
		return 2;
	}

	function baz() {
		echo "baz";
		return 3;
	}



	if (2 == 2) 
		$f = "foo";
	else
		$f = "bar";

	$result = $f(1, 2, 3, 4, 5);

	echo "hey";

?>
