<?php

	/*  
		1: kompile php.k --backend symbolic --symbolic-rules step --transition step

		2: "when given an input =/=0 , function foo returns an integer"
		krun examples/LTL-symbolic/handwritten/types-fun2.php --parser="java -jar parser/parser.jar" -cPC="#symInt(input) ==Int 0" -cIN='ListItem(#symInt(input))' --ltlmc='<>Ltl (lab("after-call") /\Ltl hasType(gv(variable("result")),int))'
	
		3: "the function will return int or string" 
		krun examples/LTL-symbolic/handwritten/types-fun2.php --parser="java -jar parser/parser.jar" -cPC="true" -cIN='ListItem(#symInt(input))' --ltlmc='<>Ltl (lab("after-call") /\Ltl (hasType(gv(variable("result")),string) \/Ltl hasType(gv(variable("result")),int)))


	*/
	
	function foo($in) {
		if ($in == 0)
			$result = 123;
		else
			$result = "a string";
		return $result;
	}
	
	$result = foo(user_input());	
	label("after-call");

?>