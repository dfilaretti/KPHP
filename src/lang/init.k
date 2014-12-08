require "memory.k"
require "k-visitor.k"
require "builtin-functions.k"

module INIT
    imports MEMORY
    imports K-VISITOR
    imports BUILTIN-FUNCTIONS

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Initialization} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
    
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Building the initial state} 
		The following operations loads the (currently defined) builtin functions such as
		key, current, vardump, etc. 
		LATER: put all this stuff into an external file, and load it via krun options. */
// ---------------------------------------------------------------------------------------------

syntax  Internal ::= "buildInitState" 
				   | "initScopes"
				   | "initBuiltinFunctions"
				   | "initBuiltinClasses"
				   | "initSuperGlobals"

rule [built-init-state]:	
	<k> buildInitState =>
		initScopes ~>
		initBuiltinFunctions ~>
		initBuiltinClasses ~>
		initSuperGlobals ~>
		buildArrayCompareFun ... </k>
	<trace> Trace:List => Trace ListItem("built-init-state") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Initializing builtin functions} */
// ---------------------------------------------------------------------------------------------

rule [init-builtin-functions]:    
	<k> initBuiltinFunctions => . ... </k>
        <heap> ... . => L |-> zval(Array(none,.List), array, 1, false) ... </heap> 
        <br/>
		<functions>
		.=> "current" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(current('Variable('Simple("x"))))), 
				@byValue, L)
				
			"count" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(count('Variable('Simple("x"))))), 
				@byValue, L)
				
			"array_key_exists" |-> f (
				'ListWrap('Param('Variable('Simple("k"))),,'ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(array_key_exists('Variable('Simple("k")),'Variable('Simple("x"))))), 
				@byValue, L)
				
			"key" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(key('Variable('Simple("x"))))), 
				@byValue, L)
				
			"next" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(next('Variable('Simple("x"))))), 
				@byValue, L)
				
			"each" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(each('Variable('Simple("x"))))), 
				@byValue, L)
				
			"reset" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(reset('Variable('Simple("x"))))), 
				@byValue, L)
			
			"var_dump" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap(var_dump('Variable('Simple("x")))), 
				@byValue, L)
			
			"print_r" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap(print_r('Variable('Simple("x")))), 
				@byValue, L)
				
			"strlen" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(strlen('Variable('Simple("x"))))), 
				@byValue, L)
				
			"substr" |-> f (
				'ListWrap('Param('Variable('Simple("str"))),,
					'Param('Variable('Simple("start"))),,
					'ParamDefault('Variable('Simple("len")),,999)
				), 
				'ListWrap('Return(substr(
					'Variable('Simple("str")),
					'Variable('Simple("start")),
					'Variable('Simple("len"))
					))), 
				@byValue, L)
			
			"define" |-> f (
				'ListWrap('Param('Variable('Simple("name"))),, 'Param('Variable('Simple("value")))), 
				'ListWrap('Return(define('Variable('Simple("name")), 'Variable('Simple("value"))))), 
				@byValue, L)
			
			"gettype" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(gettype('Variable('Simple("x"))))), 
				@byValue, L)
				
			"defined" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(defined('Variable('Simple("x"))))), 
				@byValue, L)
				
			"is_float" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_float('Variable('Simple("x"))))), 
				@byValue, L)
				
			"is_string" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_string('Variable('Simple("x"))))), 
				@byValue, L)
				
			"is_array" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_array('Variable('Simple("x"))))), 
				@byValue, L)
				
			"is_scalar" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_scalar('Variable('Simple("x"))))), 
				@byValue, L)
				
			"is_numeric" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_numeric('Variable('Simple("x"))))), 
				@byValue, L)
				
			"user_input" |-> f (
				'ListWrap(.KList), 
				'ListWrap('Return(user_input)), 
				@byValue, L)
				
			"label" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(label('Variable('Simple("x"))))), 
				@byValue, L)
		</functions>
		<trace> Trace:List => Trace ListItem("init-builtin-functions") </trace>
		when fresh(L:Loc)
		[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Initialising the scopes} */
