--TEST--
exercise different case rules for next
--FILE--
<?php
	$x = array(1, 2, 3);
	$y = array(4, 5, 6);
	foreach ($x as $v) {
		echo $v . "\n";
		if ($v == 2) {
			next($x); 	// ignored
			next($y);
		}
	}
	var_dump(current($x));
	next($x);
	var_dump(current($y));
	next($y);
	var_dump(current($y));
	reset($x);
	for ($i = 0; $i < 10; $i++){
		if ($i == 4)
			next($x);
	}
	var_dump(current($x));
?>
--EXPECT--
1
2
3
bool(false)
int(5)
int(6)
int(2)
