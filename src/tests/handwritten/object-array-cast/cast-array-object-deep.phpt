--TEST--
when casting array to object deep copy is performed
--FILE--
<?php
	$a = array("foo" => 1);      
	$x = (object) $a;
	$x -> foo = "changed";
	var_dump($a);
	var_dump($x);
?>
--EXPECTF--
array(1) {
  ["foo"]=>
  int(1)
}
object(stdClass)#%d (1) {
  ["foo"]=>
  string(7) "changed"
}
