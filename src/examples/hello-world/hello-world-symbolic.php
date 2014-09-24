<?php
	/**
	 	An example using symbolic execution. 
	 	
	 	(1) Compile  
	 			=> 'kompile php.k --backend symbolic'
	 			
	 	(2) Run the program with a symbolic integer as input (note that 
	 		only a single path is chosen):	
	 			=> 'krun --parser="java -jar parser/parser.jar" -cPC="true" //
	 				-cIN='ListItem(#symInt(x))' examples/hello-world/hello-world-symbolic.php'
	 	
	 	(3) Run the program with a symbolic integer, showing all paths: 
	 			=> 'krun --parser="java -jar parser/parser.jar" -cPC="true" --search //
	 				-cIN='ListItem(#symInt(x))' examples/hello-world/hello-world-symbolic.php'
	 		Note the <pathCondition> cell which was automatically added to the configuration.
	 */
	 
	$input = user_input();	// accepts symbolic input from command line

	if ($input == 0)
		echo "Hello\n";
	else
		echo "World\n";
?>
