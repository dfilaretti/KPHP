<?php

$x = 1;
$y = 4;
echo $x + $y;


class A {
    public $test = 1;
};

class B extends A {};

$obj = new A();

if ($obj instanceof A) {
   echo 'A';
}
?>
