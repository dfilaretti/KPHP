--TEST--
Testing recursive function
--FILE--
<?php

function Test($a)
{
   echo "$a ";
   $a++;
   if($a<10): Test($a); endif;
}

Test(1);

?>
--EXPECT--
1 2 3 4 5 6 7 8 9



