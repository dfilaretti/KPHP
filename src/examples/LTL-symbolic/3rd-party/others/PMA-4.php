<?php

/* 	!!! TOO SLOW !!!
    compile : 'kompile php.k --backend-symbolic --symbolic-rules "step"'
	run     : 'krun PMA-5.php -cPC="true" -cIN="ListItem(#symInt(x))" --parser="java -jar parser/parser.jar" --search'
*/

/**
 * Converts numbers like 10M into bytes
 * Used with permission from Moodle (http://moodle.org) by Martin Dougiamas
 * (renamed with PMA prefix to avoid double definition when embedded
 * in Moodle)
 *
 * @param string $size size
 *
 * @return integer $size
 */
function PMA_getRealSize($size = 0)
{

/*    
    if (! $size) {
        return 0;
    }
*/  
    $scan['gb'] = 1073741824; //1024 * 1024 * 1024;
    $scan['g']  = 1073741824; //1024 * 1024 * 1024;
    $scan['mb'] = 1048576;
    $scan['m']  = 1048576;
    $scan['kb'] =    1024;
    $scan['k']  =    1024;
    $scan['b']  =       1;

    foreach ($scan as $unit => $factor) {
        if (strlen($size) > strlen($unit)
            && /*strtolower*/(substr($size, strlen($size) - strlen($unit))) == $unit
        ) {
            return substr($size, 0, strlen($size) - strlen($unit)) * $factor;
        }
    }

    return $size;
} 

$in = user_input();
echo PMA_getRealSize($in) . "\n";
?>