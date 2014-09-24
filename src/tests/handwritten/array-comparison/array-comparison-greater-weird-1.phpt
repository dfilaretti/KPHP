--TEST--
Example reported in bug #60688 (https://bugs.php.net/bug.php?id=60688) 
--FILE--
<?php
	$a=array(0 => 2, 'test' => 2);
	$b=array('test' => 3, 0 => 1);
	var_dump($a>$b, $b>$a);
?>
--EXPECT--
bool(false)
bool(false)