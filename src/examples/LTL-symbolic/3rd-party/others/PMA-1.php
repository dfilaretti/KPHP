<?php

/**
 * calls $function for every element in $array recursively
 *
 * this function is protected against deep recursion attack CVE-2006-1549,
 * 1000 seems to be more than enough
 *
 * @param array  &$array             array to walk
 * @param string $function           function to call for every array element
 * @param bool   $apply_to_keys_also whether to call the function for the keys also
 *
 * @return void
 *
 * @see http://www.php-security.org/MOPB/MOPB-02-2007.html
 * @see http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2006-1549
 */

function PMA_arrayWalkRecursive(&$array, $function, $apply_to_keys_also = false)
{
    static $recursive_counter = 0;
    if (++$recursive_counter > 1000) {
        //PMA_fatalError(__('possible deep recursion attack'));
    	die('possible deep recursion attack');
    }
    foreach ($array as $key => $value) {
        if (is_array($value)) {
            PMA_arrayWalkRecursive($array[$key], $function, $apply_to_keys_also);
        } else {
            $array[$key] = $function($value);
        }

        if ($apply_to_keys_also && is_string($key)) {
            $new_key = $function($key);
            if ($new_key != $key) {
                $array[$new_key] = $array[$key];
                unset($array[$key]);
            }
        }
    }
    $recursive_counter--;
}

function inc($x) {
	return $x + 1;
}

$a = array(1, 2, 3, 4);

PMA_arrayWalkRecursive($a,"inc", false);

var_dump($a);

?>