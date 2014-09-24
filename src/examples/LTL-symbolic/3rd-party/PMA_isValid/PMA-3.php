<?php

/**
 * checks given $var against $type or $compare
 *
 * $type can be:
 * - false       : no type checking
 * - 'scalar'    : whether type of $var is integer, float, string or boolean
 * - 'numeric'   : whether type of $var is any number repesentation
 * - 'length'    : whether type of $var is scalar with a string length > 0
 * - 'similar'   : whether type of $var is similar to type of $compare
 * - 'equal'     : whether type of $var is identical to type of $compare
 * - 'identical' : whether $var is identical to $compare, not only the type!
 * - or any other valid PHP variable type
 *
 * <code>
 * // $_REQUEST['doit'] = true;
 * PMA_isValid($_REQUEST['doit'], 'identical', 'true'); // false
 * // $_REQUEST['doit'] = 'true';
 * PMA_isValid($_REQUEST['doit'], 'identical', 'true'); // true
 * </code>
 *
 * NOTE: call-by-reference is used to not get NOTICE on undefined vars,
 * but the var is not altered inside this function, also after checking a var
 * this var exists nut is not set, example:
 * <code>
 * // $var is not set
 * isset($var); // false
 * functionCallByReference($var); // false
 * isset($var); // true
 * functionCallByReference($var); // true
 * </code>
 *
 * to avoid this we set this var to null if not isset
 *
 * @param mixed &$var    variable to check
 * @param mixed $type    var type or array of valid values to check against $var
 * @param mixed $compare var to compare with $var
 *
 * @return boolean whether valid or not
 *
 * @todo add some more var types like hex, bin, ...?
 * @see     http://php.net/gettype
 */

/**
	
 Compile: kompile php.k --backend symbolic --symbolic-rules step --transition step

 Property 1: "when $var is int and $type is 'numeric' the result is always 'true'"  
	krun examples/LTL-symbolic/3rd-party/PMA_isValid/PMA-3.php --parser='java -jar parser/parser.jar' -cPC='true' -cIN='ListItem(#symInt(x)) ListItem("numeric") ListItem(#symInt(x))' --ltlmc='<>Ltl (eqTo(gv(variable("result")),val(true)))'

  Property 2: "PMA_is_Valid($x, 'similar' $y) always return true when $x is int and $y is string"
  	krun examples/LTL-symbolic/3rd-party/PMA_isValid/PMA-3.php --parser='java -jar parser/parser.jar' -cPC='true' -cIN='ListItem(#symInt(x)) ListItem("similar") ListItem(#symString(x))' --ltlmc='<>Ltl(eqTo(gv(variable("result")),val(true)))'	
 **/

function PMA_isValid(&$var, $type = 'length', $compare = null)
{

    if (! isset($var)) {
        // var is not even set
        return false;
    }

    if ($type === false) {
        // no vartype requested
        return true;
    }

    if (is_array($type)) {
        return in_array($var, $type);
    }

    // allow some aliaes of var types
    //$type = strtolower($type);	// Commented by Daniele
    switch ($type) {
    case 'identic' :
        $type = 'identical';
        break;
    case 'len' :
        $type = 'length';
        break;
    case 'bool' :
        $type = 'boolean';
        break;
    case 'float' :
        $type = 'double';
        break;
    case 'int' :
        $type = 'integer';
        break;
    case 'null' :
        $type = 'NULL';
        break;
    }

    if ($type === 'identical') {
        return $var === $compare;
    }

    // whether we should check against given $compare
    if ($type === 'similar') {
        switch (gettype($compare)) {
        case 'string':
        case 'boolean':
            $type = 'scalar';
            break;
        case 'integer':
        case 'double':
            $type = 'numeric';
            break;
        default:
            $type = gettype($compare);
        }
    } elseif ($type === 'equal') {
        $type = gettype($compare);
    }

    // do the check
    if ($type === 'length' || $type === 'scalar') {
        $is_scalar = is_scalar($var);
        if ($is_scalar && $type === 'length') {
            return (bool) strlen($var);
        }
        return $is_scalar;
    }

    if ($type === 'numeric') {
        return is_numeric($var);
    }
    
    if (gettype($var) === $type) {
        return true;
    }

    return false;
}

$var = user_input (); // symbolic 
$type = user_input (); // symbolic
$compare = user_input (); // symbolic
$result = PMA_isValid($var, $type, $compare);
label("after-call");


?>