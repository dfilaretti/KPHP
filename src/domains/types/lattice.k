module LATTICE
       
       syntax AString ::= "AStringTop" | "AStringBot" | String
       
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

       rule lub_AString(AStringBot,X)=>X
       
       rule lub_AString(X,AStringBot)=>X
	   
	   syntax ANum ::= "lub_ANum" "(" ANum "," ANum ")" [function]

	   rule lub_ANum(ANum, N:ANum)=>ANum
	   
	   rule lub_ANum(N:ANum, ANum)=>ANum
	   
	   rule lub_ANum(AInt, AFloat)=>ANum
	   
	   rule lub_ANum(AFloat, AInt)=> ANum
	   
	   rule lub_ANum(AInt, AInt) => AInt

	   rule lub_ANum(AFloat, AFloat) => AFloat
	   
	   
	   syntax  Bool ::= "valid" "(" ABool ")"	                [predicate]
	   syntax  Bool ::= "unsatisfiable" "(" ABool ")"    		[predicate]
	   
	   rule valid(ABool) => false
	   rule unsatisfiable(ABool) => false
	   
	   
	   
	   
	   

endmodule