--TEST--
reference assignment, some extra cases
--FILE--
<?php
	// scalar
	function zero() {
		return 0;
	}	
	$x =& zero();
	var_dump($x);
	// fresh object property
	$y -> a =& $x;
	var_dump($y);
	
?>
--EXPECT--
Warning: Only variables should be assigned by reference in %s on line %d
int(0)
object(stdClass)#1 (1) {
  ["a"]=>
  &int(0)
}