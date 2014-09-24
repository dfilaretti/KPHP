<?php

	/*  
		1: kompile php.k --backend symbolic --symbolic-rules step --transition step

		2: "after the function is called, global var $result has type int"
		krun examples/LTL-symbolic/handwritten/types-fun.php  --parser="java -jar parser/parser.jar" -cPC="true" -cIN='ListItem(#symInt(input))' 	
		--ltlmc = '<>Ltl (lab("after-call") /\Ltl hasType(gv(variable("result")),int))'
	*/
	
	function one() {
		$result = 1;
		return $result;
	}
	
	$result = one();	
	label("after-call");

?>