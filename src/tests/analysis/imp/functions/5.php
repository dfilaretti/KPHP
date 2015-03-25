// Expected
// [z |-> 1]   (concrete)
// [z |-> Pos] (signs)

<?php
function f($x) {
    if ($x == 5)  {
        return(1);
    }
    else {
        $z = 123;
    }
    return(12);
}

$z = f(5);
?>
