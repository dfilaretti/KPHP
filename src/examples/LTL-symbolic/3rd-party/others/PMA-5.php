<?php



/**
 * merges array recursive like array_merge_recursive() but keyed-values are
 * always overwritten.
 *
 * array PMA_arrayMergeRecursive(array $array1[, array $array2[, array ...]])
 *
 * @return array   merged array
 *
 * @see     http://php.net/array_merge
 * @see     http://php.net/array_merge_recursive
 */

function PMA_arrayMergeRecursive()
{
    switch(func_num_args()) {
    case 0 :
        return false;
        break;
    case 1 :
        // when does that happen?
        return func_get_arg(0);
        break;
    case 2 :
        $args = func_get_args();
        if (! is_array($args[0]) || ! is_array($args[1])) {
            return $args[1];
        }
        foreach ($args[1] as $key2 => $value2) {
            if (isset($args[0][$key2]) && !is_int($key2)) {
                $args[0][$key2] = PMA_arrayMergeRecursive(
                    $args[0][$key2], $value2
                );
            } else {
                // we erase the parent array, otherwise we cannot override
                // a directive that contains array elements, like this:
                // (in config.default.php)
                // $cfg['ForeignKeyDropdownOrder']= array('id-content','content-id');
                // (in config.inc.php)
                // $cfg['ForeignKeyDropdownOrder']= array('content-id');
                if (is_int($key2) && $key2 == 0) {
                    unset($args[0]);
                }
                $args[0][$key2] = $value2;
            }
        }
        return $args[0];
        break;
    default :
        $args = func_get_args();
        $args[1] = PMA_arrayMergeRecursive($args[0], $args[1]);
        array_shift($args);
        return call_user_func_array('PMA_arrayMergeRecursive', $args);
        break;
    }
}

//var_dump(PMA_arrayMergeRecursive(array('0' => 1, 2, 3), array('0' => 2, 3, 4)));

?>