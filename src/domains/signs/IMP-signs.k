/**************************************************
 *** SIGN INTERPRETER *****************************
 *************************************************/

require "../../IMP-syntax.k" 
require "../concrete/IMP-concrete-domain.k"
require "lattice.k"
require "forward-ops.k"
require "backward-ops.k"
require "alpha.k"

module IMP-SIGNS

	imports IMP-SYNTAX
	imports IMP-CONCRETE-DOMAIN
	imports LATTICE
	imports FORWARD-OPS
    imports BACKWARD-OPS
	imports ALPHA

	rule isKResult(I:Int) => false
	rule isKResult(B:Bool) => false
	rule isKResult(S:String) => false
    rule isKResult(E:Exception) => false
endmodule
