<?php 

	class A {
		//private $x = 1;
		public $a = 12;
		private $x = "hello";
	}

	class B extends A {
		public $b = 123;
		private $x = 2;
	}

	$o = new B();
?>
