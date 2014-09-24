--TEST--
even when no aliasing is present (and hence the iteration happens on a local 
temporary copy of the array) the current must be 'synchronised' at the end.
--FILE--
<?php	
	$obj1 = array(1,2);
	$obj2 = array(3,4);
	//$ref = &$obj1;
	foreach ($obj1 as $v) 
	{ 
		echo "$v,";
		if ($v === $obj1[0]) 
			break; 
	};
	var_dump(current($obj1));
?>
--EXPECT--
1,int(2)
