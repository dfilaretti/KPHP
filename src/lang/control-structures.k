require "shared.k"

module CONTROL-STRUCTURES 
    imports SHARED

//@ \Section{Control flow}

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Conditional} */
///////////////////////////////////////////////////////////////////////////////

/*@ The if-then statement is desugared into an if-then-else statement whose else 
	branch is empty. */

rule [if-no-else]:
	<k> 'If(G:K,,B:K) => 'If(G,,B,,'ListWrap(.KList),,'ListWrap(.KList)) ... </k>
	<trace> Trace:List => Trace ListItem("if-no-else") </trace>
	[structural]

/*@ The alternative syntax is also desugared into a standard if */

rule [if-alt]:  
	<k> 'AltIf(G:K,,T:K,,X:K,,F:K) => 'If(G,,T,,X,,F) ... </k>
	<trace> Trace:List => Trace ListItem("if-alt") </trace>
	[structural]

rule [if-alt-no-else]:  
	<k> 'AltIf(G:K,,B:K) => 'If(G,,B) ... </k>
	<trace> Trace:List => Trace ListItem("if-alt-no-else") </trace>
	[structural]

/*@ First of all the guard is evaluated */

context 'If(HOLE,,_,,_,,_)

/*@ In case the guard has evaluated to a reference of location, the corresponding 
	value is read from memory. */
	
rule [if-guard2LangValue]: 
	<k> 'If((R:ConvertibleToLanguageValue => convertToLanguageValue(R)),,_,,_,,_) ... </k>
	<trace> Trace:List => Trace ListItem("if-guard2LangValue") </trace>
	[intermediate]
	
/*@ And finally the value is converted to a boolean value, so that the straightforward 
	semantics given below applies. */
	
rule [if-guard2Bool]: 
	<k> 'If((V:LanguageValue => 'BoolCast(V)),,_,,_,,_) ... </k>
	<trace> Trace:List => Trace ListItem("if-guard2Bool") </trace>
	when notBool (isBoolType(V))
	[intermediate]

// Abstract semantics
/* TODO: remove once the "config" version works
rule [if]:	
        <k> 'If(C,,B1,,'ListWrap(.KList),,B2) => 
	mergeConfigs(
		runAndGetConfig(runInMem(Abexp(C, some(E)), B1)),
		runAndGetConfig(runInMem(Abexp('Not(C), some(E)), B2))) ... </k>
        <mem> E </mem>
*/

rule [if]:	
	<kphp>
	<script>
        <k> 'If(C,,B1,,'ListWrap(.KList),,B2) => 
	mergeConfigs(
		runAndGetConfig(runInConf(AbexpConf(C, config(Conf)), B1)),
		runAndGetConfig(runInConf(AbexpConf('Not(C), config(Conf)), B2))) ... </k>
        _
	</script>
	Conf:Bag
	</kphp>

	
///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Conditional expression (ternary)} 
	Simply desugared into a conditional. */
///////////////////////////////////////////////////////////////////////////////

rule [ternary]: 	
	<k> 'Ternary(Guard:K,, T:K,, F:K) => 
	'If(Guard,, T,, 'ListWrap(.KList),, F) ... </k>
	[structural]

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Break} */
///////////////////////////////////////////////////////////////////////////////

// Break takes an optional argument, which is the number of levels to break. In case
// no arg is provided, the default value is 1 - i.e. the break is performed on the inner
// loop.

rule [break-none]: 	
	<k> 'Break( ('None(_) => 'Some(1)) ) ... </k>
	[structural]
 
// Since the argument can be a complex expression, it must be evaluated first 

context 'Break('Some(HOLE))

// In case we got something which is not a simple value, we try to obtain the value...

rule [break-arg2LangValue]: 	
	<k> 'Break('Some(R:ConvertibleToLanguageValue => 
	convertToLanguageValue(R))) ... </k>
	[intermediate] 

// ... and get rid of the Some constructor, just for convenience

rule [break-some]: 	
	<k> 'Break('Some(Steps:Int)) => 'Break(Steps) ... </k>
	[structural]

// Here we finally give the semantics for Break

rule [break-n]: 	
	<k> 'Break(NSteps => NSteps -Int 1) ... </k>
	<loopStack> ListItem(K) => .List ... </loopStack>
	when NSteps >Int 1
	[intermediate]

rule [break-1-normal]:
	<k> 'Break(1) ~> _ => K </k>
	<loopStack> ListItem(loopFrame(K,none)) => .List ... </loopStack>
	[step]
	
