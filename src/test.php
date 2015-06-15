<?php

$a1 = array ("foo" => 1 ,"bar" => 2); $a2 = array ("foo" => 3 ,"bar" => 4);
$ref = &$a1; // aliasing on $a1
foreach ($a1 as $v){ echo "$v,"; if ($v === $a["foo"]) $a1=$a2; };

/*
$x = array("foo" => 1, "bar" => 2);
$z =& $x["foo"];
$q =& $z;

unset($q);
unset($q);
unset($q);
unset($q);


$y = $x;
*/
?>
