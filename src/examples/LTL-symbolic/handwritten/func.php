<?php

	/*  
		1: kompile php.k --backend symbolic --symbolic-rules step --transition step

		2: "at some point the variable $x local to function "foo" has value 4":
			krun examples/LTL-symbolic/handwritten/func.php  --parser="java -jar parser/parser.jar" -cPC="true" -cIN="ListItem(0)" --ltlmc='<>Ltl eqTo(fv("foo",variable("x")),val(4))' 
		
		3: "but not the global version of x (which instead has value 0)":
			krun examples/LTL-symbolic/handwritten/func.php  --parser="java -jar parser/parser.jar" -cPC="true" -cIN="ListItem(0)" --ltlmc='<>Ltl eqTo(gv(variable("x")),val(4))' 

		4: "global variable $y is never initialized (i.e. always NULL)":
		   krun examples/LTL-symbolic/handwritten/func.php  --parser="java -jar parser/parser.jar" -cPC="true" -cIN="ListItem(0)" --ltlmc='[]Ltl eqTo(gv(variable("y")),val(NULL))' 

	*/
	
	$x = 0;
	
	function foo() {
		$x = 4;
	}
	
	foo();

?>