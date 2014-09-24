<?php

/**
 * Example with symbolic model checking:
 * 		"for any input of type string the function always return a boolean".  
 * 
 * compile: kompile php.k --backend symbolic --transition step
 * run: krun tests-ltlmc/3rd-party/wp-1.php --parser="java -jar parser/parser.jar" -cPC="true" -cIN='ListItem(#symString(s))' --ltlmc tests-ltlmc/3rd-party/wp-1-ltlformula.txt 
 *
 * Note: the example differs from the original (from Wordpress) in 2 aspects:
 * 	- the line '$data = trim($data)' is commented since we don't support 'trim'
 *  - the comparisons are made with '!=' instead as '!=='. This is because
 *    of a weird bug, and should be fixed soon.
 */
 

/**
 * Check whether serialized data is of string type.
 *
 * @since 2.0.5
 *
 * @param mixed $data Serialized data
 * @return bool False if not a serialized string, true if it is.
 */

function is_serialized_string( $data ) 
{
	// if it isn't a string, it isn't a serialized string
	if ( !is_string( $data ) )
		return false;
	//$data = trim( $data );
	$length = strlen( $data );
	if ( $length < 4 )
		return false;
	elseif ( ':' !== $data[1] )
		return false;
	elseif ( ';' !== $data[$length-1] )
		return false;
	elseif ( $data[0] !== 's' )
		return false;
	elseif ( '"' !== $data[$length-2] )
		return false;
	else
		return true;
}

$result = is_serialized_string(user_input());
label("after-call");

?>