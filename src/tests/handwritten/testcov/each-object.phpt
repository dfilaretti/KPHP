--TEST--
each on objects
--FILE--
<?php
	$o -> a = 0; $o -> b = 1;
	var_dump(each($o));
	var_dump(current($o));
?>
--EXPECT--
array(4) {
  [1]=>
  int(0)
  ["value"]=>
  int(0)
  [0]=>
  string(1) "a"
  ["key"]=>
  string(1) "a"
}
int(1)