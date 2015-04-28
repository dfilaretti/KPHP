--TEST--
Testing stack after early function return
--FILE--
<?php 
function F () { 
	if(1) {
		return("Hello");
	}
}

$i=1;
while ($i == 2) {
	echo 1 + "2";
	echo F();
	$i++;
}
?>
--EXPECT--
HelloHello