rule [break-1-special-some]:
	<k> 'Break(1) ~> _ => syncArrayCurrent(Lorig, Llocal) ~> K </k>
	<loopStack> ListItem(loopFrame(K:K,foreachArrayPair(Lorig, Llocal))) => .List ... </loopStack>
	[step]

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Continue} */
///////////////////////////////////////////////////////////////////////////////

rule [continue-none]: 	
	<k> 'Continue( ('None(_) => 'Some(1)) ) ... </k>
	<trace> Trace:List => Trace ListItem("continue-none") </trace>
	[structural]
 
context 'Continue('Some(HOLE))

/* TODO: later
rule
	<k> 'Continue('Some(R:ConvertibleToLanguageValue => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("continue-arg2LangValue") </trace>
	[intermediate] 
*/

rule [continue-some]: 	
	<k> 'Continue('Some(Steps:Int)) => 'Continue(Steps) ... </k>
	<trace> Trace:List => Trace ListItem("continue-some") </trace>
	[structural]

rule [continue-1]:
	<k> ('Continue(_) ~> _ ) =>  . ... </k>
	<trace> Trace:List => Trace ListItem("continue-1") </trace>
	[step]

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{While} */
///////////////////////////////////////////////////////////////////////////////

/*@ The alternate syntax is desugared into standard while */

rule [alt-while]:  
	<k> 'AltWhile(G:K,,B:K) => 'While(G,,B)	... </k>
	<trace> Trace:List => Trace ListItem("alt-while") </trace>
	[structural]

/*@ In order to allow the use of break, we need to push an item in the loop stack 
	at the beginning of the loop, and pop it when it's done. We do this with the 
	following rule. Note that the actual semantics of while is give in the next rule, 
	which is an internal operation. */

// NOTE: in the following we are ignoring break/continue support
rule    
	<k> 'While(B:K,,S:K) => 
                LFP(none, #whileStep(B,S)) ~> moveOnFromLoop(B) ... </k>		
            //<niter> _ => 0 </niter> TODO 
		[transition]

//@ compute a "single step" of while loop
syntax K ::= "#whileStep" "(" K "," K ")" 

rule    <k> #whileStep(B,S) => 
 		mergeConfigs(
			runAndGetConfig(runInMem(Abexp(B, some(E)), S)),
                    	runAndGetConfig(runInMem(Abexp('Not(B), some(E)), .K))) ... </k>
        <mem> E </mem>         
        //<niter> N => N +Int 1 </niter> 
      	[transition] 

syntax  K ::= "moveOnFromLoop" "(" K ")" [strict]

rule	<k> moveOnFromLoop(V:KResult) => . ... </k>
	<status> _ => NEXT </status>
 	//<niter> _ => 0 </niter> 
 	when notBool (valid(V)) 

rule    <k> moveOnFromLoop(V:KResult) => . ... </k>      
	<status> _ => LOOP </status>
 	//<niter> _ => 0 </niter>  
 	when valid(V)  




///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{For} */
///////////////////////////////////////////////////////////////////////////////

/*@ Alternate syntax desugared into standard for */

rule [alt-for]:
	<k> ('AltFor => 'For)(Init:K,,Guard:K,,Increment::K,,Body:K) ... </k>
	[structural]

/*@ same as while */

rule [for]: 	
	<k> ('For(Init:K,,'ListWrap(Guard:K),,Increment:K,,Body:K) ~> K:K)  =>
	pushLoopContext(loopFrame(K, none)) ~> 
	for(Init, 'ListWrap(Guard), Increment,'ListWrap(Body)) ~> 
	popLoopContext </k>
	<trace> Trace:List => Trace ListItem("for") </trace>
	[structural]


syntax K ::= "for" "(" K "," K "," K "," K ")"

/* TODO: broken after WHILE semantics has chnaged
rule [for-spec]: 	
	for(Init:K, 'ListWrap(Guard:K), Increment:K, Body:K) => 
	'ListWrap(
		makeForInit(Init),,
		while(
			Guard,
			'ListWrap(Body) ~> makeForInit(Increment))) 	
	[structural]
*/

syntax K ::= "makeForInit" "(" K ")"

rule makeForInit('ListWrap(.KList)) => .
rule makeForInit('ListWrap(I:K,,Is:KList)) => 'Expr(I) ~> makeForInit('ListWrap(Is))

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Switch} */
///////////////////////////////////////////////////////////////////////////////

// The alternative syntax is desugared into standard one

rule [alt-switch]: 	
	<k> 'AltSwitch(In:K,, Clauses:K) => 'Switch(In,, Clauses) ... </k>
	<trace> Trace:List => Trace ListItem("alt-switch") </trace>
	[structural]

// The guard of the switch statement is evaluated

context 'Switch(HOLE,, _)

// Note that the guard must be converted to integer!! (see PHP docs)

rule [switch-guard2LangValue]:
	<k> 'Switch((R:ConvertibleToLanguageValue => convertToLanguageValue(R)),,_) ... </k>
	<trace> Trace:List => Trace ListItem("switch-guard2LangValue") </trace>
	[intermediate]

rule [switch]:
	<k> 'Switch(In:KResult,, Clauses:K) ~> K  => 
		pushLoopContext(loopFrame(K, none)) ~> 
		switch(In, Clauses) ~> 
		popLoopContext </k>
	<trace> Trace:List => Trace ListItem("switch") </trace>
	[step]

syntax K ::= "switch" "(" K "," K ")"

// The following rule define the 'switch' construct:

context switch(V:Value,'ListWrap('Case(HOLE,,_,,_),,Cases:KList))

rule [switch-spec-default]:
	<k> switch(
		VIn:Value, 
		'ListWrap(
			'DefaultCase(":" ,,Stmt:K),, 
			Cases:KList)) 
		=> Stmt ~> runRemainingSwitchClauses('ListWrap(Cases)) ... </k>
	<trace> Trace:List => Trace ListItem("switch-spec-default") </trace>
	[internal]

rule [switch-spec-no-default]:
	<k> switch(
		VIn:Value, 
		'ListWrap(
			'Case(VCase:Value,, _ ,,Stmt:K),, 
			Cases:KList)) 
		=>
		'If(
			'IsEqual(VIn,, VCase),, 
			Stmt ~> runRemainingSwitchClauses('ListWrap(Cases)),,
			'ListWrap(.KList),,
			switch(VIn, 'ListWrap(Cases))) ... </k>
	<trace> Trace:List => Trace ListItem("switch-spec-no-default") </trace>
	[internal]
	
rule [switch-spec-nil]: 	
	<k> switch(_, 'ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("switch-spec-nil") </trace>
	[internal]

syntax K ::= "runRemainingSwitchClauses" "(" K ")"

rule [switch-spec-run-remaining-clauses]:
	<k> runRemainingSwitchClauses(
		'ListWrap(
			Case(_,,_,,Stmt),,
			Cases:KList
		)
	) =>
	Stmt ~> runRemainingSwitchClauses('ListWrap(Cases)) ... </k>
	<trace> Trace:List => Trace ListItem("switch-spec-run-remaining-clauses") </trace>
	[internal]

rule [switch-spec-run-remaining-clauses-nil]:
	<k> runRemainingSwitchClauses('ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("switch-spec-run-remaining-clauses-nil") </trace>
	[internal]


///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Do while} */
///////////////////////////////////////////////////////////////////////////////

rule [doWhile]: 	
	<k> 'DoWhile(Body:K,,Cond:K) => 'ListWrap(Body,,'While(Cond,,Body)) ... </k>
	<trace> Trace:List => Trace ListItem("doWhile") </trace>
	[structural]

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Foreach} */
///////////////////////////////////////////////////////////////////////////////

// Evaluate the first argument to foreach (the array or object to be iterated)

context 'ForEach(HOLE,, _:K,, _:K)

// if a reference is obtained, read the corresponding location

rule [foreach-arg2Loc]: 	
	<k> 'ForEach((R:ConvertibleToLoc => convertToLoc(R,r)),,_:K,,_:K) ... </k>
	<trace> Trace:List => Trace ListItem("foreach-arg2Loc") </trace>
	[intermediate]

rule [foreach-with-local-copy]: 	
	<k> ('ForEach(L':Loc,,Pattern:K,,Stmt:K) ~> K:K) => 
			write(V,Lx,true) ~> 
			pushLoopContext(loopFrame(K, foreachArrayPair(L',Lx))) ~> 
			foreach(Lx, Pattern, Stmt) ~>
			popLoopContext
	</k>
	<thematrix> ...  L' |-> L  ... </thematrix>		
	<heap> ... L |-> zval(V:Array,_,N,_) ... </heap>
	<currentForeachItem> _ => L' </currentForeachItem>
	<trace> Trace:List => Trace ListItem("foreach-with-local-copy") </trace>
	when ((V isCompoundValue) andBool (N <=Int 1) andBool (fresh(Lx:Loc)))
	[step]
	
rule [foreach-without-local-copy]: 	
	<k> ('ForEach(L':Loc,,Pattern:K,,Stmt:K) ~> K:K) => 
			write(V,Lx,true) ~> 
			pushLoopContext(loopFrame(K, foreachArrayPair(L', none))) ~> 
			foreach(Lx, Pattern, Stmt) ~>
			popLoopContext
	</k>
	<thematrix> ...  L' |-> L  ... </thematrix>		
	<heap> ... L |-> zval(V:Object,_,N,_) ... </heap>
	<currentForeachItem> _ => L' </currentForeachItem>
	<trace> Trace:List => Trace ListItem("foreach-without-local-copy") </trace>
	when ((V isCompoundValue) andBool (N <=Int 1) andBool (fresh(Lx:Loc)))
	[step]
	
rule [foreach]: 	
	<k> ('ForEach(L':Loc,,Pattern:K,,Stmt:K) ~> K:K) => 
			pushLoopContext(loopFrame(K, foreachArrayPair(L', none))) ~> 
			foreach(L', Pattern, Stmt) ~>
			popLoopContext
	</k>
	<heap> ... L |-> zval(V:Value,_,N,_) ... </heap>
	<thematrix> ...  L' |-> L  ... </thematrix>		
	<currentForeachItem> _ => L' </currentForeachItem>
	<trace> Trace:List => Trace ListItem("foreach") </trace>
	when ((V isCompoundValue) andBool (N >Int 1))
	[step]

// Error cases: invalid argument

rule [foreach-scalar-1]:
	<k> 'ForEach(L':Loc,,_) => 
		WARNING("Warning: Invalid argument supplied for foreach() in %s on line %d\n") ... </k>
	<thematrix> ...  L' |-> L  ... </thematrix>		
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("foreach-scalar-1") </trace>
	when notBool (V isCompoundValue)
	[step, error]

rule [foreach-scalar-2]:
	<k> 'ForEach(V:ScalarValue,,'Pattern(_),,Stmt:K) =>
		WARNING("Warning: Invalid argument supplied for foreach() in %s on line %d\n") ... </k>
	<trace> Trace:List => Trace ListItem("foreach-scalar-2") </trace>
	[step, error]

rule [foreach-locNull]:
	<k> 'ForEach(Arg:K,,'Pattern(_),,Stmt:K) =>
	WARNING("Warning: Invalid argument supplied for foreach() in %s on line %d\n") ... </k>
	<trace> Trace:List => Trace ListItem("foreach-locNull") </trace>
	when (Arg ==K locNull) 
	[step, error]


///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Internal definitions for foreach} */
///////////////////////////////////////////////////////////////////////////////

syntax K ::= "foreach" "(" Loc "," K "," K ")"  [strict(1)]

// TODO: replace 'crnt' with some variable name which will not interfere with 
//       user-defined variables

/* TODO: broken after WHILE rule changed
rule [foreach-spec]:
	<k> foreach(L:Loc, Pattern:K, Stmt:K) => 
		'ListWrap(
			'Expr(reset(L)),,
			'Expr('Assign('Variable('Simple("crnt")),,key(L))),,
			while('IsNotIdentical('False(.KList),,'Variable('Simple("crnt"))),
					*Cond(
						isCrntVisib(L),
						'ListWrap(
							initIterationVars(L,Pattern) ~> 
							'Expr(myNext(L)) ~> 
							'ListWrap('Expr('Assign('Variable('Simple("crnt")),,key(L)))) ~>
							Stmt,,
							'If(
								locHoldsCompoundValue(L),,
								'ListWrap(.KList),,
								'ListWrap(.KList),,
								(WARNING("Invalid argument supplied for foreach() in %s on line %d\n") ~> 'Break(1))
							)
						),
						'Expr(myNext(L)) ~> 
						'ListWrap('Expr('Assign('Variable('Simple("crnt")),,key(L))))
					)
				)	
		) ... </k>
		<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
		<currentForeachItem> L1:Loc </currentForeachItem>
	<trace> Trace:List => Trace ListItem("foreach-spec") </trace>
	when (V isCompoundValue)
	[internal]
*/

syntax K ::= "ArrayCrnt2None" "(" Loc ")"

rule 
	<k> ArrayCrnt2None(L') => . ... </k>
	<thematrix> ...  L' |-> L  ... </thematrix>		
	<heap>... L |-> zval(Array(_ => none,_),_,_,_)  ... </heap>
	
rule 
	<k> ArrayCrnt2None(L1') => . ... </k>
	<thematrix> 
	... 
		L1' |-> L1
		L'  |-> L  
	... 
	</thematrix>			
	<heap>
		... 
		L1 |-> zval(OID(L',_,_),_,_,_)
		L |-> zval(Array(_ => none,_),_,_,_)  
		... 
	</heap>

syntax K ::= "initIterationVars" "(" Loc "," K ")" 

rule [init-foreach-iteration-vars-value]:
	<k> initIterationVars(L,'Pattern('None(_),, X:K)) => 'Expr('Assign(X,,current(L))) ... </k>
	<trace> Trace:List => Trace ListItem("init-foreach-iteration-vars-value") </trace>
	when getKLabel(X) =/=KLabel 'Ref
	[internal]

rule [init-foreach-iteration-vars-value-ref]:
	<k> initIterationVars(L,'Pattern('None(_),,'Ref(X:K)) ) => 'Expr('ReferenceAssign(X,,current(L))) ... </k>
	<trace> Trace:List => Trace ListItem("init-foreach-iteration-vars-value-ref") </trace>
	[internal]

rule [init-foreach-iteration-vars-keyvalue]: 
	<k> initIterationVars(L, 'Pattern('Some('Key(K:K)),,V:K)) => 'Expr('Assign(V,,current(L))) ~> 'Expr('Assign(K,,key(L))) ... </k>
	<trace> Trace:List => Trace ListItem("init-foreach-iteration-vars-keyvalue") </trace>
	when (getKLabel(V) =/=KLabel 'Ref) andBool (getKLabel(K) =/=KLabel 'Ref)
	[internal]

rule [init-foreach-iteration-vars-keyvalue-ref]:
	<k> initIterationVars(L, 'Pattern('Some('Key(K:K)),,'Ref(V:K))) => 'Expr('Assign(K,, key(L))) ~> 'Expr('ReferenceAssign(V,,'ArrayAccess(L,, K))) ... </k>
	<trace> Trace:List => Trace ListItem("init-foreach-iteration-vars-keyvalue-ref") </trace>
	when getKLabel(K) =/=KLabel 'Ref
	[internal]
	
rule [init-foreach-iteration-vars-keyvalue-ref-error]:
	<k> initIterationVars(L, 'Pattern('Some('Key('Ref(K:K))),,_)) => ERROR("Key element cannot be a reference in %s on line $d\n") ... </k>
	<trace> Trace:List => Trace ListItem("init-foreach-iteration-vars-keyvalue-ref-error") </trace>
	[internal]

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Control flow auxiliary operations} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Checking if the value being iterated is an object or array} 
		Such control is made at the beginning of the 'foreach' loop, producing an error 
		if trying to iterate over a scalar value. 
		However, the value being iterated might be changed at runtime, during the execution
		of the 'foreach' body. 
		For this reason we basically need to check wether the iterated value is a compound 
		value at every iteration. The boolean function below makes this check. */
// ---------------------------------------------------------------------------------------------

syntax K ::= "locHoldsCompoundValue" "(" Loc ")" 

rule [loc-holds-compound-value-true]:
	<k> locHoldsCompoundValue(L') => true ... </k>
	<thematrix> ...  L' |-> L  ... </thematrix>			
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("loc-holds-compound-value-true") </trace>
	when (isArrayType(V) orBool isObjectType(V))
	[internal]

rule [loc-holds-compound-value-false]:
	<k> locHoldsCompoundValue(L') => false ... </k>
	<thematrix> ...  L' |-> L  ... </thematrix>			
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("loc-holds-compound-value-false") </trace>
	when notBool (isArrayType(V) orBool isObjectType(V))
	[internal]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Auxiliary operations for loop stack manipulation} 
		The following macros simply push or pop a frame in the loop stack. */
// ---------------------------------------------------------------------------------------------

syntax K ::= "pushLoopContext" "(" K ")"  

rule [push-loop-cntx]: 	
	<k> pushLoopContext(K:LoopFrame) => .K ... </k>
	<loopStack> . => ListItem(K) ... </loopStack>
	<trace> Trace:List => Trace ListItem("push-loop-cntx") </trace>
	[internal]

syntax K ::= "popLoopContext"

rule [pop-loop-cntx-normal]:    
	<k> popLoopContext => K ... </k>
	<loopStack> ListItem(loopFrame(K:K,none)) => .List ... </loopStack>
	<trace> Trace:List => Trace ListItem("pop-loop-cntx-normal") </trace>
	[internal]
	
rule [pop-loop-cntx-special]:    
	<k> popLoopContext => syncArrayCurrent(Lorig, Llocal) ~> K ... </k>
	<loopStack> ListItem(loopFrame(K:K,foreachArrayPair(Lorig, Llocal))) => .List ... </loopStack>
	<trace> Trace:List => Trace ListItem("pop-loop-cntx-special") </trace>
	[internal]


syntax K ::= "syncArrayCurrent" "(" Loc "," OptionLoc ")"

rule [syncArrayCurrent-some]: 
	<k> syncArrayCurrent(Lorig', Llocal':Loc) => . ... </k>
	<thematrix> 
	...  
		Lorig' |-> Lorig
		Llocal' |-> Llocal  
	... 
	</thematrix>		
	
	<heap> 
	...
		Lorig |-> zval(Array(_ => Crnt,_),_,_,_)
		Llocal |-> zval(Array(Crnt,_),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("syncArrayCurrent-some") </trace>
	[internal]
	
rule [syncArrayCurrent-none]: 
	<k> syncArrayCurrent(Lorig, none) => . ... </k>
	<trace> Trace:List => Trace ListItem("syncArrayCurrent-none") </trace>
	[internal]

	

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Checking if the current element has been unset in the body} 
		When the current element is unset in the foreach body, the current pointer 
		needs not to be advanced at the end of the iteration. 
		In order to do that we keep a boolean flag in each loop frame. The flag is false
		when the loop starts but during execution might be set to true by other operations
		(e.g. unset) when such a situation is detected.
		In foreach, when such control returns true, we avoid advancing the current 
		pointer for the current iteration. */
// ---------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Checking if the current element is visible} 
		We desugar foreach into a while loop using 'current' and 'next' language operations, 
		which by default iterate over ALL properties of the object, visible or not, while
		'foreach' only shows the visible properties. 
		We achieve this behaviour by iterating over all the properties but showing only 
		the visible ones, by using the guard defined below. */ 
// ---------------------------------------------------------------------------------------------

syntax K ::= "isCrntVisib" "(" Loc ")"

rule [is-crnt-visib-array]:
	<k> isCrntVisib(L':Loc) => true ... </k>
	<thematrix> ...  L' |-> L  ... </thematrix>		
	<heap> ... L  |-> zval(V:Array,_,_,_) ... </heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-array") </trace>
	[internal]

rule [is-crnt-visib-obj-public]:
	<k> isCrntVisib(L':Loc) => true ... </k>
	<thematrix> 
	...  
		L'  |-> L
		L1' |-> L1 
	... 
	</thematrix>		
	<heap>
	...
		L  |-> zval(OID(L1':Loc,_,_),_,_,_)
		L1 |-> zval(Array([_,public],_),_,_,_)
	...
	</heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-obj-public") </trace>
	[internal]
		
rule [is-crnt-visib-obj-protected]: 	
	<k> isCrntVisib(L':Loc) => isVisible(ObjClass, Context, protected) ... </k>
	<class> Context:K </class>
	<thematrix> 
	...  
		L'  |-> L
		L1' |-> L1 
	... 
	</thematrix>
	<heap>
	...
		L  |-> zval(OID(L1':Loc,ObjClass,_),_,_,_)
		L1 |-> zval(Array([_,protected],_),_,_,_)
	...
	</heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-obj-protected") </trace>
	[internal]
		
rule [is-crnt-visib-obj-private-true]:
	<k> isCrntVisib(L':Loc) => true ... </k>
	<class> Context:K </class>
	<thematrix> 
	...  
		L'  |-> L
		L1' |-> L1 
	... 
	</thematrix>	
	<heap>
	...
		L  |-> zval(OID(L1':Loc,_,_),_,_,_)
		L1 |-> zval(Array([_,private(Context)],_),_,_,_)
	...
	</heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-obj-private-true") </trace>
	[internal]
	
rule [is-crnt-visib-obj-private-false]:
	<k> isCrntVisib(L':Loc) => false ... </k>	
	<class> Context:K </class>
	<thematrix> 
	...  
		L'  |-> L
		L1' |-> L1 
	... 
	</thematrix>
	<heap>
	...
		L  |-> zval(OID(L1':Loc,ObjClass,_),_,_,_)
		L1 |-> zval(Array([_,private(Owner:Id)],_),_,_,_)
	...
	</heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-obj-private-false") </trace>
	when (Context =/=K Owner)
	[internal]


endmodule 
