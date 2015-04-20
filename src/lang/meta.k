module META

// ***************************************************************************************
//@ \section{Semantic infrastructure}
// **************************************************************************************
 
///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Memory locations} */
///////////////////////////////////////////////////////////////////////////////


/*  TODO
    syntax  LocBase ::= "loc" "(" Int ")"
    syntax  LocCons  ::= "loc" "(" Loc "," Loc ")"
    syntax  Loc ::= LocBase | LocCons
    rule    isKResult(loc(L1:KResult,L2:KResult)) => true

    ///////////////////////////////////////////////////////////////////////////
    //@ Comparison
    ///////////////////////////////////////////////////////////////////////////

    syntax  Bool ::= Loc "==Loc"  Loc   [predicate]  
                   | Loc "=/=Loc" Loc   [predicate]            

    // base cases
    rule    loc(I1:Int) ==Loc loc(I2:Int) => I1 ==K I2  
    rule    loc(_:Int) ==Loc loc(_:Loc,_:Loc) => false 
    rule    loc(_:Loc,_:Loc) ==Loc loc(_:Int) => false 

    // cons case
    rule    loc(L1:Loc,L2:Loc) ==Loc loc(L1':Loc,L2':Loc) =>
            (L1 ==Loc L1') andBool (L2 ==Loc L2')

    rule    L1 =/=Loc L2 => notBool (L1 ==Loc L2)
*/


///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Noemrlisation of boolean expressions} */
///////////////////////////////////////////////////////////////////////////////

/*  TODO
    syntax  BExp ::= "norm" "(" Exp ")" [function] 

    rule    norm(A:AExp) => A
    rule    norm(true) => true
    rule    norm(false) => false
    rule    norm(A1 < A2) => A1 < A2
    rule    norm(A1 <= A2) => (A1 < A2) | (A1 == A2)
    rule    norm(A1 == A2) => A1 == A2
    rule    norm(A1 <> A2) => (A1 < A2) | (A2 < A1)
    rule    norm(A1 > A2) => A2 < A1
    rule    norm(A1 >= A2) => (A1 == A2) | (A2 < A1) 
    rule    norm(B1 | B2) => norm(B1) | norm(B2)
    rule    norm(B1 & B2) => norm(B1) & norm(B2)    

    rule    norm(!true) => false
    rule    norm(!false) => true
    rule    norm(!(A1 < A2)) => norm(A1 >= A2) 
    rule    norm(!(A1 <= A2)) => norm(A1 > A2) 
    rule    norm(!(A1 == A2)) => norm(A1 <> A2) 
    rule    norm(!(A1 <> A2)) => A1 == A2
    rule    norm(!(A1 > A2)) => norm(A1 <= A2)
    rule    norm(!(A1 >= A2)) => A1 < A2
    rule    norm(!(B1 | B2)) => norm(!B1) & norm(!B2)
    rule    norm(!(B1 & B2)) => norm(!B1) | norm(!B2)
    rule    norm(!!B) => norm(B)
*/

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Merging configurations} */
///////////////////////////////////////////////////////////////////////////////

syntax  K ::= "mergeConfigs" "(" BoxedConfig "," BoxedConfig ")" [strict(1,2)] 

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{ABexp} */
///////////////////////////////////////////////////////////////////////////////

syntax  K ::= "Abexp"  "(" K "," OptionBag ")"
syntax  K ::= "Abexp1" "(" K "," OptionBag ")" [strict(1)]

rule Abexp(K,M) => Abexp1(runInMem(M,K),M)



rule Abexp1(V:KResult, M:OptionBag) =>
	#if valid(V) #then 
            M
    #else
            #if unsatisfiable(V) #then
                none
            #else
                M   
            #fi
    #fi
    [transition]

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Return codes} */
///////////////////////////////////////////////////////////////////////////////

    // TODO: move to memory?
    syntax ReturnCode ::= "NEXT" | "RET" | "DONE" | "LOOP" | "ERR"

    //@ get status of a configuration
    syntax  ReturnCode ::= "configGetStatus" "(" Bag ")"    [function]
    rule    configGetStatus(_ <status> S </status> _) => S

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Boxes and options} */
///////////////////////////////////////////////////////////////////////////////

    /*@ In the following we'll need to pass around configurations (i.e. states), but 
    in order to do this in \K we need to box them. Note that this construction is 
    generic and will work even if more cell are added to the language 
    (i.e. everyting of sort Bag can go there). */

    syntax BoxedConfig ::= "config" "(" Bag ")"
    syntax KResult ::= BoxedConfig

    // option bag
    syntax OptionBag ::= "some" "(" Bag ")" | None
    syntax KResult ::= OptionBag

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Auxiliary machine operations} */
///////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    //@ Update current memory
    ///////////////////////////////////////////////////////////////////////////

	syntax  K ::= "updateMem" "(" OptionBag ")"     [strict]

	rule <k> updateMem(some(M)) => . ... </k>
             <mem> _:Bag => M </mem> 
            [transition]    

    ///////////////////////////////////////////////////////////////////////////
    // Update the value of a variable in a given memory. Return updated mem.
    ///////////////////////////////////////////////////////////////////////////
    
    /* TODO
    syntax  K ::= "updateMem" "(" OptionBag "," Id "," K ")"
    
    // no memory 
    rule    updateMem(none,_,_) => none

    // existing variable
    rule    updateMem(some(
                <env> (X |-> L)  E </env> 
                <store> (L |-> V1) S </store>), X, V) =>
                    some(<env> (X |-> L) E </env> <store> (L |-> V) S </store>)
    // fresh variable
    rule    updateMem(
                some(
                    <env> E </env> 
                    <store> S </store>), X, V) 
                =>
                some(
                    <env> (X |-> loc(L)) E </env> 
                    <store> (loc(L) |-> V) S </store>)
                when (notBool (X in keys(E))) andBool (fresh(L:Int))
    */
            
    ///////////////////////////////////////////////////////////////////////////
    //@ Update current mconfiguration
    ///////////////////////////////////////////////////////////////////////////
 
	syntax K ::= "updateConfig" "(" BoxedConfig ")" [strict]

	rule	<kphp>
                <script> 
                    <k> updateConfig(config(C)) => . ... </k>
                    _
                </script>
                (_ => C)
            </kphp>
            [transition]

    ///////////////////////////////////////////////////////////////////////////
    //@ Run computation in given memory 
    ///////////////////////////////////////////////////////////////////////////

    syntax K ::= "runInMem" "(" OptionBag "," K ")" [strict(1)]

    rule    <k> runInMem(some(M:Bag), B:K) => updateMem(some(M)) ~> B ... </k>
            <status> _ => NEXT </status>
            [transition]
    
