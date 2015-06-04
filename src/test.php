<?php
	// expecting MUST aliasing but getting MAY


/*
$x = 1;
if (2 == 2) {
	$y = 1;
}
else {
	$y = -1;
}

*/


	$x = array("foo" => 1, "bar" => 2);

	if (2 == 2) {
		$y =& $x["foo"];
	}
	else {
		$y =& $x["foo"];
	}	

?>
