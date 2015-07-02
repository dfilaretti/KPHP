module LATTICE
       
	   syntax ErrFlag ::= "MayBeNull" | "VisibilityErr" | "ImplicitTypeConversion"
	   
	   syntax ErrFlags ::= ErrListItem(ErrFlag) [function, hook(List:ListItem)] 
	   syntax ErrFlags ::= ErrFlags "/" ErrFlags [left, function, hook(List:__), klabel('_List_)]
	   syntax ErrFlags ::= ".ErrFlags" [function, hook(List:.List)]
	   
       syntax AStringValue ::= "AStringTop" | String
       
	   syntax AString ::= "(" AStringValue "," ErrFlags ")"
	   
       syntax AIntValue ::= "AInt" 
	   
	   syntax AInt ::= "(" AIntValue "," ErrFlags ")"
	
       syntax ABoolValue ::= "ABool" 

	   syntax ABool ::= "(" ABoolValue "," ErrFlags ")"	   
	   
       syntax AFloatValue ::= "AFloat"
	   
	   syntax AFloat ::= "(" AFloatValue "," ErrFlags ")"
	   
	   syntax ANumValue ::= AFloatValue | AIntValue | "ANum"
	   
	   syntax ANum ::= AInt| AFloat| "(" "ANum" "," ErrFlags ")"
	   
	   syntax Scalar ::= ANumValue | AStringValue | ABoolValue | Null | Bot
	
	   syntax Scalar ::= "getValue" "(" DomainValue ")" [function]
	   
	   syntax DomainValue ::= ANum | AString | ABool | Null
	   
	   syntax VEPair ::= "VE" "(" Scalar "," ErrFlags ")"
	   
	   syntax VEPair ::= "lub_Domain" "(" DomainValue "," DomainValue ")" [function]
	   
	   syntax PlainLanguageValue ::= "specify" "(" VEPair ")" [function]

	   syntax AInt ::= "specify_AInt" "(" VEPair ")" [function]
	   
	   syntax AFloat ::= "specify_AFloat" "(" VEPair ")" [function]
	   
	   syntax AString ::= "specify_AString" "(" VEPair ")" [function]
	   
	   syntax ABool ::= "specify_ABool" "(" VEPair ")" [function]
	  
	   syntax VEPair ::= "generalize" "(" DomainValue ")" [function]
	   
	   rule generalize( (V,E):AInt) => VE(V,E)
	   rule generalize( (V,E):AFloat) => VE(V,E)
	   rule generalize( (V,E):AString) => VE(V,E)
	   rule generalize( (V,E):ABool) => VE(V,E)
	  
	  
	   rule specify(VE(V:AIntValue, E)) => specify_AInt(VE(V,E))	
	   rule specify(VE(V:AFloatValue, E)) => specify_AFloat(VE(V,E))
	   rule specify(VE(V:AStringValue, E)) => specify_AString(VE(V,E))
	   rule specify(VE(V:ABoolValue, E)) => specify_ABool(VE(V,E))
	   rule specify(VE(NULL, _) ) => NULL
	  
	   rule specify_AInt ( VE(I:AIntValue, E) ) => (I,E)
	   rule specify_AFloat ( VE(F:AFloatValue, E) ) => (F,E)
	   rule specify_AString ( VE(S:AStringValue, E) ) => (S,E)
	   rule specify_ABool ( VE(B:ABoolValue, E) ) => (B,E)
	  
	  
	   rule getValue( (V:AIntValue, E:ErrFlags) ) => V
	   rule getValue( (V:AFloatValue, E:ErrFlags) ) => V
	   rule getValue( (V:AStringValue, E:ErrFlags) ) => V
	   rule getValue( (V:ABoolValue, E:ErrFlags) ) => V
	   
	   
	   rule lub(V1:DomainValue, V2:DomainValue) => specify(lub_Domain(V1, V2))
	   when V1 =/=K Bot andBool V2 =/=K Bot
	   
	   //TODO : lub (Array(), NULL)
	   //rule lub(A:Array, B:K) => Top
	  // when A =/=K B
	   
	   syntax ErrFlags ::= "getErrFlags" "(" K ")" [function]
	   
	   rule getErrFlags ( (V:AIntValue, E:ErrFlags) ) => E
	   rule getErrFlags ( (V:AFloatValue, E:ErrFlags) ) => E
	   rule getErrFlags ( (V:AStringValue, E:ErrFlags) ) => E
	   rule getErrFlags ( (V:ABoolValue, E:ErrFlags) ) => E
	   rule getErrFlags( NULL ) => .ErrFlags
	   
	   rule lub_Domain(D1,D2) =>  VE ( lub_Value(getValue(D1), getValue(D2)), mergeList(getErrFlags(D1), getErrFlags(D2)) )
	   when D1 =/=K NULL andBool D2 =/=K NULL
	   
	   rule lub_Domain( D1, NULL) => VE (getValue(D1), mergeList (ErrListItem(MayBeNull), getErrFlags(D1)))
	   when D1 =/=K NULL
	   
	   rule lub_Domain(NULL, NULL) => VE(NULL, .ErrFlags)
	   
	   rule lub_Domain( NULL, D1) => VE(getValue(D1), mergeList (ErrListItem(MayBeNull), getErrFlags(D1)))
	   
       syntax Scalar ::= "lub_Value" "(" Scalar "," Scalar ")" [function]
       rule lub_Value(ABool, ABool)=>ABool	   
	   rule lub_Value(S1:String, S2:String)=>AStringTop
	   when S1 =/=String S2
	   
	   rule lub_Value(S1:String, S2:String)=>S1
	   when S1 ==String S2

       rule lub_Value(AStringTop, X:AStringValue)=>AStringTop

       rule lub_Value(X:AStringValue, AStringTop)=>AStringTop

	   rule lub_Value(ANum, N:ANumValue)=>ANum
	   
	   rule lub_Value(N:ANumValue, ANum)=>ANum
	   
	   rule lub_Value(I:AIntValue, F:AFloatValue)=>ANum
	   
	   rule lub_Value(F:AFloatValue, I:AIntValue)=> ANum
	   
	   rule lub_Value(I1:AIntValue, I2:AIntValue) => AInt

	   rule lub_Value(F1:AFloatValue, F2:AFloatValue) => AFloat
	   
	   rule lub_Value(Bot, V) => V
	   
	   rule lub_Value(V, Bot) => V
	   
	   syntax Scalar ::= "valueOfErr"  "(" ErrFlag ")" [function]
	   
	   rule valueOfErr( MayBeNull) => NULL
	   
	   rule valueOfErr( VisibilityErr) => Bot
	   
	   rule valueOfErr( ImplicitTypeConversion) => Bot

	   syntax Scalar ::= "valueOfErrs" "(" ErrFlags ")" [function]
	   
	   rule valueOfErrs(.ErrFlags) => Bot
	  
	   rule valueOfErrs(ErrListItem(E) / L) => lub_Value(valueOfErr(E), valueOfErrs(L))
	   
	   
	   syntax Bool ::= "keepErrFlag" "(" ErrFlag ")" [predicate] 		//true if valueOfErr = Bot ?
	   
	   rule keepErrFlag(MayBeNull) => false
	   
	   rule keepErrFlag(VisibilityErr) => true
	   
	   rule keepErrFlag(ImplicitTypeConversion) => true
	   
	   syntax ErrFlags ::= "FilterErrFlags" "(" ErrFlags ")" [function]
	   
	   rule FilterErrFlags(.ErrFlags) => .ErrFlags
	   
	   rule FilterErrFlags(ErrListItem(E) / L) => FilterErrFlags(L)
	   when notBool(keepErrFlag(E))
	   
	   rule FilterErrFlags(ErrListItem(E) / L) => ErrListItem(E) / FilterErrFlags(L)
	   when keepErrFlag(E)
	   
	   syntax 	Bool ::= K "<Lattice" K		[function]
	   syntax Bool ::= Scalar "<ScalarLattice" Scalar [function]
	   
	   rule D1:DomainValue <Lattice D2:DomainValue => generalize(D1) <Lattice generalize(D2)  //TODO : this looks like it's not working
	   
	   rule VE(V1, E1):VEPair <Lattice VE(V2, E2):VEPair => (V1 <ScalarLattice V2) andBool (E1 incList E2) 
	   
	   rule Top <Lattice X:K => false
	   rule X:K <Lattice Bot => false
	   
	   rule X:K <Lattice Top => true
	   when X =/=K Top
	   
	   rule Bot <Lattice X:K => true
	   when X =/=K Bot
	   
	   rule AInt <ScalarLattice AInt => false
	   rule (AFloat <ScalarLattice AFloat) => false
//TODO	   rule "ANum" <ScalarLattice X:ANum => false
	   rule (AInt <ScalarLattice AFloat) => false
	   rule (AFloat <ScalarLattice AInt) => false
	   rule (AInt <ScalarLattice ANum) => true
	   rule (AFloat <ScalarLattice ANum) => true
	   
	   rule  AStringTop <ScalarLattice AStringTop => false
	   rule AStringTop <ScalarLattice X:Scalar => false
	   rule S:String <ScalarLattice S2:String => false
	   rule S:String <ScalarLattice AStringTop => true
	   
	   syntax 	Bool ::= K ">Lattice" K		[function]
	   
	   rule A:K >Lattice B:K => B <Lattice A
	   
	   
	   syntax  Bool ::= "valid" "(" ABool ")"	                [predicate]
	   syntax  Bool ::= "unsatisfiable" "(" ABool ")"    		[predicate]
	   
	   rule valid(_) => false
	   rule unsatisfiable(_) => false
	   
	   //list manipulation //TODO move
	   
	   syntax Bool ::= ErrFlag "inList" ErrFlags   [function]
	   rule K1:ErrFlag inList ErrListItem(K2:ErrFlag) / L2:ErrFlags => K1 ==K K2 orBool  K1 inList L2
	   
	   rule _ inList .ErrFlags => false
	   
	   
	   syntax ErrFlags ::= "mergeList" "(" ErrFlags "," ErrFlags ")" [function]
	   
	   rule mergeList(.ErrFlags, L) => L
	   
	   rule mergeList(ErrListItem(E1) / L1:ErrFlags, L2:ErrFlags) => mergeList(L1, L2)
	   when E1 inList L2
	   
	   rule mergeList (ErrListItem(E1) / L1:ErrFlags, L2:ErrFlags) => mergeList(L1, ErrListItem(E1) / L2)
	   when notBool(E1 inList L2)
	   
	   syntax Bool ::= ErrFlags "incList" ErrFlags [function]
	   
	   rule .ErrFlags incList _ => true
	   
	   rule ErrListItem(E1:ErrFlag) / L1:ErrFlags incList L2:ErrFlags => false
	   when notBool(E1 inList L2)
	   
	   rule ErrListItem(E1:ErrFlag) / L1:ErrFlags incList L2:ErrFlags => L1 incList L2
	   when E1 inList L2
	   

endmodule