// Expected
// [z |-> 8]   (concrete)
// [z |-> Pos] (signs)

<?php
function foo($x) {
    $y = $x + 1;
    return($y);
}

function bar($x) {
    $y = foo($x);
    return($y * 2);
}

$z = bar(3);
?>
