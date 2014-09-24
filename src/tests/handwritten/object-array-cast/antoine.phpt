--TEST--
converting array to object may introduce objects having integer-indexed 
properties, that cannot be accessed... Unless the object is casted 
to array again.
--FILE--
<?php
	$a = array(1);      
	$x = (object) $a;
	$x -> {0} = 2;		// this accesses $x -> "0"
	var_dump($x);
	$a = (array) $x;
	var_dump($a);
?>
--EXPECTF--
object(stdClass)#%d (2) {
  [0]=>
  int(1)
  ["0"]=>
  int(2)
}
array(2) {
  [0]=>
  int(1)
  ["0"]=>
  int(2)
}