// ---------------------------------------------------------------------------------------------

rule [init-scopes]:   
	 <k> initScopes => . ... </k>
	 <heap> . => L  |-> zval(Array(none,.List), array, 0, false) 
       		   L1 |-> zval(Array(none,.List), array, 1, false) 
        	   L3 |-> zval(Array(none,.List), array, 1, false)	</heap> 
	<currentScope> . => L </currentScope>
	<globalScope> . => L </globalScope>
	<superGlobalScope> . => L1 </superGlobalScope>
	<globalStaticScope> . => L3 </globalStaticScope>
	<trace> Trace:List => Trace ListItem("init-scopes") </trace>
	when fresh(L:Loc) andBool fresh(L1:Loc) andBool fresh(L3:Loc)
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Superglobals initialization} 
		This operation initializes (some of the) superglobals. */
// ---------------------------------------------------------------------------------------------

rule [init-superglobals]:    
	<k> initSuperGlobals => 
			'Expr('Assign(ref(Lsg, "_GET"),, 'Array('ListWrap(.KList)))) ~>
			'Expr('Assign(ref(Lsg, "_COOKIE"),, 'Array('ListWrap(.KList)))) ~>
			'Expr('Assign(ref(Lsg, "_POST"),, 'Array('ListWrap(.KList)))) ~>
			'Expr('ReferenceAssign(ref(Lsg, "GLOBALS"),, Lg))
	... </k>    
	<superGlobalScope> Lsg:Loc </superGlobalScope>
	<globalScope> Lg:Loc  </globalScope>
	<trace> Trace:List => Trace ListItem("init-superglobals") </trace>
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Building the builtin classes} 
		Currently, we have just Exception and stdClass */
// ---------------------------------------------------------------------------------------------

rule [init-builtin-classes]:    
	<k> initBuiltinClasses => makeExceptionClass ~> makeStdClass ... </k>
	<trace> Trace:List => Trace ListItem("init-builtin-classes") </trace>
	[internal]

syntax K ::= "makeStdClass"

rule [make-stdClass]: 
	<k> makeStdClass =>
	    'Class(
	    	'Normal(.KList),,
			"stdClass",,
	        'None(.KList),,
	        'None(.KList),,
	        'ListWrap(.KList)) ... </k>
	<trace> Trace:List => Trace ListItem("make-stdClass") </trace>
	[internal]

syntax K ::= "makeExceptionClass"

rule [make-exception]: 	
	<k> makeExceptionClass => 
		'Class(
      'Normal(
        .KList
      ),,
      "Exception",,
      'None(
        .KList
      ),,
      'None(
        .KList
      ),,
      'ListWrap(
        'InstanceVariable(
          'Modifiers(
            'ListWrap(
              'Public(
                .KList
              )
            )
          ),,
          'ListWrap(
            'Normal(
              'Variable(
                'Simple(
                  "errorMsg"
                )
              )
            )
          )
        ),,
        'FunctionDecl(
          "Exception",,
          'ListWrap(
            'Param(
              'Variable(
                'Simple(
                  "msg"
                )
              )
            )
          ),,
          'ListWrap(
            'Expr(
              'Assign(
                'ObjectAccess(
                  'Variable(
                    'Simple(
                      "this"
                    )
                  ),,
                  'ObjectProperty(
                    'Simple(
                      "errorMsg"
                    )
                  )
                ),,
                'Variable(
                  'Simple(
                    "msg"
                  )
                )
              )
            )
          )
        ),,
        'FunctionDecl(
          "getMessage",,
          'ListWrap(
            .KList
          ),,
          'ListWrap(
            'Return(
              'Some(
                'ObjectAccess(
                  'Variable(
                    'Simple(
                      "this"
                    )
                  ),,
                  'ObjectProperty(
                    'Simple(
                      "errorMsg"
                    )
                  )
                )
              )
            )
          )
        )
      )
    ) ... </k>
	<trace> Trace:List => Trace ListItem("make-exception") </trace>
	[internal]



