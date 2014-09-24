<?php

	/*  
	
		Simple model checking example
	
		compile: kompile php.k --transition step

		run: To check property "global variable $x and local $x at some point will be aliased" 	
			krun examples/LTL-symbolic/handwritten/alias.php --parser="java -jar parser/parser.jar" --ltlmc = '<>Ltl alias(gv(variable("y")),fv("foo", variable("x")))'
		
	*/
	
	$y = 0;	
	function foo() {
		global $y;
		$x = &$y;
	}
	foo();
	
?>