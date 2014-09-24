<?php

    /* Another instance of the {paper, Dagtuhl talk} example */

    $a = "one";
    $c = $a . ($a = "two");
    echo $c; // "twotwo"

    $GLOBALS["a"] = "one";
    $c = $GLOBALS["a"] . ($GLOBALS["a"] = "two");
    echo $c; // "onetwo"
?>
