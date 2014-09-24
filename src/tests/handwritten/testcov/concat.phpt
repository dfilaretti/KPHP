--TEST--
concat 
--FILE--
<?php
	$l = "hello ";
	$r = "world!";
	$msg = $l . $r;
	$msg .= "\n";
	echo $msg;

?>
--EXPECT--
hello world!
