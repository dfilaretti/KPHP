// Concrete: [z |-> 45]
// Signs: [z |-> Pos]

<?php
function foo($x) {
    if ($x == 10) {
        return 0;
    }
    else {
        return $x + foo($x + 1);
    }
}

$z = foo(0); 
?>
