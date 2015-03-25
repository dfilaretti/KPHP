// Expected
// [z |-> 0]  (concrete)
// [z |-> Zero] (signs)

<?php
function f($x) {
    $z = 123;
    // no explicit return hence the default one is used
}

$z = f(0);
?>
