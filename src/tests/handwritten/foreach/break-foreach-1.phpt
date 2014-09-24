--TEST--
this shows that, inside a foreach loop, 'current' is advanced at the beginning 
of the loop body  
--FILE--
<?php
	$obj1 -> a = 1; $obj1 -> b = 2; 
	$obj2 -> a = 3; $obj2 -> b = 4; 	
	$ref = &$obj1;
	foreach ($obj1 as $v) { 
		echo "$v,";
		if ($v === $obj1 -> a) 
			break;
	};
	var_dump(current($obj1));
?>
--EXPECT--
1,int(2)
