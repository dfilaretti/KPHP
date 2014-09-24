<?php

/*

    compile : 'kompile php.k --backend-symbolic --symbolic-rules "step"'

	run     : 'krun examples/LTL-symbolic/handwritten/4.php  -cPC="true" -cIN="ListItem(#symInt(x))" --parser="java -jar parser/parser.jar" --search'
*/

	$a = array("a" => 0, "b" => 1);
	$k = user_input();
	
	if ($k == "bc")
		echo $a[$k];
?>