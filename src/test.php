
<?php 

$i="abc";

//for ($j=0; $j<10; $j++) {
switch (1) {
  case 1:
  	echo "In branch 1\n";
	
  	switch ($i) {
  		case "ab":
  			echo "This doesn't work... :(\n";
  			break;
  		default:
  			echo "Inner default...\n";
  	}
	
  	/*for ($blah=0; $blah<2; $blah++) {
  	  if ($blah==1) {
  	    echo "blah=$blah\n";
  	  }
  	}*/
  	break;
	
  case 2:
  	echo "In branch 2\n";
  	break;
  case 3:
  	echo "In branch \$i\n";
  	break;
  case 4:
  	echo "In branch 4\n";
  	break;
  default:
  	echo "Hi, I'm default\n";
  	break;
 }
//}
?>
