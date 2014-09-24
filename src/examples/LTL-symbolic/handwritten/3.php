<?php

	/*  
		Symbolic execution example, using bound
		
		compile : 'kompile php.k --backend-symbolic --symbolic-rules "step"'
		
		run: krun examples/LTL-symbolic/handwritten/3.php -cIN="ListItem(#symInt(x))" -cPC="true" --search --parser="java -jar parser/parser.jar" --bound 3
	*/

	$x = user_input();
	
	for ($i = 0; $i < $x; $i++) {
		$data[$i] = 0;
	}


 

?>