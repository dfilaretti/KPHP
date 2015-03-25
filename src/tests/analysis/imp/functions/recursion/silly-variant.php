// Concrete: [z |-> 45]
// Signs: [z |-> Pos]

<?php
function foo($x) {
    if (!($x == 10)) {
        return $x + foo($x + 1);
    }
    else {
        return 0;
    }
}


$z = foo(0); 
?>
