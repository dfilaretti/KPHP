--TEST--
--FILE--
<?php
	class Foo {
		public function sayHi() {
			var_dump($this);
		} 
	}
	
	$o = new Foo;
	$o -> sayHi();
	
?>
--EXPECT--
object(Foo)#1 (0) {
}
