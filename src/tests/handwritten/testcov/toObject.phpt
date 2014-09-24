--TEST--
toObject
--FILE--
<?php
	// array
	$x = array(1,2);
	$y = (object) $x;
	var_dump($y);
	// scalar
	$x = 0;
	$y = (array) $x;
	var_dump($y);
	// object
	unset($x);
	$x -> a = 1;
	$y = (object) $x;
	var_dump($y);
	
?>
--EXPECTF--
object(stdClass)#%d (2) {
  [0]=>
  int(1)
  [1]=>
  int(2)
}
array(1) {
  [0]=>
  int(0)
}
object(stdClass)#%d (1) {
  ["a"]=>
  int(1)
}