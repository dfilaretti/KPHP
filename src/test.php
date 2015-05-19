<?php 

$x="base";

function F()
{
global $x;
$x="guard";
return true;
}


if (F()) {
echo "true";
echo $x;
}
else {
echo "false"; 
echo $x;
}




?>
