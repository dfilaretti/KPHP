/* In the concrete, this program will not terminate.
   However, in the SIGNS domain, the analysis will determine 
   that the content of X will not change, and it will remain 
   zero il all reachable states. */

$x = 0;

while ($x == 0) {    // non-termination 
    $x = $x + 0;
}
