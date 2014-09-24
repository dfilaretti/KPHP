--TEST--
key casting
--FILE--
<?php
	$x["3"] = 0;
	$x[3.6] = 1;
	var_dump($x);	
?>
--EXPECT--
array(1) {
  [3]=>
  int(1)
}