syntax K ::= "buildArrayCompareFun"

rule [build-array-compare]: 

<k>	buildArrayCompareFun => 
'FunctionDecl(
      "isEqualArray",,
      'ListWrap(
        'Param(
          'Variable(
            'Simple(
              "op1"
            )
          )
        ),,
        'Param(
          'Variable(
            'Simple(
              "op2"
            )
          )
        )
      ),,
      'ListWrap(
        'If(
          'Less(
            'FunctionCall(
              'FunctionName(
                "count"
              ),,
              'ListWrap(
                'Param(
                  'Variable(
                    'Simple(
                      "op1"
                    )
                  )
                )
              )
            ),,
            'FunctionCall(
              'FunctionName(
                "count"
              ),,
              'ListWrap(
                'Param(
                  'Variable(
                    'Simple(
                      "op2"
                    )
                  )
                )
              )
            )
          ),,
          'Block(
            'ListWrap(
              'Return(
                'Some(
                  'Negative(
                    'LNumber(
                      'Deci(
                        "1"
                      )
                    )
                  )
                )
              )
            )
          ),,
          'ListWrap(
            'ElseIf(
              'Greater(
                'FunctionCall(
                  'FunctionName(
                    "count"
                  ),,
                  'ListWrap(
                    'Param(
                      'Variable(
                        'Simple(
                          "op1"
                        )
                      )
                    )
                  )
                ),,
                'FunctionCall(
                  'FunctionName(
                    "count"
                  ),,
                  'ListWrap(
                    'Param(
                      'Variable(
                        'Simple(
                          "op2"
                        )
                      )
                    )
                  )
                )
              ),,
              'Block(
                'ListWrap(
                  'Return(
                    'Some(
                      'LNumber(
                        'Deci(
                          "1"
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        ),,
        'ForEach(
          'Variable(
            'Simple(
              "op1"
            )
          ),,
          'Pattern(
            'Some(
              'Key(
                'Variable(
                  'Simple(
                    "key"
                  )
                )
              )
            ),,
            'Variable(
              'Simple(
                "val"
              )
            )
          ),,
          'Block(
            'ListWrap(
              'If(
                'Not(
                  'FunctionCall(
                    'FunctionName(
                      "array_key_exists"
                    ),,
                    'ListWrap(
                      'Param(
                        'Variable(
                          'Simple(
                            "key"
                          )
                        )
                      ),,
                      'Param(
                        'Variable(
                          'Simple(
                            "op2"
                          )
                        )
                      )
                    )
                  )
                ),,
                'Block(
                  'ListWrap(
                    'Return(
                      'Some(
                        'Null(
                          .KList
                        )
                      )
                    )
                  )
                ),,
                'ListWrap(
                  'ElseIf(
                    'Less(
                      'Variable(
                        'Simple(
                          "val"
                        )
                      ),,
                      'ArrayAccess(
                        'Variable(
                          'Simple(
                            "op2"
                          )
                        ),,
                        'Some(
                          'Variable(
                            'Simple(
                              "key"
                            )
                          )
                        )
                      )
                    ),,
                    'Block(
                      'ListWrap(
                        'Return(
                          'Some(
                            'Negative(
                              'LNumber(
                                'Deci(
                                  "1"
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  ),,
                  'ElseIf(
                    'Greater(
                      'Variable(
                        'Simple(
                          "val"
                        )
                      ),,
                      'ArrayAccess(
                        'Variable(
                          'Simple(
                            "op2"
                          )
                        ),,
                        'Some(
                          'Variable(
                            'Simple(
                              "key"
                            )
                          )
                        )
                      )
                    ),,
                    'Block(
                      'ListWrap(
                        'Return(
                          'Some(
                            'LNumber(
                              'Deci(
                                "1"
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        ),,
        'Return(
          'Some(
            'LNumber(
              'Deci(
                "0"
              )
            )
          )
        )
      )
    ) ... </k>
	<trace> Trace:List => Trace ListItem("build-array-compare") </trace>
	[internal]

endmodule
