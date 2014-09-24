--TEST--
key cannot be a reference
--FILE--
<?php
	$a = array(1);
	foreach ($a as &$k => $v)
		echo $v;
?>
--EXPECTF--
Fatal error: Key element cannot be a reference in %s on line %d