--TEST--
--FILE--
<?php
	$x = 0;
	$y = array("foo" => &$x);
	var_dump($y);
?>
--EXPECT--
array(1) {
  ["foo"]=>
  &int(0)
}