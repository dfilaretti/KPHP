--TEST--
another foreach test
--FILE--
<?php
	$obj1 = array(1,2);
	$obj2 = array(3,4);
	$ref = &$obj1;
	foreach ($obj1 as $e=>$v) { echo "$v,";
		if ($v === $obj1[0]) $obj1 =& $obj2;}                       
	if ($obj1 === $obj2) echo "true\n"; //1,2,true
?>
--EXPECT--
1,2,true
