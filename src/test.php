<?php 


$i=1;
$j=1;

switch($i) {
    case 0:
      echo "In branch 0\n";
      break;
    case 1:
      echo "In branch 1\n";
      break;
    case 2:
      echo "In branch 2\n";
      break;
    case 3:
      echo "In branch 3\n";
      break 2;
    case 4:
      echo "In branch 4\n";
      break;
    default:
      echo "In default\n";
      break;
  }

echo $j;  
?>
