--TEST--
when casting object to array deep copy is performed
--FILE--
<?php
	$a -> foo = 1;      
	$x = (array) $a;
	$x["foo"] = "changed";
	var_dump($a);
	var_dump($x);
?>
--EXPECTF--
object(stdClass)#%d (1) {
  ["foo"]=>
  int(1)
}
array(1) {
  ["foo"]=>
  string(7) "changed"
}