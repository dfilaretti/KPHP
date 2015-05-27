<?php 

// An example involving objects 

	// Define a class with a few fields of different visibility
	class A {
		public $a = 12;
		protected $b = -1;
		private $c = "hello";
	}

	// let us "build" a "top" string key
	if (2 == 3) 
		$k = "hello";
	
	else 
		$k = "world";
	

	// Create an instance of A
	$o = new A();

	// Attempt to access the "Top" field
	$v =  ($o -> $k);

	// OUTCOME: same as for arrays.
	// All fields of $o are "collapsed" (read, aliased)
	// into a single one, and a "StringTop" key is inserted
	// in $o, also pointing to this "merge set". 
	// The value contained is the LUB of all previously existing 
	// values... 
	












?>
