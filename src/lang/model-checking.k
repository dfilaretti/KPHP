require "memory.k"
require "builtins/model-checker.k"

module MODEL-CHECKING
	imports MEMORY
	imports LTL-HOOKS
  	imports MODEL-CHECKER-HOOKS

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Model checking} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=  

  syntax K ::= LtlFormula

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Logic Language} */
// ---------------------------------------------------------------------------------------------

syntax KeyList ::= List{Key,","}

syntax Exp ::= "gv" "(" Variable ")"
			 | "fv" "(" String "," Variable ")"
			 | "val" "(" LanguageValue ")"
			 | "len" "(" Exp ")"
			// | Exp "+" Exp [strict] // LATER
			 
syntax Variable ::= "variable" "(" Key ")"
			 	  | "array" "(" KeyList ")"

// ---------------------------------------------------------------------------------------------
/*@ \subsection{gettype} */
// ---------------------------------------------------------------------------------------------

syntax Type ::= "type" "(" LanguageValue ")" [function]

rule type(V:Int) => int
rule type(V:Bool) => bool
rule type(V:Float) => float
rule type(V:String) => string
rule type(V:Array) => array
rule type(V:Object) => object
rule type(NULL) => unset

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Propositions} */
// ---------------------------------------------------------------------------------------------

syntax Prop ::= "eqTo" "(" Exp "," Exp ")"
rule B:Bag |=Ltl eqTo(E1:Exp, E2:Exp) => true when expEval(B, E1) ==K expEval(B, E2) [anywhere]       

syntax Prop ::=  "lab" "(" String ")"
rule B:Bag |=Ltl lab(X:String) => true when get_config_label(B) ==String X 			[anywhere]

syntax Prop ::= "alias" "(" Exp "," Exp ")"	
rule B:Bag |=Ltl alias(E1:Exp, E2:Exp) => true when expEvalLoc(B, E1) ==K expEvalLoc(B, E2) [anywhere]       

syntax Prop ::= "hasType" "(" Exp "," Type ")"
rule B:Bag |=Ltl hasType(E:Exp, T:Type) => true when type(expEval(B,E)) ==K T [anywhere]       

syntax Prop ::= "geq" "(" Exp "," Exp ")"
rule B:Bag |=Ltl geq(E1:Exp, E2:Exp) => true when geqVal(expEval(B, E1), expEval(B, E2)) [anywhere]             

syntax Prop ::= "leq" "(" Exp "," Exp ")"
rule B:Bag |=Ltl leq(E1:Exp, E2:Exp) => true when leqVal(expEval(B, E1), expEval(B, E2)) [anywhere]             

syntax Prop ::= "inFun" "(" String ")"
rule B:Bag |=Ltl inFun(X:String) => true when get_crnt_fun(B) ==String X 			[anywhere]

syntax Bool ::= "geqVal" "(" LanguageValue "," LanguageValue ")" [function]

rule geqVal(V1:Int, V2:Int) => V1 >=Int V2

syntax Bool ::= "leqVal" "(" LanguageValue "," LanguageValue ")" [function]

rule leqVal(V1:Int, V2:Int) => V1 <=Int V2

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Evaluation function for expressions} */
// ---------------------------------------------------------------------------------------------

syntax LanguageValue ::= "expEval" "(" Bag "," Exp ")"	 				[function]

rule expEval(B, gv(X:Variable)) => read(B, lookup_glob(B, X))
rule expEval(B, fv(FName, X:Variable)) => read(B, lookup_fun(B, FName, X))
rule expEval(B, len(X:Exp)) => myStrlen(B, expEvalLoc(B, X))
rule expEval(_, val(V)) => V

syntax Int ::= "myStrlen" "(" Bag "," Loc ")" [function]


rule myStrlen(
	<generatedTop>
	... 
		<kphp>
		...
    		<heap> 
            ... 
				L |-> zval(V:String,_,_,_) 
		 	...                 	
			</heap>
		...
		</kphp> 
	...
	</generatedTop>, 
	L:Loc) => lengthString(V)
		when L =/=K locNull

rule myStrlen(
	<generatedTop>
	... 
		<kphp>
		...
    		<heap> 
            ... 
				L |-> zval(V:LanguageValue,_,_,_) 
		 	...                 	
			</heap>
		...
		</kphp> 
	...
	</generatedTop>, 
	L:Loc) => 0
		when (L =/=K locNull) andBool (notBool isStringType(V))

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Evaluation to a location} */
// ---------------------------------------------------------------------------------------------

syntax Loc ::= "expEvalLoc" "(" Bag "," Exp ")"	 				[function]

rule expEvalLoc(B, gv(X:Variable)) => lookup_glob(B, X)
rule expEvalLoc(B, fv(FName, X:Variable)) => lookup_fun(B, FName, X)
rule expEvalLoc(_, val(V)) => locNull

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Lookup} */
// ---------------------------------------------------------------------------------------------

