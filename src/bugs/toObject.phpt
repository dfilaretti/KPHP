--TEST--
toObject
--FILE--
<?php
	$x = array(1,2);
	$y = (object) $x;
	var_dump($y);
	$x = 0;
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