--TEST--
testing the 'empty' internal function. 
--FILE--
<?php
	
	// Integers
	
	echo "--- INTEGERS ---\n";
	
	$x = 0;
	var_dump(empty($x));

	$x = 12345;
	var_dump(empty($x));
	
	// floats
	
	echo "--- FLOATS ---\n";
	
	$x = 0.0;
	var_dump(empty($x));

	$x = 12345.5;
	var_dump(empty($x));
	
	// Boolean
	
	echo "--- BOOLEANS ---\n";
	
	$x = false;
	var_dump(empty($x));

	$x = true;
	var_dump(empty($x));

	// Strings
	
	echo "--- STRINGS ---\n";
	
	$x = "";
	var_dump(empty($x));
	
	$x = "hello";
	var_dump(empty($x));

	// Arrays
	
	echo "--- ARRAYS ---\n";
	
	$x = array();
	var_dump(empty($x));

	$x = array(1);
	var_dump(empty($x));
	
	// Objects
	
	echo "--- OBJECTS ---\n";
	
	$x = new stdClass;
	var_dump(empty($x));

	$x = new stdClass;
	$x -> a = 1;
	var_dump(empty($x));	

	// NULL
	
	echo "--- NULL ---\n";
	
	unset($x);	
	var_dump(empty($x));	
	
?>
--EXPECT--
--- INTEGERS ---
bool(true)
bool(false)
--- FLOATS ---
bool(true)
bool(false)
--- BOOLEANS ---
bool(true)
bool(false)
--- STRINGS ---
bool(true)
bool(false)
--- ARRAYS ---
bool(true)
bool(false)
--- OBJECTS ---
bool(false)
bool(false)
--- NULL ---

Notice: Undefined variable: %s in %s on line %d
bool(true)

