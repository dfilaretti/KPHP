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
				   | "initDomain"
				   | "initScopes"
				   | "initBuiltinFunctions"
				   | "initBuiltinClasses"
				   | "initSuperGlobals"
                   | "initStatus"
				   

rule [built-init-state]:	
	<k> buildInitState =>
		initDomain ~>
        initStatus ~> 
		initScopes ~>
		initBuiltinFunctions ~>
		initBuiltinClasses ~>
		initSuperGlobals ~>
		buildArrayCompareFun ... </k>
	<trace> Trace:List => Trace ListItem("built-init-state") </trace>
	[internal]


rule    <k> initStatus => . ... </k>
        <status> _ => NEXT </status>


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Initializing builtin functions} */
// ---------------------------------------------------------------------------------------------

rule [init-builtin-functions]:    
	<k> initBuiltinFunctions => . ... </k>
	<thematrix>
	...
	. =>
	L1' |-> L1
	L2' |-> L2
	L3' |-> L3
	L4' |-> L4
	L5' |-> L5
	L6' |-> L6
	L7' |-> L7
	L8' |-> L8
	L9' |-> L9
	L10' |-> L10
	L11' |-> L11
	L12' |-> L12
	L13' |-> L13
	L14' |-> L14
	L15' |-> L15
	L16' |-> L16
	L17' |-> L17
	L18' |-> L18
	L19' |-> L19
	L20' |-> L20
	L21' |-> L21
	...
	</thematrix>
        <heap> ... 
		. => 
		L1 |-> emptyArrayZval
		L2 |-> emptyArrayZval
		L3 |-> emptyArrayZval  	 
		L4 |-> emptyArrayZval 
		L5 |-> emptyArrayZval
		L6 |-> emptyArrayZval 
		L7 |-> emptyArrayZval 
		L8 |-> emptyArrayZval 
		L9 |-> emptyArrayZval 
		L10 |-> emptyArrayZval  
		L11 |-> emptyArrayZval
		L12 |-> emptyArrayZval
		L13 |-> emptyArrayZval  	 
		L14 |-> emptyArrayZval 
		L15 |-> emptyArrayZval
		L16 |-> emptyArrayZval 
		L17 |-> emptyArrayZval 
		L18 |-> emptyArrayZval 
		L19 |-> emptyArrayZval 
		L20 |-> emptyArrayZval  
		L21 |-> emptyArrayZval
	... </heap> 
        <br/>
		<functions>
		.=> "current" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(current('Variable('Simple("x"))))), 
				@byValue, L1')
				
			"count" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(count('Variable('Simple("x"))))), 
				@byValue, L2')
				
			"array_key_exists" |-> f (
				'ListWrap('Param('Variable('Simple("k"))),,'ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(array_key_exists('Variable('Simple("k")),'Variable('Simple("x"))))), 
				@byValue, L3')
				
			"key" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(key('Variable('Simple("x"))))), 
				@byValue, L4')
				
			"next" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(next('Variable('Simple("x"))))), 
				@byValue, L5') // !!!!!!
				
			"each" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(each('Variable('Simple("x"))))), 
				@byValue, L6')
				
			"reset" |-> f (
				'ListWrap('ParamRef('Variable('Simple("x")))), 
				'ListWrap('Return(reset('Variable('Simple("x"))))), 
				@byValue, L7')
			
			"var_dump" |-> f (
				'ListWrap('VarLengthParam('Variable('Simple("x")))), 
				'ListWrap(var_dump_map('Variable('Simple("x")))), 
				@byValue, L8')
			
			"print_r" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap(print_r('Variable('Simple("x")))), 
				@byValue, L9')
				
			"strlen" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(strlen('Variable('Simple("x"))))), 
				@byValue, L10')
				
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
				@byValue, L11')
			
			"define" |-> f (
				'ListWrap('Param('Variable('Simple("name"))),, 'Param('Variable('Simple("value")))), 
				'ListWrap('Return(define('Variable('Simple("name")), 'Variable('Simple("value"))))), 
				@byValue, L12')
			
			"gettype" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(gettype('Variable('Simple("x"))))), 
				@byValue,  L13')
				
			"defined" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(defined('Variable('Simple("x"))))), 
				@byValue,  L14')
				
			"is_float" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_float('Variable('Simple("x"))))), 
				@byValue, L15')
				
			"is_string" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_string('Variable('Simple("x"))))), 
				@byValue,  L16')
				
			"is_array" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_array('Variable('Simple("x"))))), 
				@byValue,  L17')
				
			"is_scalar" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_scalar('Variable('Simple("x"))))), 
				@byValue,  L18')
				
			"is_numeric" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(is_numeric('Variable('Simple("x"))))), 
				@byValue,  L19')
				
			"user_input" |-> f (
				'ListWrap(.KList), 
				'ListWrap('Return(user_input)), 
				@byValue,  L20')
				
			"label" |-> f (
				'ListWrap('Param('Variable('Simple("x")))), 
				'ListWrap('Return(label('Variable('Simple("x"))))), 
				@byValue, L21')
		</functions>
		when 	fresh(L1:Loc) andBool
			fresh(L2:Loc) andBool
			fresh(L3:Loc) andBool
			fresh(L4:Loc) andBool
			fresh(L5:Loc) andBool
			fresh(L6:Loc) andBool
			fresh(L7:Loc) andBool
			fresh(L8:Loc) andBool
			fresh(L9:Loc) andBool
			fresh(L10:Loc) andBool
			fresh(L11:Loc) andBool
			fresh(L12:Loc) andBool
			fresh(L13:Loc) andBool
			fresh(L14:Loc) andBool
			fresh(L15:Loc) andBool
			fresh(L16:Loc) andBool
			fresh(L17:Loc) andBool
			fresh(L18:Loc) andBool
			fresh(L19:Loc) andBool
			fresh(L20:Loc) andBool
			fresh(L21:Loc) andBool
			fresh(L1':Loc) andBool
			fresh(L2':Loc) andBool
			fresh(L3':Loc) andBool
			fresh(L4':Loc) andBool
			fresh(L5':Loc) andBool
			fresh(L6':Loc) andBool
			fresh(L7':Loc) andBool
			fresh(L8':Loc) andBool
			fresh(L9':Loc) andBool
			fresh(L10':Loc) andBool
			fresh(L11':Loc) andBool
			fresh(L12':Loc) andBool
			fresh(L13':Loc) andBool
			fresh(L14':Loc) andBool
			fresh(L15':Loc) andBool
			fresh(L16':Loc) andBool
			fresh(L17':Loc) andBool
			fresh(L18':Loc) andBool
			fresh(L19':Loc) andBool
			fresh(L20':Loc) andBool
			fresh(L21':Loc) 	
		[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Initialising the scopes} */
// ---------------------------------------------------------------------------------------------

/*
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
*/

rule [init-scopes]:   
	<k> initScopes => . ... </k>
	<thematrix> . =>
		L  |-> L' 
		L1 |-> L1'
		L3 |-> L3'
	</thematrix> 
	<heap> . => 
		L'  |-> zval(Array(none,.List), array, 0, false) 
       		L1' |-> zval(Array(none,.List), array, 1, false) 
        	L3' |-> zval(Array(none,.List), array, 1, false)	
	</heap> 
	<currentScope> . => L </currentScope>
	<globalScope> . => L </globalScope>
	<superGlobalScope> . => L1 </superGlobalScope>
	<globalStaticScope> . => L3 </globalStaticScope>
	when 	fresh(L:Loc) andBool fresh(L1:Loc) andBool fresh(L3:Loc) andBool
		fresh(L':Loc) andBool fresh(L1':Loc) andBool fresh(L3':Loc)
	
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Superglobals initialization} 
		This operation initializes (some of the) superglobals. */
// ---------------------------------------------------------------------------------------------

rule [init-superglobals]:    
	<k> initSuperGlobals => 
			'Expr('Assign(ref(Lsg, alpha("_GET")),, 'Array('ListWrap(.KList)))) ~>
			'Expr('Assign(ref(Lsg, alpha("_COOKIE")),, 'Array('ListWrap(.KList)))) ~>
			'Expr('Assign(ref(Lsg, alpha("_POST")),, 'Array('ListWrap(.KList)))) ~>
			'Expr('ReferenceAssign(ref(Lsg, alpha("GLOBALS")),, Lg))
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
