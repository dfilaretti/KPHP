<?php 

	class A {
		public $x = 123;
	}


	// we need some "StringTop"
	if (2 == 1) {
		$k = "hello";
	}
	else {
		$k = "world";
	}


	$o = new A();
	$o -> foo = -1;
	$o -> foo = 0;

	$k1 = "foo";	
	
	$o -> $k =& $k1;
	
	//var_dump($o);
?>
