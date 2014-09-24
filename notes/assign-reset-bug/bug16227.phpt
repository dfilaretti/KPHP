--TEST--
Bug #16227 (Internal hash position bug on assignment)
--FILE--
<?php

$arrayOuter = array("key1","key2");
$arrayInner = array("0","1");

while(list(,$o) = each($arrayOuter)){
	$placeholder = $arrayInner;
	//current($placeholder);     <-------------
	while(list(,$i) = each($arrayInner)){
		print "inloop $i for $o\n";
	}
}

?>
--EXPECT--
inloop 0 for key1
inloop 1 for key1
inloop 0 for key2
inloop 1 for key2
