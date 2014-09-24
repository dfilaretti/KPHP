<?php

	/*  
		1: kompile php.k --backend symbolic --symbolic-rules step --transition step

		2: "variable $y will never have type string"

		krun tests-ltlmc/types.php --parser="java -jar parser/parser.jar" -cPC="true" -cIN='ListItem(#symInt(input))' --ltlmc='~Ltl <>Ltl hasType(gv(variable("y")),string)'
		
	*/
	
	$input = user_input();
	
	if ($input <= 0) 
		$y = 0;
	else	
		$y = 1;

?>