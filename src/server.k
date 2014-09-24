require "init.k"

module CONFIGURATION-SERVER
	imports INIT

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Configuration} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
   
configuration
	<T color="blue">
		<script color="red">
			<decl color="orange"> .K </declarations>
			<commands color="orange"> .K </commands>
			<k color="blue"> 
				Loop(1,	 
					 resetMem ~> 
					 buildInitState  ~> 
					 select ~> 
					 initGet ~> 
					 $PGM:K
				)
			</k>
		</script>	
		<br/>
		<declarations color="pink">
			<functions color="orange"> .Map </functions>
    		<classes color="orange"> .Map </classes>
    		<consts color="orange"> .Map </constants>
    	</tables>
	    <br/>
		<globalScope> .K </globalScope>
        <globalStaticScope> .K </globalStaticScope> 
        <superGlobalScope> .K </superGlobalScope>
		<crntScope color="magenta"> .K </currentScope>
		<control>	
			<functionStack> .List </functionStack>
			<exceptionStack> .List </exceptionStack>
			<loopStack> .List  </loopStack> 
			<context>
				<currentForeachItem> .K </currentForeachItem> 
				<object> .K </object>
                <class> .K </class> 
                <function> .K </function>
			</context>
			<functionArgumentsDeclaration> .K </functionArgumentsDeclaration>
			<processedFunctionBody> .K  </processedFunctionBody>
			<processedStaticDeclarations> .K </processedStaticDeclarations>
		</control>	
		<classInstanceCounters> .Map </classInstanceCounters>
		<br/>
		<config>
            <varDumpLevel> 0 </varDumpLevel>
		</config>	
		<br/>
		<mem color="Cyan"> .Map </heap>
     	<br/> 		
     	<IO>
     		<in color="green" stream="stdin"> .List </in>
     		<out color="red" /*stream="stdout"*/> .List </out>
            <exitStatus color="pink"> 0 </exitStatus>
     	</IO>
     	<errorManagement> 0 </errorManagement>
		<instrumentation>
			<clean-trace> true </clean-trace> 
			<isTerminated> false </isTerminated> 
			<label> "@" </label>
		</instrumentation>     		
		<gc> 
			<locationsToCollect> .List </locationsToCollect>
			<gc-enabled> false </gc-enabled>
		</gc>
		<server>
     		<db> $MyDb:DB </db>
			<msg> msg("", "", "", "") </msg>
     	</server>
    </T>

// Specific instrumentation for the server

syntax K ::= "Loop" "(" K "," K ")"

rule Loop(0,Command:K) => .
rule Loop(N:Int,Command:K) => Command ~> Loop(N -Int 1,Command) 
     when (N >Int 0) [kripke]
rule ""Loop("loop",Command:K) => Command ~> ""Loop("loop",Command) [kripke]


syntax K ::= "initGet" 
rule 	<k> initGet =>	'Expr('Assign('ArrayAccess('Variable('Simple("_GET")),,"user"),,A)) ... </k>
		<msg> msg(A:String, B:String, C:String, D:String)  </msg>

syntax K ::= "resetMem"

rule	<k> resetMem => . ... </k>
		<declarations> _ => . </declarations>
		<commands> _ => . </commands>
		<functions> _ => .Map </functions>
		<classes> _ => .Map </classes>
		<constants> _ => .Map </constants>
		<globalScope> _ => . </globalScope>
		<superGlobalScope> _ => . </superGlobalScope>
		<globalStaticScope> _ => . </globalStaticScope>
		<functionStack> _ => .List </functionStack>
		<loopStack> _ => .List </loopStack>
		<currentScope> _ => . </currentScope>
		<object> _ => . </object>
		<class> _ => . </class>
		<functionArgumentsDeclaration> _ => . </functionArgumentsDeclaration>
		<varDumpLevel> _ => 0 </varDumpLevel>
		<heap> _ => . </heap>
		<exitStatus> _ => . </exitStatus>

syntax K ::= "select" 
           | "void" Pair
	   	   | "getInput"

//rule 	<k> getInput => ""print("*") ... </k>
//		<in> X:K => . ... </in>
//		<db> _ => X </db>

context void HOLE
rule void P:Pair => .

rule 	<k> select => void Sel(A, 1) ~> void Sel(B, 2) ~> void Sel(C, 3) ~> void Sel(D, 4)  ... </k>
		<db> db(A:Pair, B:Pair, C:Pair, D:Pair) </db>
		
// Pairs

syntax Msg ::= "msg" "(" String "," String "," String "," String ")"
syntax DB ::= "db" "(" Pair "," Pair "," Pair "," Pair ")"
syntax Pair ::= "pair" "(" Pair "," Pair ")" [strict, superheat]
	      | String

syntax KResult ::= Pair

syntax K ::= "Sel" "(" Pair "," Int ")" 

rule Sel(pair(X:Pair, Y:Pair), Z:Int) => pair(Sel(X, Z), Sel(Y, Z))  //[supercool]

rule 	<k> Sel(S:String, 1) => S ... </k>
	<msg> msg((_ => S),_,_,_) </msg> [supercool]

rule 	<k> Sel(S:String, 2) => S ... </k>
	<msg> msg(_,(_ => S),_,_) </msg> [supercool]

rule 	<k> Sel(S:String, 3) => S ... </k>
	<msg> msg(_,_,(_ => S),_) </msg> [supercool]

rule 	<k> Sel(S:String, 4) => S ... </k>
	<msg> msg(_,_,_,(_ => S)) </msg> [supercool]


endmodule
