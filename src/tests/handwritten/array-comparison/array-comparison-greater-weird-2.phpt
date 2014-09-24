--TEST--
Our own variation of the example from bug #60688. 
--FILE--
<?php
	$a=array("a" => 2, 'test' => 4);
	$b=array('test' => 1, "a" => 3);
	var_dump($a < $b, $a > $b); 
?>
--EXPECT--
bool(true)
bool(true)