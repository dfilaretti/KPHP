<?
function F()
{
	$a = "Hello ";
	return($a);
}

function G()
{
  $myvar = 4;
  
  echo "$myvar ";
  echo F();
  echo "\$myvar";
}

G();
?>