--TEST--
the next element to be iterated is read at the beginning of the loop body
(otherwise the result would have been '1,2,3,4,true')
--FILE--
<?php
	$obj1 -> a = 1; $obj1 -> b = 2; 
	$obj2 -> a = 3; $obj2 -> b = 4; 
	$ref = &$obj1;
	foreach ($obj1 as $v) { 
		echo "$v,";
		if ($v === $obj1 -> b) 
			$obj1 = $obj2; 
	};
	if ($obj1 === $obj2) echo "true";
?>
--EXPECT--
1,2,true
