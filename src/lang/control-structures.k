require "shared.k"

module CONTROL-STRUCTURES 
    imports SHARED

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Control flow structures} 
		We define here the control flow constructs of the language. We give a semantics
		for if and while, and for the remaining constructs we use a desugaring approach. */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{If} */
// ---------------------------------------------------------------------------------------------

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

/*
rule    [if]:	
    <k> if (C:Exp) then B1:Block else B2:Block => 
			    mergeConfigs(
				    runAndGetConfig(runInMem(Abexp(norm(C), some(E)), B1)),
				    runAndGetConfig(runInMem(Abexp(norm(!C), some(E)), B2))) ... </k>
            <mem> E </mem>
            [transition]
*/

rule    [if-yeah]:	
        <k> 'If(C,,B1,,'ListWrap(.KList),,B2) => 
			    mergeConfigs(
				    runAndGetConfig(runInMem(Abexp(C, some(E)), B1)),
				    runAndGetConfig(runInMem(Abexp('Not(C), some(E)), B2))) ... </k>
        <mem> E </mem>

/* NOTE: this is the old semantics of IF. TODO: replace when done with new one. 
rule [if-true-1]:	
	<k> 'If(true,,S:K,,X:K,,Y:K) => S ... </k>
	<trace> Trace:List => Trace ListItem("if-true-1") </trace>
	[step]
	
rule [if-true-2]:	
	<k> 'If(true,,S:K,,X:K) => S ... </k>
	<trace> Trace:List => Trace ListItem("if-true-2") </trace>
	[step]

rule [if-false]:	
	<k> 'If(false,,_,,'ListWrap(.KList),,S:K) => S ... </k>
	<trace> Trace:List => Trace ListItem("if-false") </trace>
	[step]

rule [if-false-elseIf-1]:
	<k> 'If(false,,_,,'ListWrap('ElseIf(Guard:K,, Stmt:K),, ElseIfs:KList),,S:K) => 
	'If(Guard,, Stmt,, 'ListWrap(ElseIfs),, S) ... </k>
	<trace> Trace:List => Trace ListItem("if-false-elseIf-1") </trace>
	[step]

rule [if-false-elseIf-2]:
	<k> 'If(false,,Z:K,,'ListWrap('ElseIf(Guard:K,, Stmt:K),, ElseIfs:KList)) => 
	'If(false,,Z,,'ListWrap('ElseIf(Guard,, Stmt),, ElseIfs),,'ListWrap(.KList)) ... </k>
	<trace> Trace:List => Trace ListItem("if-false-elseIf-2") </trace>
	[step]
*/
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{Conditional Expression} 
		The conditional expression is desugared into an if statement. */
// ---------------------------------------------------------------------------------------------

rule [ternary]: 	
	<k> 'Ternary(Guard:K,, T:K,, F:K) => 'If(Guard,, T,, 'ListWrap(.KList),, F) ... </k>
	<trace> Trace:List => Trace ListItem("ternary") </trace>
	[structural]

/*---------------------------------------------------------------------------------------------
\subsection{Break}
----------------------------------------------------------------------------------------------*/

// Break takes an optional argument, which is the number of levels to break. In case
// no arg is provided, the default value is 1 - i.e. the break is performed on the inner
// loop.

rule [break-none]: 	
	<k> 'Break( ('None(_) => 'Some(1)) ) ... </k>
	<trace> Trace:List => Trace ListItem("break-none") </trace>
	[structural]
 
// Since the argument can be a complex expression, it must be evaluated first 

context 'Break('Some(HOLE))

// In case we got something which is not a simple value, we try to obtain the value...

rule [break-arg2LangValue]: 	
	<k> 'Break('Some(R:ConvertibleToLanguageValue => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("break-arg2LangValue") </trace>
	[intermediate] 

// ... and get rid of the Some constructor, just for convenience

rule [break-some]: 	
	<k> 'Break('Some(Steps:Int)) => 'Break(Steps) ... </k>
	<trace> Trace:List => Trace ListItem("break-some") </trace>
	[structural]

// Here we finally give the semantics for Break

rule [break-n]: 	
	<k> 'Break(NSteps => NSteps -Int 1) ... </k>
	<loopStack> ListItem(K) => .List ... </loopStack>
	<trace> Trace:List => Trace ListItem("break-n") </trace>
	when NSteps >Int 1
	[intermediate]

rule [break-1-normal]:
	<k> 'Break(1) ~> _ => K </k>
	<loopStack> ListItem(loopFrame(K,none)) => .List ... </loopStack>
	<trace> Trace:List => Trace ListItem("break-1-normal") </trace>
	[step]
	
rule [break-1-special-some]:
	<k> 'Break(1) ~> _ => syncArrayCurrent(Lorig, Llocal) ~> K </k>
	<loopStack> ListItem(loopFrame(K:K,foreachArrayPair(Lorig, Llocal))) => .List ... </loopStack>
	<trace> Trace:List => Trace ListItem("break-1-special-some") </trace>
	[step]
	
/*---------------------------------------------------------------------------------------------
\subsection{Continue}
----------------------------------------------------------------------------------------------*/

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

// ---------------------------------------------------------------------------------------------
/*@ \subsection{While} */
// ---------------------------------------------------------------------------------------------

/*@ The alternate syntax is desugared into standard while */

rule [alt-while]:  
	<k> 'AltWhile(G:K,,B:K) => 'While(G,,B)	... </k>
	<trace> Trace:List => Trace ListItem("alt-while") </trace>
	[structural]









/*@ In order to allow the use of break, we need to push an item in the loop stack 
	at the beginning of the loop, and pop it when it's done. We do this with the 
	following rule. Note that the actual semantics of while is give in the next rule, 
	which is an internal operation. */

/* NOTE: this is the old definition of WHILE
rule [while]: 	
	<k> 'While(Cond:K,, Body:K) ~> K:K =>
	pushLoopContext(loopFrame(K,none)) ~> 
	while(Cond, Body) ~> 
	popLoopContext ... </k>
	<trace> Trace:List => Trace ListItem("while") </trace>
	[step]

// Internal operation modelling the semantics of while.

syntax K ::= "while" "(" K "," K ")"

rule [while-spec]: 	
	<k> while(Condition:K, Body:K) =>
	'If(
		Condition,, 
		'ListWrap(Body,, while(Condition, Body )),,
		'ListWrap(.KList),,
		'ListWrap(.KList)
	) ... </k>
	<trace> Trace:List => Trace ListItem("while-spec") </trace>
	[structural]
*/


// WHILE semantics adapted from the IMP analyser

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







// ---------------------------------------------------------------------------------------------
/*@ \subsection{For} 
		For is desugared into while. */
// ---------------------------------------------------------------------------------------------

/*@ Alternate syntax desugared into standard for */

rule [alt-for]:
	<k> ('AltFor => 'For)(Init:K,,Guard:K,,Increment::K,,Body:K) ... </k>
	<trace> Trace:List => Trace ListItem("alt-for") </trace>
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

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Switch} */
// ---------------------------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Do-while} 
		Do-while is simply desugared into a while. */
// ---------------------------------------------------------------------------------------------

rule [doWhile]: 	
	<k> 'DoWhile(Body:K,,Cond:K) => 'ListWrap(Body,,'While(Cond,,Body)) ... </k>
	<trace> Trace:List => Trace ListItem("doWhile") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Foreach} */
// ---------------------------------------------------------------------------------------------

// Evaluate the first argument to foreach (the array or object to be iterated)

context 'ForEach(HOLE,, _:K,, _:K)

// if a reference is obtained, read the corresponding location

rule [foreach-arg2Loc]: 	
	<k> 'ForEach((R:ConvertibleToLoc => convertToLoc(R,r)),,_:K,,_:K) ... </k>
	<trace> Trace:List => Trace ListItem("foreach-arg2Loc") </trace>
	[intermediate]


rule [foreach-with-local-copy]: 	
	<k> ('ForEach(L:Loc,,Pattern:K,,Stmt:K) ~> K:K) => 
			write(V,Lx) ~> 
			pushLoopContext(loopFrame(K, foreachArrayPair(L,Lx))) ~> 
			foreach(Lx, Pattern, Stmt) ~>
			popLoopContext
	</k>
	<heap> ... L |-> zval(V:Array,_,N,_) ... </heap>
	<currentForeachItem> _ => L </currentForeachItem>
	<trace> Trace:List => Trace ListItem("foreach-with-local-copy") </trace>
	when ((V isCompoundValue) andBool (N <=Int 1) andBool (fresh(Lx:Loc)))
	[step]
	
rule [foreach-without-local-copy]: 	
	<k> ('ForEach(L:Loc,,Pattern:K,,Stmt:K) ~> K:K) => 
			write(V,Lx) ~> 
			pushLoopContext(loopFrame(K, foreachArrayPair(L, none))) ~> 
			foreach(Lx, Pattern, Stmt) ~>
			popLoopContext
	</k>
	<heap> ... L |-> zval(V:Object,_,N,_) ... </heap>
	<currentForeachItem> _ => L </currentForeachItem>
	<trace> Trace:List => Trace ListItem("foreach-without-local-copy") </trace>
	when ((V isCompoundValue) andBool (N <=Int 1) andBool (fresh(Lx:Loc)))
	[step]

	
rule [foreach]: 	
	<k> ('ForEach(L:Loc,,Pattern:K,,Stmt:K) ~> K:K) => 
			pushLoopContext(loopFrame(K, foreachArrayPair(L, none))) ~> 
			foreach(L, Pattern, Stmt) ~>
			popLoopContext
	</k>
	<heap> ... L |-> zval(V:Value,_,N,_) ... </heap>
	<currentForeachItem> _ => L </currentForeachItem>
	<trace> Trace:List => Trace ListItem("foreach") </trace>
	when ((V isCompoundValue) andBool (N >Int 1))
	[step]

// Error cases: invalid argument

rule [foreach-scalar-1]:
	<k> 'ForEach(L:Loc,,_) => 
		WARNING("Warning: Invalid argument supplied for foreach() in %s on line %d\n") ... </k>
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

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Internal operations for foreach} */
// ---------------------------------------------------------------------------------------------

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
	<k> ArrayCrnt2None(L) => . ... </k>
	<heap>... L |-> zval(Array(_ => none,_),_,_,_)  ... </heap>
	
rule 
	<k> ArrayCrnt2None(L1) => . ... </k>
	<heap>
		... 
		L1 |-> zval(OID(L,_,_),_,_,_)
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
	<k> locHoldsCompoundValue(L) => true ... </k>
	<heap> ... L |-> zval(V:Value,_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("loc-holds-compound-value-true") </trace>
	when (isArrayType(V) orBool isObjectType(V))
	[internal]

rule [loc-holds-compound-value-false]:
	<k> locHoldsCompoundValue(L) => false ... </k>
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
	<k> syncArrayCurrent(Lorig, Llocal:Loc) => . ... </k>
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
	<k> isCrntVisib(L:Loc) => true ... </k>
	<heap> ... L  |-> zval(V:Array,_,_,_) ... </heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-array") </trace>
	[internal]

rule [is-crnt-visib-obj-public]:
	<k> isCrntVisib(L:Loc) => true ... </k>
	<heap>
	...
		L  |-> zval(OID(L1:Loc,_,_),_,_,_)
		L1 |-> zval(Array([_,public],_),_,_,_)
	...
	</heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-obj-public") </trace>
	[internal]
		
rule [is-crnt-visib-obj-protected]: 	
	<k> isCrntVisib(L:Loc) => isVisible(ObjClass, Context, protected) ... </k>
	<class> Context:K </class>
	<heap>
	...
		L  |-> zval(OID(L1:Loc,ObjClass,_),_,_,_)
		L1 |-> zval(Array([_,protected],_),_,_,_)
	...
	</heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-obj-protected") </trace>
	[internal]
		
rule [is-crnt-visib-obj-private-true]:
	<k> isCrntVisib(L:Loc) => true ... </k>
	<class> Context:K </class>
	<heap>
	...
		L  |-> zval(OID(L1:Loc,_,_),_,_,_)
		L1 |-> zval(Array([_,private(Context)],_),_,_,_)
	...
	</heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-obj-private-true") </trace>
	[internal]
	
rule [is-crnt-visib-obj-private-false]:
	<k> isCrntVisib(L:Loc) => false ... </k>	
	<class> Context:K </class>
	<heap>
	...
		L  |-> zval(OID(L1:Loc,ObjClass,_),_,_,_)
		L1 |-> zval(Array([_,private(Owner:Id)],_),_,_,_)
	...
	</heap> 
	<trace> Trace:List => Trace ListItem("is-crnt-visib-obj-private-false") </trace>
	when (Context =/=K Owner)
	[internal]


///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Merging configurations} */
///////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    // Merging entry point, Special cases.
    ///////////////////////////////////////////////////////////////////////////

    syntax  K ::= "mergeConfigs" "(" BoxedConfig "," BoxedConfig ")"         [strict(1,2)] 

    /*@ Adaptive-merge case. This happens when one branch returned 
    but the other didn't. See notes. */

/*  TODO (when POP is disambiguated)
    rule    (mergeConfigs(config(A), config(B)) ~> K => 
                #if (K =/=K .K) #then 
                    mergeConfigs(config(A), runAndGetConfig(runInConf(config(B),K)))
                #else
                    mergeConfigsBase(config(A), config(B))       
                #fi) ~> POP(_)
            when (configGetStatus(A) ==K RET) andBool (configGetStatus(B) ==K NEXT)
            [transition]

    rule    (mergeConfigs(config(A), config(B)) ~> K => 
                #if (K =/=K .K) #then 
                    mergeConfigs(runAndGetConfig(runInConf(config(A),K)),config(B))
                #else
                    mergeConfigsBase(config(A), config(B))       
                #fi
                ) ~> POP(_)
            when (configGetStatus(A) ==K NEXT) andBool (configGetStatus(B) ==K RET)
            [transition]       
*/
    /*@ This is misleading. It doesn't mean DONE. This is the case when 
    one branch is not executed at all. Should find better naming. */

    rule    mergeConfigs(config(A),config(B)) => updateConfig(config(A)) 
            when (configGetStatus(B) ==K DONE)
            [transition]

    rule    mergeConfigs(config(A),config(B)) => updateConfig(config(B)) 
            when (configGetStatus(A) ==K DONE)
            [transition]

    rule    mergeConfigs(config(A), config(B)) => mergeConfigsBase(config(A),config(B))
            when  notBool isSpecialMergeCase(configGetStatus(A),configGetStatus(B))  
		[transition]
 
    //@ decide wether our merging task is special or not
    syntax Bool ::= "isSpecialMergeCase" "(" ReturnCode "," ReturnCode ")" [predicate]

    rule    isSpecialMergeCase(St1,St2) => ((St1 ==K DONE) orBool (St2 ==K DONE))



    syntax K ::= "mergeConfigsBase" "(" BoxedConfig "," BoxedConfig ")"     [strict(1,2)]


/*
    rule    mergeConfigsBase(
                config( 
                    <functions> F1 </functions>
                    <IO>
                        <in> In1 </in>
                        <out> Out1 </out>
                    </IO>
                    <context>                   
                        <mem> M1 </mem>
                        <status> St1 </status>
                        <returns> R1 </returns> 
                        <errors> Er1 </errors> 
                        <stack> S1 </stack>
                        <xstack> XS1 </xstack> 
                        <niter> N1 </niter>
                    </context>),
               config(
                    <functions> F2 </functions>
                    <IO>
                        <in> In2 </in>
                        <out> Out2 </out>
                    </IO>
                    <context>
                        <mem> M2 </mem>
                        <status> St2 </status>
                        <returns> R2 </returns> 
                        <errors> Er2 </errors>
                        <stack> S2 </stack>
                        <xstack> XS2 </xstack>
                        <niter> N2 </niter>
                    </context>)) =>
                updateConfig(config(
                    <functions> mergeFunctions(F1,F2) </functions>
                    <IO>
                        <in> In1 </in>
                        <out> Out1 </out>
                    </IO>
                    <context>                   
                        <mem> mergeMem(N1,M1,M2) </mem>
                        <status> mergeStatus(St1,St2) </status>
                        <returns> mergeReturns(R1,R2) </returns> 
                        <errors> mergeErrors(Er1,Er2) </errors>
                        <stack> mergeStack(S1,S2) </stack>
                        <xstack> mergeXStack(XS1,XS2) </xstack>
                        <niter> mergeNIter(N1,N2) </niter>
                    </context>))                  
                    [transition]
*/

    rule    mergeConfigsBase(
                config( 
                        C1:Bag
			<returns> R1 </returns>  
			<status> S1 </status> 	                 
                        <mem> M1 </mem>),
                config(
                        C2:Bag
			<returns> R2 </returns> 	
			<status> S2 </status> 	
                        <mem> M2 </mem>)) =>

                updateConfig(config(
                        C1 // TODO: add other stuff  
			<returns> mergeReturns(R1,R2) </returns> 
			<status> mergeStatus(S1,S2) </status>
                        <mem> mergeMem(0,M1,M2) </mem>))                  
                    [transition]


    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsection{Merging the status cell} */
    ///////////////////////////////////////////////////////////////////////////

    //@ Merging of return codes
    syntax ReturnCode ::= "mergeStatus" "(" ReturnCode "," ReturnCode ")" [function]

    rule    mergeStatus(NEXT,NEXT)  => NEXT
    rule    mergeStatus(RET,RET)    => RET
    rule    mergeStatus(NEXT,DONE)  => NEXT
    rule    mergeStatus(DONE,NEXT)  => NEXT
    rule    mergeStatus(RET,NEXT)   => NEXT
    rule    mergeStatus(NEXT,RET)   => NEXT
    rule    mergeStatus(NEXT,ERR)   => NEXT
    rule    mergeStatus(ERR,NEXT)   => NEXT
    rule    mergeStatus(ERR,ERR)    => ERR
    // are we sure?
    rule    mergeStatus(ERR,RET)    => RET
    rule    mergeStatus(RET,ERR)    => RET
    // ...


    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsection{Merging returns} */
    ///////////////////////////////////////////////////////////////////////////

    syntax  K ::= "mergeReturns" "(" K "," K ")"         [function] 
    rule    mergeReturns(V1, V2) => lub(V1,V2)

    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsection{Merging memories} */
    ///////////////////////////////////////////////////////////////////////////


    syntax  Bag ::= "mergeMem" "(" Int ","Bag "," Bag ")"       [function]

    rule    mergeMem(_,
                <scopes> 
                    <currentScope> L1 </currentScope>
                    <globalScope> L2 </globalScope>
                    <globalStaticScope> L3 </globalStaticScope>
                    <superGlobalScope> L4 </superGlobalScope> 
                </scopes> 
                <heap> H1 </heap>,

                <scopes> 
                    <currentScope> L1' </currentScope>
                    <globalScope> L2' </globalScope>
                    <globalStaticScope> L3' </globalStaticScope>
                    <superGlobalScope> L4' </superGlobalScope>   
                </scopes> 
                <heap> H2 </heap>) => 

                <scopes>
                    <currentScope> L1 </currentScope>
                    <globalScope> L2 </globalScope>
                    <globalStaticScope> L3 </globalStaticScope>
                    <superGlobalScope> L4 </superGlobalScope>  
                </scopes>
                <heap>
                	mergeArray(L4,heap_read(H1,L4),H1,heap_read(H2,L4'),H2,.List,.Map)
                    	mergeArray(L3,heap_read(H1,L3),H1,heap_read(H2,L3'),H2,.List,.Map)
		        mergeArray(L1,heap_read(H1,L1),H1,heap_read(H2,L1'),H2,.List,.Map)
		
                </heap>
		//when (L1 =/=K L2) 

    // TODO: factorise with prevuous case using a conditional!!!
/*
    rule    mergeMem(_,
                <scopes> 
                    <currentScope> L1 </currentScope>
                    <globalScope> L2 </globalScope>
                    <globalStaticScope> L3 </globalStaticScope>
                    <superGlobalScope> L4 </superGlobalScope> 
                </scopes> 
                <heap> H1 </heap>,

                <scopes> 
                    <currentScope> L1' </currentScope>
                    <globalScope> L2' </globalScope>
                    <globalStaticScope> L3' </globalStaticScope>
                    <superGlobalScope> L4' </superGlobalScope>   
                </scopes> 
                <heap> H2 </heap>) => 

                <scopes>
                    <currentScope> L1 </currentScope>
                    <globalScope> L2 </globalScope>
                    <globalStaticScope> L3 </globalStaticScope>
                    <superGlobalScope> L4 </superGlobalScope>  
                </scopes>
                <heap>
		mergeArray(L1,heap_read(H1,L1),H1,heap_read(H2,L1'),H2,.List,.Map)
	
		
		    mapUnion( 
                    mergeArray(L4,heap_read(H1,L4),H1,heap_read(H2,L4'),H2,.List,.Map),
                    mergeArray(L3,heap_read(H1,L3),H1,heap_read(H2,L3'),H2,.List,.Map))
		    //mergeArray(L1,heap_read(H1,L1),H1,heap_read(H2,L1'),H2,.List,.Map)
		
                </heap>
		when (L1 ==K L2) 
*/


    ///////////////////////////////////////////////////////////////////////////
    // Merge
    ///////////////////////////////////////////////////////////////////////////

    syntax  Bool ::= "isScalar_zval" "(" Zval ")" [predicate]

    rule    isScalar_zval(zval(V,_,_,_)) => isScalarValue(V)
    

    syntax  Map ::= "mergeArray" "(" Loc "," Zval "," Map "," Zval "," Map "," List "," Map ")" [function]

    rule    mergeArray(L,
                zval(Array(_,A1),_,_,_),
                H1,
                zval(Array(_,A2),_,_,_),
                H2,                
                A,
                H) => mergeArray1(L,A1,H1,A2,H2,A,H)

    syntax  Map ::= "mergeArray1" "(" Loc "," List "," Map "," List "," Map "," List "," Map ")" [function]
            
    // base case
    // TODO: should merge the 2 heaps (as done in IMP)? 
    rule    mergeArray1(L,.List,M1,.List,M2,A,H) => 
                (L |-> zval(Array(head(A),A),array,1,false)) mapUnion(H,M1)

    // field exists only in one of the two arrays, scalar case 

    rule   mergeArray1(L,
                ListItem([X,Vis,L1]) M1,
                (L1 |-> V1) S1,
                M2,S2,V,S) => 
            mergeArray1(L,M1,S1,M2,S2,
                ListItem([X,Vis,N]) V,
                (N |-> V1) S)
            when (notBool (M2 hasProperty X)) andBool 
                 isScalar_zval(V1) andBool
                 fresh(N:Loc) 

    rule   mergeArray1(L,
                M1,S1,
                ListItem([X,Vis,L2]) M2,
                (L2 |-> V2) S2,
                V,S)=> 
            mergeArray1(L,M1,S1,M2,S2,
                ListItem([X,Vis,N]) V,
                (N |-> V2) S)
            when (notBool (M1 hasProperty X)) andBool 
                 isScalar_zval(V2) andBool
                 fresh(N:Loc)

    // field exists only in one of the two arrays, array case 

    rule   mergeArray1(L,
                ListItem([X,Vis,L1]) M1,
                (L1 |-> Array(_,V1)) S1,
                M2,S2,V,S) => 
            mergeArray1(L,M1,S1,M2,S2,
                ListItem([X,Vis,N]) V,
                mergeArray1(N,V1,S1,.List,.Map,.List,.Map) S)
            when (notBool (M2 hasProperty X)) andBool
                 fresh(N:Loc)

    rule   mergeArray1(L,
                M1,S1,
                ListItem([X,Vis,L2]) M2,
                (L2 |-> Array(_,V2)) S2,
                V,S)=> 
            mergeArray1(L,M1,S1,M2,S2,
                ListItem([X,Vis,N]) V,
                mergeArray1(N,V2,S2,.List,.Map,.List,.Map) S)
            when (notBool (M1 hasProperty X)) andBool
                 fresh(N:Loc)

    // field exists in both arrays

/* OLD
    rule    mergeArray1(L,
                ListItem([X,Vis,L1]) M1,
                (L1 |-> V1) S1,
                M2, 
                S2,
                V,S) => 

            mergeArray1(L,M1,(L1 |-> V1) S1,(arrayRemove(M2,X)),S2,
                ListItem(merge_ArrayItem(N,[X,Vis,L1],array_read(M2,X))) V,
                mergeZval(N,V1,(L1 |-> V1) S1,heap_read(S2,array_read_v(M2,X)),S2) S)
            when (M2 hasProperty X) andBool (fresh(N:Loc))
*/


    rule    mergeArray1(L,
                ListItem([X,Vis,L1]) M1,
                (L1 |-> V1) S1,
                M2, 
                S2,
                V,S) => 

            mergeArray1(L,M1,(L1 |-> V1) S1,(arrayRemove(M2,X)),S2,
                V ListItem(merge_ArrayItem(L1,[X,Vis,L1],array_read(M2,X))),
                mergeZval(L1,V1,(L1 |-> V1) S1,heap_read(S2,array_read_v(M2,X)),S2) S)
            when (M2 hasProperty X) //andBool (fresh(N:Loc))



    // merges two "array entries" (TODO properly)
    syntax  ArrayItem ::= "merge_ArrayItem" "(" Loc "," ArrayItem "," ArrayItem ")" [function]

    rule    merge_ArrayItem(L,[X,V1,_],[X,V2,_]) => [X,V1,L]
                        
    // merges two zvals V1 and V2, then creates the entry L |-> lub(V1,V2)
    syntax  Map ::= "mergeZval" "(" Loc "," Zval "," Map "," Zval "," Map ")" [function]

    // scalar case
    rule    mergeZval(L,zval(V,T,R,I),_,zval(V',T',R',I'),_) => (L |-> zval(lub(V,V'),T,R,I))  
            when (isScalarValue(V) ==K true) orBool (isScalarValue(V') ==K true)

    // array case
    rule    mergeZval(L,zval(Array(_,V.),T,R,I),H1,zval(Array(_,V'),T',R',I'),H2) => 
                mergeArray1(L,V,H1,V',H2,.List,.Map)

endmodule 
