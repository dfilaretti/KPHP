--TEST--
asd
--FILE--
<?php
	$x = 123;
	$y = (object) $x;
	var_dump($y);
?>
--EXPECT--
object(stdClass)#%d (1) {
  ["scalar"]=>
  int(123)
}