rule	<k> runInMem(none, _) => .  ... </k> 
	    // Result doesn't matter cause it's discarded
            <status> _ => DONE </status>
            [transition]

    ///////////////////////////////////////////////////////////////////////////
    //@ Run computation in given configuration
    ///////////////////////////////////////////////////////////////////////////

    syntax K ::= "runInConf" "(" BoxedConfig "," K ")"     [strict(1)] 
	
	rule	runInConf(C, K) => updateConfig(C) ~> K 
    
    ///////////////////////////////////////////////////////////////////////////
    //@ Return current configuration
    ///////////////////////////////////////////////////////////////////////////
 
	syntax  K ::= "getCurrentConfig"

    rule 	<kphp>
                <script>
                    <k> getCurrentConfig => config(Cfg) ... </k>
                    _
                </script>
			    Cfg:Bag
            </kphp> 

    ///////////////////////////////////////////////////////////////////////////
    //@ Run K and return the configuration after it
    ///////////////////////////////////////////////////////////////////////////
    
	syntax  K ::= "runAndGetConfig"	"(" K ")" 	

	rule 	<k> runAndGetConfig(S) => S ~> getCurrentConfig ... </k>
            [transition]

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Memory operations} */
///////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    // Memory equality 
    ///////////////////////////////////////////////////////////////////////////

    // memory equality. TODO: is that really true? What if (one of) the two memories
    // being compared contains merged locations i.e. loc(l1,l2)... ?
    // Maybe: we should chage the def of recursive locs to be weaker 
    // (e.g. sets instead as pairs)
    syntax  Bool ::= "==Mem" "(" Bag "," Bag ")" [predicate]

    // TODO: do we really need this? Why don't use "isomorp" instead?

    rule    ==Mem(
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
                <heap> H2 </heap>) => H1 ==Map H2

    ///////////////////////////////////////////////////////////////////////////
    // Memory equality (modulo isomorphism)
    ///////////////////////////////////////////////////////////////////////////

    syntax  Bool ::= "(" Map "," Map ")"   "|-" "isomorph"  "(" Zval "," Zval ")" [predicate]

	//rule	_ |- isomorph(_,_) => false

	
	// scalar

	
        rule    (_,_) |- isomorph(zval(V1:ScalarValue,_,_,_),zval(V2:ScalarValue,_,_,_)) => 
			V1 ==K V2
	

	// array 

	
    	rule    (H',H) |- isomorph(zval(Array(_,L1:List),_,_,_),zval(Array(_,L2:List),_,_,_)) =>
			(H',H) |- isomorph1(L1,L2)
		

	// object
	
   	 rule    (H',H) |- isomorph(zval(OID(Loc1,_,_),_,_,_),zval(OID(Loc2,_,_),_,_,_)) =>
			(H',H) |- isomorph(heap_read(H',H,Loc1),heap_read(H',H,Loc2))
	
    syntax  Bool ::= "(" Map "," Map ")"   "|-" "isomorph1" "(" List "," List ")" [predicate]

    //@ base case

	rule    (_,_) |- isomorph1(.List,.List) => true
  
  	rule    (_,_) |- isomorph1(ListItem([X,_,_]) A1,A2:List) => false
            when notBool(A2 hasProperty X)

  	rule    (_,_) |- isomorph1(A1:List, ListItem([X,_,_]) A2) => false
            when notBool(A1 hasProperty X)

 
    // cons cases

    rule    (H',H) |- isomorph1(ListItem([X,_,L1]) A1, A2) => 
	    (H',H) |- isomorph1(A1,arrayRemove(A2,X))
            when  (A2 hasProperty X) andBool 
	    ((H',H) |- isomorph(heap_read(H',H,L1), heap_read(H',H,optionLoc2Loc(array_read_v(A2,X)))))


    rule    (H',H) |- isomorph1(ListItem([X,_,L1]) A1, A2) => false
            when  (A2 hasProperty X) andBool 
	(notBool ((H',H) |- isomorph(heap_read(H',H,L1), heap_read(H',H,optionLoc2Loc(array_read_v(A2,X))))))


///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Fixpoint computation} */
///////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    //@ Compute the fixpoint of a given K w.r.t. a given memory
    ///////////////////////////////////////////////////////////////////////////

    syntax K ::= "LFP" "(" OptionBag "," K ")"
    
    //@ fixpoint has been reached
    rule    <k> LFP(some(E), _) => . ... </k>
            <mem> E:Bag </mem>

    //@ fixpoint not reached, run computation again
    rule    <k> LFP(some(E1:Bag), K) => K ~> LFP(some(E), K) ... </k>
            <mem> E:Bag </mem>
            when notBool (==Mem(E,E1))     

    //@ start the computation
    rule    <k> LFP(none, K) => K ~> LFP(some(E), K) ... </k>
            <mem> E:Bag </mem>
    

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Stack frames operations} */
///////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    //@ Similarity notion
    ///////////////////////////////////////////////////////////////////////////

    syntax Bool ::= "(" Map "," Map ")"  
	 	    "|-" "similar" "(" StackFrame "," StackFrame ")" [predicate]
 
    /*@ We consider two stack frames as similar is they refer to the same label and 
    their two memories are isomoprphic.  */

    rule	(H',H) |- similar(sf(_,A1':Loc,_,_,_,_,L1:Int),sf(_,A2':Loc,_,_,_,_,L2:Int)) => 
			((H',H) |- isomorph(heap_read(H',H,A1'),heap_read(H',H,A2')))
			andBool (L1 ==K L2)

    /* OLD
    rule	Sto |- similar(sf(_,H1:Loc,_,_,_,_,L1:Int),sf(_,H2:Loc,_,_,_,_,L2:Int)) => 
			(Sto |- isomorph(heap_read(Sto,H1),heap_read(Sto,H2)))
				andBool (L1 ==K L2)
    */

    /*@ Given a stack frame, decided wether a similar (as defined above) 
    one is present in the stack. */

    syntax Bool ::= "(" Map "," Map ")" "|-" StackFrame "isIn" List   [function]

    rule    (_,_) |- S isIn .List => false

    rule    (H',H) |- S isIn ListItem(S1) L:List => true 
            when (H',H) |- similar(S,S1)

    rule    (H',H) |- S isIn ListItem(S1) L:List => (H',H) |- S isIn L 
            when notBool((H',H) |- similar(S,S1))
    
    /* OLD
    rule    _ |- S isIn .List => false
    rule    Sto |- S isIn ListItem(S1) L:List => true 
            when Sto |- similar(S,S1)

    rule    Sto |- S isIn ListItem(S1) L:List => Sto |- S isIn L 
            when notBool(Sto |- similar(S,S1))
    */

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Merging configurations} */
///////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    // Merging entry point, Special cases.
    ///////////////////////////////////////////////////////////////////////////

    syntax  K ::= "mergeConfigs" "(" BoxedConfig "," BoxedConfig ")"         [strict(1,2)] 

    /*@ Adaptive-merge case. This happens when one branch returned 
    but the other didn't. See notes. */


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
    rule    mergeConfigsBase(
                config( 
                        C1:Bag
			<returns> R1 </returns>  
			<returns-loc> RL1 </returns-loc>
			<status> S1 </status> 	                 
                        <mem> M1 </mem>
	    		<control>
			    Ctr1:Bag
			    <functionStack> St1 </functionStack>
			</control>
			<tables>
			    Tables1:Bag
			    <functions> F1 </functions>
			</tables>),
                config(
                        C2:Bag
			<returns> R2 </returns> 
			<returns-loc> RL2 </returns-loc>
			<status> S2 </status> 	
                        <mem> M2 </mem>
			<control>
			    Ctr2:Bag
			    <functionStack> St2 </functionStack>
			</control>
			<tables>
			    Tables2:Bag
			    <functions> F2 </functions>
			</tables>)) =>

                updateConfig(config(
                        C1 // TODO 
			<returns-loc> RL1 RL2 </returns-loc>
			<returns> mergeReturns(R1,R2) </returns> 
			<status> mergeStatus(S1,S2) </status>
                        <mem> mergeMem(0,M1,St1,F1,M2,St2,F2) </mem>
			<control>
			    Ctr1    // TODO
			    <functionStack> mergeFunctionStack(St1,St2) </functionStack>
			</control>
			<tables>
			    Tables1 // TODO
			    <functions> mergeFunctions(F1,F2) </functions>
			</tables>))
                  
                    [transition]

    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsubsection{Merge functionStack} */
    ///////////////////////////////////////////////////////////////////////////

    // TODO
    syntax List ::= "mergeFunctionStack" "(" List "," List ")" [function]    
    rule mergeFunctionStack(S1,S2) => S1
    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsubsection{Merge functions} */
    ///////////////////////////////////////////////////////////////////////////
    
    // TODO
    syntax Map ::= "mergeFunctions" "(" Map "," Map ")" [function]
    rule mergeFunctions(F1,F2) => F1

    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsubsection{Merging the status cell} */
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
    /*@ \subsubsection{Merging returns} */
    ///////////////////////////////////////////////////////////////////////////

    syntax  K ::= "mergeReturns" "(" K "," K ")"         [function] 
    rule    mergeReturns(V1, V2) => lub(V1,V2)

    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsubsection{Merging memories} */
    ///////////////////////////////////////////////////////////////////////////


    syntax  Bag ::= "mergeMem" "(" Int "," Bag "," List "," Map ","  Bag "," List "," Map ")"
	    [function]

    // TODO: factorise those two by using side-conditions & conditional



    rule    mergeMem(_,
                <scopes> 
                    <currentScope> L1 </currentScope>
                    <globalScope> L2 </globalScope>
                    <globalStaticScope> L3 </globalStaticScope>
                    <superGlobalScope> L4 </superGlobalScope> 
                </scopes> 
                <heap> H1 </heap>
		<thematrix> H1' </thematrix>
		,St1,F1,
                <scopes> 
                    <currentScope> L1' </currentScope>
                    <globalScope> L2' </globalScope>
                    <globalStaticScope> L3' </globalStaticScope>
                    <superGlobalScope> L4' </superGlobalScope>   
                </scopes> 
                <heap> H2 </heap>
		<thematrix> H2' </thematrix>,St2,F2) => 
                <scopes>
                    <currentScope> L1 </currentScope>
                    <globalScope> L2 </globalScope>
                    <globalStaticScope> L3 </globalStaticScope>
                    <superGlobalScope> L4 </superGlobalScope>  
                </scopes>
		bagUnwrap(
		    leftElem(
			mergeArrayInCtx(
			    pair(
				bagWrap(<thematrix> .Map </thematrix> <heap> .Map </heap>), 
				mapWrap(.Map)),
			    ListItem(
				mergeArgs(
				    L4,optionLoc2Loc(vheap_read(H1',L4)),
				    heap_read(H1',H1,L4 ),H1',H1,
				    heap_read(H2',H2,L4'),H2',H2))
			    mergeFunStaticScopes(F1,H1',H1,F2,H2',H2))))	
		when L1 ==K L2




    rule    mergeMem(_,
                <scopes> 
                    <currentScope> L1 </currentScope>
                    <globalScope> L2 </globalScope>
                    <globalStaticScope> L3 </globalStaticScope>
                    <superGlobalScope> L4 </superGlobalScope> 
                </scopes> 
                <heap> H1 </heap>
		<thematrix> H1' </thematrix>
		,St1,F1,
                <scopes> 
                    <currentScope> L1' </currentScope>
                    <globalScope> L2' </globalScope>
                    <globalStaticScope> L3' </globalStaticScope>
                    <superGlobalScope> L4' </superGlobalScope>   
                </scopes> 
                <heap> H2 </heap>
		<thematrix> H2' </thematrix>,St2,F2) => 
                <scopes>
                    <currentScope> L1 </currentScope>
                    <globalScope> L2 </globalScope>
                    <globalStaticScope> L3 </globalStaticScope>
                    <superGlobalScope> L4 </superGlobalScope>  
                </scopes>
		bagUnwrap(
		    leftElem(
			mergeArrayInCtx(
			    pair(
				bagWrap(<thematrix> .Map </thematrix> <heap> .Map </heap>), 
				mapWrap(.Map)),
			    ListItem(
				mergeArgs(
				    L4,optionLoc2Loc(vheap_read(H1',L4)),
				    heap_read(H1',H1,L4 ),H1',H1,
				    heap_read(H2',H2,L4'),H2',H2))
			    ListItem(
				mergeArgs(
				    L1,optionLoc2Loc(vheap_read(H1',L1)),
				    heap_read(H1',H1,L1 ),H1',H1,
				    heap_read(H2',H2,L1'),H2',H2))   
			    mergeStackedScopes(St1,H1',H1,St2,H2',H2)   
			    mergeFunStaticScopes(F1,H1',H1,F2,H2',H2))))	
		when L1 =/=K L2
	










    ///////////////////////////////////////////////////////////////////////////
    // Merge array
    ///////////////////////////////////////////////////////////////////////////

    // ------------------------------------------------- auxiliary constructions


    // option loc 2 loc
    syntax Loc ::= "optionLoc2Loc" "(" OptionLoc ")" [function]
    rule optionLoc2Loc(L:Loc) => L


    // Pairs
    syntax Pair ::= "pair" "(" K "," K ")"

    syntax K ::= "leftElem" "(" Pair ")" [function]
    rule leftElem(pair(L,_)) => L 
	
    syntax K ::= "rightElem" "(" Pair ")" [function]
    rule rightElem(pair(_,R)) => R 





    // isScalarZVal
    syntax Bool ::= "isScalar_zval" "(" Zval ")" [predicate]
    rule isScalar_zval(zval(V,_,_,_)) => true 
        when isScalarValue(V) ==K true

    rule isScalar_zval(zval(V,_,_,_)) => false
        when notBool (isScalarValue(V) ==K true)

    // isArrayZVal
    syntax Bool ::= "isArray_zval" "(" Zval ")" [predicate]
    rule isArray_zval(zval(V,_,_,_)) => true 
        when isArray(V) ==K true

    rule isArray_zval(zval(V,_,_,_)) => false
        when notBool (isArray(V) ==K true)

    // isObjectZVal
    syntax Bool ::= "isObject_zval" "(" Zval ")" [predicate]
    rule isObject_zval(zval(V,_,_,_)) => true 
        when isObject(V) ==K true

    rule isObject_zval(zval(V,_,_,_)) => false
        when notBool (isObject(V) ==K true)
    
    // zval2ArrayList
    syntax List ::= "zval2ArrayList" "(" Zval ")" [function]
    rule zval2ArrayList(zval(Array(_,E),_,_,_)) => E




    // set wrap 
    syntax K ::= "setWrap" "(" Set ")"

    // bag wrap
    syntax K ::= "bagWrap" "(" Bag ")"
    syntax Bag ::= "bagUnwrap" "(" K ")" [function]
    rule bagUnwrap(bagWrap(B)) => B
    
    // map wrap
    syntax K ::= "mapWrap" "(" Map ")"
    syntax Map ::= "mapUnwrap" "(" K ")" [function]
    rule mapUnwrap(mapWrap(M)) => M
    

    // preimage: Map -> K -> Set
    syntax Set ::= "preimage" "(" Map "," K ")" [function]
    rule preimage(_,none) => SetItem(none)
    rule preimage(H,Y) => preimage'(H,Y)	when Y =/=K none

    syntax Set ::= "preimage'" "(" Map "," K ")"
    rule preimage'(.Map,X) => .Set
    rule preimage'(X |-> Y  M,Y) => SetItem(X) preimage'(M,Y)
    rule preimage'(X |-> Y1 M,Y) => preimage'(M,Y)
	 when Y1 =/=K Y

    // unify
    syntax Loc ::= "unify" "(" Map "," Set ")" [function]
    rule unify(H',LocSet) => unify'(H',vheapReadSet(H',LocSet))

    syntax Loc ::= "unify'" "(" Map "," Set ")" [function]
    rule unify'(_,.Set) => J 		when fresh(J:Loc)
    rule unify'(_,SetItem(X)) => X

    // makeH'
    syntax Map ::= "makeH'" "(" Map "," Set "," Loc ")" [function]
    rule makeH'(_,.Set,_) => .Map
    rule makeH'(H',SetItem(L) S, J) => add2H'(L,J) makeH'(H',S,J)
	when notBool(L in keys(H'))
    
    rule makeH'(H',SetItem(L) S, J) => makeH'(H',S,J)
	when (L in keys(H'))

    syntax Map ::= "add2H'" "(" K "," K ")" [function]
    rule add2H'(none,_) => .Map
    rule add2H'(L,J) => L |-> J when L =/=K none


    // update zval ref counter
    syntax Zval ::= "setZvalRC" "(" Zval "," Int ")" [function]
    rule setZvalRC(zval(V,T,R',I),R) => zval(V,T,R,I)

    syntax Int ::= "getRC" "(" Zval ")" [function]
    rule getRC(zval(_,_,RC,_)) => RC


    // makeH
    syntax Map ::= "makeH" "(" Map "," Loc "," Zval "," Zval ")" [function]
    rule makeH(H,J,ZV1,ZV2) => makeH1(H,J,mergeZval(ZV1,ZV2))

    syntax Map ::= "makeH1" "(" Map "," Loc "," Zval ")" [function]

    // NOTE: could optimize by 
    //     (i) making mergeZval init the RC with 1
    //    (ii) avoid the increment in the rule below 

    rule    makeH1(H,J,ZV) => (J |-> setZvalRC(ZV,1 +Int getRC(ZV))) H 
	when notBool(J in keys(H))

    rule makeH1((J |-> ZV') H,J,ZV) => (J |-> setZvalRC(ZV,1 +Int getRC(ZV'))) H 

   // similar to map union, but if an element is present in both maps, 
   // the element on the RHS "wins"... 
   syntax Map ::= Map "<-" Map [function]

   // base
   rule .Map <- H => H
   rule H <- .Map => H

   // item in both maps
   rule (H1 (J |-> V1)) <- (H2 (J |-> V2)) => (J |-> V1) (H1 <- H2)

   // item only in left map
   rule (H1 (J |-> V1)) <- H2  => (J |-> V1) (H1 <- H2) 
   	when notBool (J in keys(H2))

   // item only in right map
   rule H1 <- (H2 (J |-> V2))  => (J |-> V2) (H1 <- H2) 
	when notBool (J in keys(H1))

    // increment reference counter
    syntax Map ::= "incRCf" "(" Map "," Loc ")" [function]
    rule incRCf(L |-> zval(V,T,R,I) H,L) => (L |-> zval(V,T,R +Int 1,I)) H 

    // ------------------------------------------------- merging


    syntax MergeArgs ::= "mergeArgs" "(" 
	Loc "," Loc "," 
	Zval "," Map "," Map "," 
	Zval "," Map "," Map ")"

    syntax Pair ::= "mergeArrayInCtx" "(" Pair "," List ")" [function]
    
    // base case
    rule mergeArrayInCtx(M:Pair,.List) => M 

    // cons case
    rule mergeArrayInCtx(M:Pair, ListItem(A:MergeArgs) Args) =>    
	mergeArrayInCtx(mergeArrayInCtx1(M,A), Args) 

    syntax Pair ::= "mergeArrayInCtx1" "(" Pair "," MergeArgs ")" [function]
    rule mergeArrayInCtx1(P,mergeArgs(L',L,V1,H1',H1,V2,H2',H2)) => 
	    mergeArrayInCtx2(P,L',L,V1,H1',H1,V2,H2',H2)  

    
    syntax Pair ::= "mergeArrayInCtx2" "(" 
	Pair ","
	Loc "," Loc ","
	Zval "," Map "," Map ","
	Zval "," Map "," Map ")"
	[function]

    rule mergeArrayInCtx2(
	    pair(bagWrap(<thematrix> H' </thematrix> <heap> H </heap>),mapWrap(Alpha)),
	    L',L,
	    A1,H1',H1,
	    A2,H2',H2) => 
	mergeArray(L',L,A1,H1',H1,A2,H2',H2,.List,H',H,Alpha)


    // ----- step 0: init
    syntax  Pair ::= "mergeArray" "(" 
	OptionLoc "," Loc ","				    // destination
	Zval "," Map "," Map ","	    // memory 1
	Zval "," Map "," Map ","	    // memory 2
	List "," Map "," Map "," Map ")"    // intermediate memory/result
	[function]
 
    rule    mergeArray(
		L',L,
                zval(Array(_,E1),_,Rc1,_),H1',H1,
                zval(Array(_,E2),_,Rc2,_),H2',H2,                
                E,H',H,Alpha) => 
		mergeArray1(L',L,1/*max(Rc1,Rc2)*/,E1,H1',H1,E2,H2',H2,E,H',H,Alpha)
 

    // ----- step 1: choose variable to merge. Identify locs in the heap.

    syntax  Pair ::= "mergeArray1" "(" 
	OptionLoc "," Loc "," Int "," 
	List "," Map "," Map "," 
	List "," Map "," Map "," 
	List "," Map "," Map ","
	Map ")"
	[function]

    // base case - none 
    rule    mergeArray1(none,L,Rc,.List,_,_,.List,_,_,E,H',H,Alpha) => 
		pair(
		    bagWrap(
			<heap> (L |-> zval(Array(head(E),E),array,Rc,#if (Rc >Int 1) #then true #else false #fi)) H </heap>
			<thematrix> H' </thematrix>),
		    mapWrap(Alpha))
 
    // base case - Loc
    rule    mergeArray1(L':Loc,L,Rc,.List,_,_,.List,_,_,E,H',H,Alpha) => 
		pair(
		    bagWrap(
			<heap> (L |-> zval(Array(head(E),E),array,Rc,#if (Rc >Int 1) #then true #else false #fi)) H </heap>
			<thematrix> (L' |-> L) H' </thematrix>),
		    mapWrap(Alpha))
 
    // left
    rule    mergeArray1(
		L',L,Rc,
		(ListItem([X,Vis,L1']) E1),H1',H1,
                E2,H2',H2,                
                E,H',H,
		Alpha) =>
	    mergeArray2(
		L',L,Rc,
		E1,H1',H1,
		arrayRemove(E2,X),H2',H2,
		E,H',H,
		Alpha,
		pair(X,Vis),
		pair(
		    vheap_read(H1',L1'), 
		    vheap_read(H2',array_read_v(E2,X)))) 
	
    // right
    rule    mergeArray1(
		L',L,Rc,
		E1,H1',H1,
                (ListItem([X,Vis,L2']) E2),H2',H2,                
                E,H',H,
		Alpha) =>
	    mergeArray2(
		L',L,Rc,
		arrayRemove(E1,X),H1',H1,
		E2,H2',H2,
		E,H',H, 
		Alpha,
		pair(X,Vis),
		pair(
		    vheap_read(H1',(array_read_v(E1,X))), 
		    vheap_read(H2',L2')))



    // ----- step 2: retrieve heap locs
    syntax  Pair ::= "mergeArray2" "(" 
	OptionLoc "," Loc "," Int ","
	List "," Map "," Map "," 
	List "," Map "," Map "," 
	List "," Map "," Map ","
	Map ","
	Pair ","		    // the variable (and visibility) being mergedd
	Pair ")"		    // the pair of heap locations 
	[function]


    rule    mergeArray2(
		L',L,Rc,
		E1,H1',H1,
                E2,H2',H2,                
                E,H',H,
		Alpha,
		Var,
		pair(J1,J2)) =>
	    mergeArray3(
		L',L,Rc,
		E1,H1',H1,
		E2,H2',H2, 
		E,H',H,
		Alpha,
		Var,
		pair(J1, J2),
		preimage(H1',J1) preimage(H2',J2))


    // ----- step 2: make env entry


    syntax  Pair ::= "mergeArray3" "(" 
	OptionLoc "," Loc "," Int ","
	List "," Map "," Map "," 
	List "," Map "," Map "," 
	List "," Map "," Map ","
	Map ","
	Pair ","		    // the variable being merged
	Pair ","		    // the pair of heap locations 
	Set ")"			    // codomain
	[function]



    rule    mergeArray3(
		L',L,Rc,
		E1,H1',H1,
                E2,H2',H2,                
                E,H',H,
		(setWrap(C) |-> L1' Alpha),
		pair(X,Vis),
		_,
		C:Set) =>
	    mergeArray1(
		L',L,Rc,
		E1,H1',H1,
		E2,H2',H2,
		E ListItem([X,Vis,L1']),H',incRCf(H,optionLoc2Loc(vheap_read(H',L1'))), 
		(setWrap(C) |-> L1' Alpha))


    rule    mergeArray3(
		L',L,Rc,
		E1,H1',H1,
                E2,H2',H2,                
                E,H',H,
		Alpha,
		pair(X,Vis),
		LocPair,
		C) =>
	    mergeArray4(
		L',L,Rc,
		E1,H1',H1,
		E2,H2',H2,
		E ListItem([X,Vis,L1']),H',H,
		(setWrap(C) |-> L1') Alpha,
		LocPair,
		C SetItem(L1'),
		unify(H',C))
    when (notBool(setWrap(C) in keys(Alpha))) andBool (fresh(L1':Loc))  











    // ----- step 3: 

    syntax  Pair ::= "mergeArray4" "(" 
	OptionLoc "," Loc "," Int ","
	List "," Map "," Map "," 
	List "," Map "," Map "," 
	List "," Map "," Map ","
	Map ","
	Pair ","		    // the pair of heap locations 
	Set ","
	Loc ")"
	[function]

    // TODO: all the following should incfement ref counter of J 

    // variable only in left branch - scalar
    rule    mergeArray4(
		L',L,Rc,
		E1,H1',(J1 |-> ZV1) H1,
                E2,H2',H2,                
                E,H',H,
		Alpha,
		pair(J1,none),
		C,
		J) =>
	    mergeArray1(
		L',L,Rc,
		E1,H1',(J1 |-> ZV1) H1,
		E2,H2', H2,
		E, 
		H' makeH'(H',C,J),	    
		makeH(H,J,ZV1,ZV1),  
		Alpha)
    when isScalar_zval(ZV1)   

    // variable only in right branch - scalar
    rule    mergeArray4(
		L',L,Rc,
		E1,H1',H1,
                E2,H2',(J2 |-> ZV2) H2,                
                E,H',H,
		Alpha,
		pair(none,J2),
		C,
		J) =>
	    mergeArray1(
		L',L,Rc,
		E1,H1',H1,
		E2,H2', (J2 |-> ZV2) H2,
		E, 
		H' makeH'(H',C,J),	    
		makeH(H,J,ZV2,ZV2),  
		Alpha)
    when isScalar_zval(ZV2)  

    // variable in both branches - scalar OR (scalar + array)
    rule    mergeArray4(
		L',L,Rc,
		E1,H1',(J1 |-> ZV1) H1,
                E2,H2',(J2 |-> ZV2) H2,                
                E,H',H,
		Alpha,
		pair(J1,J2),
		C,
		J) =>
	    mergeArray1(
		L',L,Rc,
		E1,H1',(J1 |-> ZV1) H1,
		E2,H2',(J2 |-> ZV2) H2,
		E, 
		H' makeH'(H',C,J),	    
		makeH(H,J,ZV1,ZV2),  
		Alpha)
	when isScalar_zval(ZV1) orBool isScalar_zval(ZV2) 

    // variable only in left branch - array
    rule    mergeArray4(
		L',L,Rc,
		E1,H1',(J1 |-> ZV1) H1,
                E2,H2',H2,                
                E,H',H,
		Alpha,
		pair(J1,none),
		C,
		J) =>
	  mergeArray5(
		L',L,Rc,
		E1,H1',(J1 |-> ZV1) H1,
		E2,H2',H2,
		E,
		H' makeH'(H',C,J),
		H, 
		Alpha,
		bagUnwrap(leftElem(mergeArray(none,J,ZV1,H1',H1,emptyArrayZval,.Map,.Map,.List,.Map,.Map,Alpha))))
    when isArray_zval(ZV1) 


    // variable only in right branch - array
    rule    mergeArray4(
		L',L,Rc,
		E1,H1',H1,
                E2,H2',(J2 |-> ZV2) H2,                
                E,H',H,
		Alpha,
		pair(none,J2),
		C,
		J) =>
	    mergeArray5(
		L',L,Rc,
		E1,H1',H1,
		E2,H2',(J2 |-> ZV2) H2,
		E,
		H' makeH'(H',C,J),
		H, 
		Alpha,
		bagUnwrap(leftElem(mergeArray(none,J,emptyArrayZval,.Map,.Map,ZV2,H2',H2,.List,.Map,.Map,Alpha))))
    when isArray_zval(ZV2)

    // variable in both branches - array 
    rule    mergeArray4(
		L',L,Rc,
		E1,H1',
		(J1 |-> ZV1) H1,
                E2,H2',
		(J2 |-> ZV2) H2,                
                E,H',H,
		Alpha,
		pair(J1,J2),
		C,
		J) =>
	    mergeArray5(
		L',L,Rc,
		E1,H1',(J1 |-> ZV1) H1,
		E2,H2',(J2 |-> ZV2) H2,
		E,
		H' makeH'(H',C,J),
		H, 
		Alpha,
		bagUnwrap(leftElem(mergeArray(none,J,ZV1,H1',H1,ZV2,H2',H2,.List,.Map,.Map,Alpha))))
    when isArray_zval(ZV1) andBool isArray_zval(ZV2)
    /*
    // variable only in left branch - array
    rule    mergeArray4(
		L',L,
		E1,H1',(J1 |-> zval(Array(_,E1'),_,_,_)) H1,
                E2,H2',H2,                
                E,H',H,
		Alpha,
		pair(J1,none),
		C,
		J) =>
	  mergeArray5(
		L',L,
		E1,H1',H1,
		E2,H2',H2,
		E,
		H' makeH'(H',C,J),
		H, 
		Alpha,
		bagUnwrap(leftElem(mergeArray1(none,J,E1',H1',H1,.List,.Map,.Map,.List,.Map,.Map,Alpha))))
 
    // variable only in right branch - array
    rule    mergeArray4(
		L',L,
		E1,H1',H1,
                E2,H2',(J2 |-> zval(Array(_,E2'),_,_,_)) H2,                
                E,H',H,
		Alpha,
		pair(none,J2),
		C,
		J) =>
	    mergeArray5(
		L',L,
		E1,H1',H1,
		E2,H2',H2,
		E,
		H' makeH'(H',C,J),
		H, 
		Alpha,
		bagUnwrap(leftElem(mergeArray1(none,J,.List,.Map,.Map,E2',H2',H2,.List,.Map,.Map,Alpha))))
 

    // variable in both branches - array 
    rule    mergeArray4(
		L',L,
		E1,H1',
		(J1 |-> zval(Array(_,E1'),_,_,_)) H1,
                E2,H2',
		(J2 |-> zval(Array(_,E2'),_,_,_)) H2,                
                E,H',H,
		Alpha,
		pair(J1,J2),
		C,
		J) =>
	    mergeArray5(
		L',L,
		E1,H1',H1,
		E2,H2',H2,
		E,
		H' makeH'(H',C,J),
		H, 
		Alpha,
		bagUnwrap(leftElem(mergeArray1(none,J,E1',H1',H1,E2',H2',H2,.List,.Map,.Map,Alpha))))
    */


    // ----- step 3: 




    // TODO: should increment ref count of J 
    syntax  Pair ::= "mergeArray5" "(" 
	OptionLoc "," Loc "," Int ","
	List "," Map "," Map "," 
	List "," Map "," Map "," 
	List "," Map "," Map ","
	Map ","
	Bag ")"
	[function]
    
    rule    mergeArray5(
		L',L,Rc,
		E1,H1',H1,
                E2,H2',H2,                
                E,H',H,
		Alpha,
		<heap> H3 </heap> <thematrix> H3' </thematrix>) =>
	    mergeArray1(
		L',L,Rc,
		E1,H1',H1,
		E2,H2',H2,
		E, (H' H3'), (H <- H3),  
		Alpha)





/*
    // merges two "array entries" (TODO properly)
    syntax  ArrayItem ::= "merge_ArrayItem" "(" Loc "," ArrayItem "," ArrayItem ")" [function]
    rule    merge_ArrayItem(L,[X,V1,_],[X,V2,_]) => [X,V1,L]
*/
    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsection{merge two zvals. */
    ///////////////////////////////////////////////////////////////////////////
                       
    // notice that only zvals containing scalars arrive here...

    // TODO: should NOT update refcount
    syntax  Zval ::= "mergeZval" "(" Zval "," Zval ")" [function]
    rule    mergeZval(zval(V,T,R,I),zval(V',T',R',I')) => 
	    zval(
	        lub(V,V'),
	        lub_type(T,T'),
	        0, // TODO: can remove max(R,R'), if not used
	        I orBool I')  

    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsection{merge the function's static vars part of the heap} */
    ///////////////////////////////////////////////////////////////////////////

    syntax List ::= "mergeFunStaticScopes" "(" Map "," Map "," Map "," 
			Map "," Map "," Map ")" [function]

    rule    mergeFunStaticScopes(.Map,_,_,.Map,_,_) => .List

    rule    mergeFunStaticScopes(
		F|->f(_,_,_,L1) F1,
		H1',
		H1,
		F|->f(_,_,_,L2) F2,
		H2',
		H2) =>
		ListItem(
		    mergeArgs(
			L1,optionLoc2Loc(vheap_read(H1',L1)),
			heap_read(H1',H1,L1),
			H1',
			H1,
			heap_read(H2',H2,L2),
			H2',
			H2))
		mergeFunStaticScopes(F1,H1',H1,F2,H2',H2)



    rule    mergeFunStaticScopes(
		F|->f(_,_,_,L1) F1,
		H1',
		H1,
		F2,
		H2',
		H2) =>
		ListItem(
		    mergeArgs(
			L1,optionLoc2Loc(vheap_read(H1',L1)),
			heap_read(H1',H1,L1),
			H1',
			H1,
			emptyArrayZval,
			H2',
			H2))
		mergeFunStaticScopes(F1,H1',H1,F2,H2',H2)	
		when notBool (F in keys(F2))

    rule    mergeFunStaticScopes(
		F1,
		H1',
		H1,
		F|->f(_,_,_,L2) F2, 
		H2',
		H2) =>
		ListItem(
		    mergeArgs(
			L2,optionLoc2Loc(vheap_read(H2',L2)),
			emptyArrayZval,
			H1',
			H1,
			heap_read(H2',H2,L2),
			H2',
			H2))
		mergeFunStaticScopes(F1,H1',H1,F2,H2',H2)	
		when notBool (F in keys(F1))


    /*
    syntax Map ::= "mergeFunStaticScopes" "(" Map "," Map "," Map "," Map  ")" [function]

    rule    mergeFunStaticScopes(F|->f(_,_,_,L1)F1,H1,F|->f(_,_,_,L2)F2,H2) =>
		mergeArray(L1,heap_read(H1,L1),H1,heap_read(H2,L2),H2,.List,.Map) 
		mergeFunStaticScopes(F1,H1,F2,H2)

    rule    mergeFunStaticScopes(F|->f(_,_,_,L1)F1,H1,F2,H2) =>
		mergeArray(L1,heap_read(H1,L1),H1,emptyArrayZval,H2,.List,.Map) 
		mergeFunStaticScopes(F1,H1,F2,H2)
		when notBool (F in keys(F2))

    rule    mergeFunStaticScopes(F1,H1,F|->f(_,_,_,L2)F2,H2) =>
		mergeArray(L2,emptyArrayZval,H1,heap_read(H2,L2),H2,.List,.Map) 
		mergeFunStaticScopes(F1,H1,F2,H2)
		when notBool (F in keys(F1))

    rule    mergeFunStaticScopes(.Map,_,.Map,_) => .Map
    */
    ///////////////////////////////////////////////////////////////////////////
    /*@ \subsection{merge the stack content part of the heap} */
    ///////////////////////////////////////////////////////////////////////////

    syntax List ::= "mergeStackedScopes" 
	"(" List "," Map "," Map "," List "," Map "," Map  ")" [function]

    rule    mergeStackedScopes(.List,_,_,.List,_,_) => .List
    rule    mergeStackedScopes(ListItem(_),_,_,ListItem(_),_,_) => .List

    // process all elements but the 1st (the global scope!)
    rule    mergeStackedScopes(
		S:List ListItem(_),H1',H1,
		S ListItem(_), H2',H2) => mergeStackedScopes1(S,H1',H1,S,H2',H2)
	    when S =/=List .List

    syntax List ::= "mergeStackedScopes1" 
	"(" List "," Map "," Map "," List "," Map "," Map ")" [function]

    rule    mergeStackedScopes1(.List,_,_,.List,_,_) => .List

    rule    mergeStackedScopes1(
		ListItem(sf(_,L1',_,_,_,_,_)) S,H1',H1,
		ListItem(sf(_,L1',_,_,_,_,_)) S,H2',H2) =>
		ListItem(
		    mergeArgs(
			L1',optionLoc2Loc(vheap_read(H1',L1')),
			heap_read(H1',H1,L1'),
			H1',
			H1,
			heap_read(H2',H2,L1'),
			H2',
			H2))
		mergeStackedScopes1(S,H1',H1,S,H2',H2)


    /*
    syntax Bag ::= "mergeStackedScopes" 
	"(" List "," Map "," Map "," List "," Map "," Map  ")" [function]

    rule    mergeStackedScopes(.List,_,_,.List,_,_) => .Bag
    rule    mergeStackedScopes(ListItem(_),_,_,ListItem(_),_,_) => .Bag

    // process all elements but the 1st (the global scope!)
    rule    mergeStackedScopes(
		S:List ListItem(_),H1',H1,
		S ListItem(_), H2',H2) => mergeStackedScopes1(S,H1',H1,S,H2',H2)
	    when S =/=List .List

    syntax Bag ::= "mergeStackedScopes1" 
	"(" List "," Map "," Map "," List "," Map "," Map ")" [function]

    rule    mergeStackedScopes1(.List,_,_,.List,_,_) => .Bag

    rule    mergeStackedScopes1(
		ListItem(sf(_,L1',_,_,_,_,_)) S,H1',H1,
		ListItem(sf(_,L1',_,_,_,_,_)) S,H2',H2) =>
		bagUnwrap(leftElem(mergeArray(
			L1',optionLoc2Loc(vheap_read(H1',L1')),
			heap_read(H1',H1,L1'),
			H1',
			H1,
			heap_read(H2',H2,L1'),
			H2',
			H2,
			.List,
			.Map,
			.Map,.Map)))
		+Mem
		mergeStackedScopes1(S,H1',H1,S,H2',H2)
    */










endmodule
