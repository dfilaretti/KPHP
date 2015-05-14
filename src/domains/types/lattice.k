module LATTICE
       
       syntax AString ::= "AStringTop" | String
       
       syntax AInt ::= "AInt"

       syntax ABool ::= "ABool"

       syntax AFloat ::= "AFloat"
	   
	   syntax ANum ::= "ANum" | AFloat | AInt

       syntax  AInt ::= "lub_AInt" "(" AInt "," AInt ")" [function]
       
       rule lub_AInt(AInt, AInt) => AInt

       syntax  AFloat ::= "lub_AFloat" "(" AFloat "," AFloat ")" [function]

       rule lub_AFloat (AFloat, AFloat) => AFloat

       syntax  ABool ::= "lub_ABool" "(" ABool "," ABool ")" [function]

       rule lub_ABool(ABool, ABool)=>ABool

       syntax  AString ::= "lub_AString" "(" AString "," AString ")" [function]
	   
	   rule lub_AString(S1:String, S2:String)=>AStringTop

       rule lub_AString(AStringTop, X)=>AStringTop

       rule lub_AString(X, AStringTop)=>AStringTop
	   
	   syntax ANum ::= "lub_ANum" "(" ANum "," ANum ")" [function]

	   rule lub_ANum(ANum, N:ANum)=>ANum
	   
	   rule lub_ANum(N:ANum, ANum)=>ANum
	   
	   rule lub_ANum(AInt, AFloat)=>ANum
	   
	   rule lub_ANum(AFloat, AInt)=> ANum
	   
	   rule lub_ANum(AInt, AInt) => AInt

	   rule lub_ANum(AFloat, AFloat) => AFloat
	   
	   
	   
	   syntax 	Bool ::= K "<Lattice" K		[function]
	   
	   rule Top <Lattice X:K => false
	   rule X:K <Lattice Bot => false
	   
	   rule X:K <Lattice Top => true
	   when X =/=K Top
	   
	   rule Bot <Lattice X:K => true
	   when X =/=K Bot
	   
	   rule AInt <Lattice AInt => false
	   rule AFloat <Lattice AFloat => false
	   rule ANum <Lattice X:ANum => false
	   rule AInt <Lattice AFloat => false
	   rule AFloat <Lattice AInt => false
	   rule AInt <Lattice ANum => true
	   rule AFloat <Lattice ANum => true
	   
	   rule AStringTop <Lattice X:AString => false
	   rule S:String <Lattice S2:String => false
	   rule S:String <Lattice AStringTop => true
	   
	   syntax 	Bool ::= K ">Lattice" K		[function]
	   
	   rule A:K >Lattice B:K => B <Lattice A
	   
	   
	   syntax  Bool ::= "valid" "(" ABool ")"	                [predicate]
	   syntax  Bool ::= "unsatisfiable" "(" ABool ")"    		[predicate]
	   
	   rule valid(ABool) => false
	   rule unsatisfiable(ABool) => false
	   
	   
	   
	   
	   

endmodule