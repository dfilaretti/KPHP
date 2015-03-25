// Expected
// [z |-> 1]   (concrete)
// [z |-> Top] (signs)

<?php
function f($x) {
    if ($x == 5) {
        return(1);
    }
    else {
        return(-1);
    }
}

$z = f(5);
?>
