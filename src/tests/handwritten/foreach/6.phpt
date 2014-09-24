--TEST--
causes a loop
--FILE--
<?php	
	$obj1 = array(1,2);
	$obj2 = array(3,4);
	$ref = &$obj1;
	$counter = 0;
	foreach ($obj1 as $v) { 
		if ($counter == 10) {
			echo "loop detected\n";
			break;
		}
		else
			$counter++;
		echo "$v,";
		if ($v === $obj1[0]) 
			$obj1 = $obj2; 
	};
?>
--EXPECT--
1,3,3,3,3,3,3,3,3,3,loop detected
