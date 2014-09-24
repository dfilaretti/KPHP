require "configuration.k"
require "syntax.k"
require "shared.k"
require "memory.k"
require "core.k"
require "functions.k"
require "classes.k"
require "objects.k"
require "arith-ops.k"
require "arrays.k"
require "type-conversions.k"
require "control-structures.k"
require "io.k"
require "scope-resolution.k"
require "strings.k"
require "include.k"
require "not-supported.k"
require "constants.k"
require "exceptions.k"
require "post-execution.k"
require "model-checking.k"

module PHP-SYNTAX
endmodule

module PHP	
	// Language features
	imports PHP-SYNTAX
	imports CONFIGURATION
	imports SYNTAX
	imports SHARED
	imports MEMORY
	imports CORE					
	imports FUNCTIONS				
	imports CLASSES					
	imports OBJECTS					
	imports ARITH-OPS				
	imports ARRAYS					
	imports TYPE-CONVERSIONS		
	imports CONTROL-STRUCTURES		
	imports IO						
	imports SCOPE-RESOLUTION		
	imports STRINGS					
	imports INCLUDE					
	imports NOT-SUPPORTED
	imports CONSTANTS
	imports EXCEPTIONS
	imports POST-EXECUTION
	imports MODEL-CHECKING

	// Builtin stuff	
	imports URIS
	imports STRING-SYNTAX-HOOKS
	imports STRING-HOOKS
	imports ID-HOOKS
endmodule

