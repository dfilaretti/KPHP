--TEST--
toObject
--FILE--
<?php
	// array
	$x = array(1,2);
	$y = (array) $x;
	var_dump($y);
	// scalar
	$x = 0;
	$y = (array) $x;
	var_dump($y);
	// object
	unset($x);
	$x -> a = 1;
	$y = (array) $x;
	var_dump($y);
	
?>
--EXPECTF--
array(2) {
  [0]=>
  int(1)
  [1]=>
  int(2)
}
array(1) {
  [0]=>
  int(0)
}
array(1) {
  ["a"]=>
  int(1)
}