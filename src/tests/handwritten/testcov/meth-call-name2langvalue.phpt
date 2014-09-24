--TEST--
using variable as method name
--FILE--
<?php
	class A {
		public function foo () {
			echo "Hello!\n";
		}
	}	
	$x = new A;
	$fun = "foo";
	$x -> $fun();
?>
--EXPECT--
Hello!