syntax Loc ::= "lookup_glob" "(" Bag "," Variable ")" 					[function]
rule lookup_glob(B:Bag, X:Variable) => lvalue(B, getGlobalScope(B), X)

syntax Loc ::= "lookup_fun" "(" Bag "," String "," Variable ")" 		[function]
rule lookup_fun(B:Bag, FunName:String, X:Variable) => lvalue(B, getFunScope(B, FunName), X)

// ---------------------------------------------------------------------------------------------
/*@ \subsection{get global scope} */
// ---------------------------------------------------------------------------------------------

syntax Loc ::= "getGlobalScope" "(" Bag ")" [function]

rule getGlobalScope(
	<generatedTop>
	... 
		<kphp>
		...
			<scopes>
			...
				<globalScope> L:Loc </globalScope>
			...
			</scopes>
		...
		</kphp> 
	...
	</generatedTop>) => L

// ---------------------------------------------------------------------------------------------
/*@ \subsection{get function scope} */
// ---------------------------------------------------------------------------------------------

syntax Loc ::= "getFunScope" "(" Bag "," String ")" [function]

rule getFunScope(
	<generatedTop>
	... 
		<kphp>
		...
		<control>	
			...
			<functionStack>
				ListItem(sf(FName,_,_,_,_,_,_)) ...
			</functionStack>
			...
		</control>	
		<scopes>
			...
			<currentScope> L:Loc </currentScope>
			...
		</scopes>
		...
		</kphp> 
	...
	</generatedTop>, FName:String) => L
	
// ---------------------------------------------------------------------------------------------
/*@ \subsection{get current function} */
// ---------------------------------------------------------------------------------------------

syntax String ::= "get_crnt_fun" "(" Bag ")" [function]


rule get_crnt_fun(
	<generatedTop>
	... 
		<kphp>
		...
		<control>	
			...
			
			<functionStack>
				ListItem(sf(F:String,_,_,_,_,_,_)) ...
			</functionStack>
			...
		</control>	
		...
		</kphp> 
	...
	</generatedTop>) => F

rule get_crnt_fun(
	<generatedTop>
	... 
		<kphp>
		...
		<control>	
			...
			<functionStack>
				.List
			</functionStack>
			...
		</control>	
		...
		</kphp> 
	...
	</generatedTop>) => "top"

// ---------------------------------------------------------------------------------------------
/*@ \subsection{lvalue} */
// ---------------------------------------------------------------------------------------------

syntax Loc ::= "lvalue" "(" Bag "," Loc "," Variable ")" 					[function]

// simple variables: special case of array

rule lvalue(B:Bag, L:Loc, (variable(X:Key) => array(X, .KeyList)))

// array

rule lvalue(
	<generatedTop>
	... 
		<kphp>
		...
    		<heap> 
            ... 
				L  |-> zval(Array(_,_ ListItem([X1,_,L1]) _),_,_,_) 
		 		L1 |-> zval(V:Array,_,_,_) 
		 	...                 	
			</heap>
		...
		</kphp> 
	...
	</generatedTop>, 
	(L:Loc => L1), (array((X1:Key, Path:KeyList) => Path)))
		when notBool (Path ==K .KeyList)

// value not found -- return locnull

rule lvalue(
	<generatedTop>
	... 
		<kphp>
		...
    		<heap> 
            ... 
				L  |-> zval(Array(_,Elems),_,_,_) 
		 	...                 	
			</heap>
		...
		</kphp> 
	...
	</generatedTop>, 
	L:Loc, array(X1:Key,_)) => locNull
		when notBool (Elems hasProperty X1)

// final value found

rule lvalue(
	<generatedTop>
	... 
		<kphp>
		...
    		<heap> 
            ... 
				L |-> zval(Array(_,_ ListItem([X,_,L1]) _),_,_,_) 
		 	...                 	
			</heap>
		...
		</kphp> 
	...
	</generatedTop>, 
	L:Loc, array(X:String, .KeyList)) => L1

// ---------------------------------------------------------------------------------------------
/*@ \subsection{read} */
// ---------------------------------------------------------------------------------------------

syntax LanguageValue ::= "read" "(" Bag "," Loc ")"		[function]

rule read(
	<generatedTop>
	... 
		<kphp>
		...
    		<heap> 
            ... 
				L |-> zval(V:LanguageValue,_,_,_) 
		 	...                 	
			</heap>
		...
		</kphp> 
	...
	</generatedTop>, 
	L:Loc) => V
		when L =/=K locNull
	
rule read(_,locNull) => NULL

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Label} */
// ---------------------------------------------------------------------------------------------

syntax String ::= "get_config_label" "(" Bag ")" [function]

rule get_config_label(
	<generatedTop> 
	... 
	<kphp>
	...
		<instrumentation>
			...
			<label> S:String </label>
			...
		</instrumentation>
	...
	</kphp> 
	... 
	</generatedTop>) => S

endmodule