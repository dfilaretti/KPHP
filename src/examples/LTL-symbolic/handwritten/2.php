<?php

/* 
	Symbolic execution example.

    compile : 'kompile php.k --backend-symbolic --symbolic-rules "step"'

	run     : krun examples/LTL-symbolic/handwritten/2.php -cPC="true" -cIN="ListItem(#symInt(x))" --parser="java -jar parser/parser.jar" --search
*/

	$x = user_input();
	if ($x < 0) echo "negative\n"; else echo "positive or zero\n";
	
?>