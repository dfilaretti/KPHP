--TEST--
when comparing two compounds values stored into the same location, instead of
performing the array comparison algorithm we directly return true (this is not
really necessary, but only an optimization).
--FILE--
<?php
	$x = array(1);
	var_dump($x == $x);		// triggers optimized rule comparison-equal-loc
	$y = $x;
	var_dump($x == $y);		// triggers optimized rule comparison-equal-array
?>
--EXPECT--
bool(true)
bool(true)