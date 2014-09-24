<?php
	/**
	
		(0) Compile: 
				=> 'kompile php.k --transition="step"'
	
		(1) Example of true property: "variable $x eventually assume value 'hello'".
				=> 'krun --parser="java -jar parser/parser.jar" --ltlmc='<>Ltl(eqTo(gv(variable("x")),val("hello")))' examples/hello-world/hello-world-ltl.php'
	 	
	 	(2) Example of false property: "variable $x eventually assume value 'hello'".
	 			=> 'krun --parser="java -jar parser/parser.jar" --ltlmc='<>Ltl(eqTo(gv(variable("x")),val("world")))' examples/hello-world/hello-world-ltl.php'
	 */
	 
	$x = 0;
	$x = "hello";
?>
