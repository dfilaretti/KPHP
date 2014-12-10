// (some of the) the language infrastructure

require "configuration.k"
require "syntax.k"

// (language independent) language features

require "lang/shared.k"
require "lang/memory.k"
require "lang/core.k"
require "lang/functions.k"
require "lang/classes.k"
require "lang/objects.k"
require "lang/arith-ops.k"
require "lang/arrays.k"
require "lang/type-conversions.k"
require "lang/control-structures.k"
require "lang/io.k"
require "lang/scope-resolution.k"
require "lang/strings.k"
require "lang/include.k"
require "lang/not-supported.k"
require "lang/constants.k"
require "lang/exceptions.k"
require "lang/post-execution.k"
//require "lang/model-checking.k"

// (abstract) domains 

//require "domains/empty/empty-domain.k"
require "domains/mySigns/mySigns-domain.k"


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
//	imports MODEL-CHECKING

    // Which domain would you like? ;)

    //imports EMPTY-DOMAIN
    imports MYSIGNS-DOMAIN

	// Builtin stuff	
	imports URIS
	imports STRING-SYNTAX-HOOKS
	imports STRING-HOOKS
	imports ID-HOOKS
endmodule

