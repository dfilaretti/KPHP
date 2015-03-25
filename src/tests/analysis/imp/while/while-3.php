/* In the concrete, this program will terminate in a state 
   where X has value 10. In the SIGN domain, the analysis will
   only be able to tell that X will be positive.  */

<?php
$x = 0;

while (!($x == 10)) {    // x != 10 
    $x = $x + 1;
}
?>
