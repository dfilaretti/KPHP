module LATTICE
       
       syntax AString ::= "AStringTainted" | "AStringUntainted" | "AStringTop" | "AStringBot"
       
       syntax AInt ::= "AInt"

       syntax ABool ::= "ABool"

       syntax AFloat ::= "AFloat"

       syntax  AInt ::= "lub_AInt" "(" AInt "," AInt ")" [function]
       
       rule lub_AInt(AInt, AInt) => AInt

       syntax  AFloat ::= "lub_AFloat" "(" AFloat "," AFloat ")" [function]

       rule lub_AFloat (AFloat, AFloat) => AFloat

       syntax  ABool ::= "lub_ABool" "(" ABool "," ABool ")" [function]

       rule lub_ABool(ABool, ABool)=>ABool

       syntax  AString ::= "lub_AString" "(" AString "," AString ")" [function]

       rule lub_AString(AStringUntainted, AStringUntainted)=>AStringUntainted

       rule lub_AString(AStringTainted, AStringTainted)=>AStringTainted

       rule lub_AString(AStringTainted, AStringUntainted)=>AStringTop

       rule lub_AString(AStringUntainted, AStringTainted)=>AStringTop

       rule lub_AString(AStringTop, X)=>AStringTop

       rule lub_AString(X, AStringTop)=>AStringTop

       rule lub_AString(AStringBot,X)=>X
       
       rule lub_AString(X,AStringBot)=>X
	   
	   
	   //no reduction rules for these
	   syntax  Bool ::= "valid" "(" ABool ")"	                [predicate]
	   syntax  Bool ::= "unsatisfiable" "(" ABool ")"    		[predicate]
	   
	   
	   
	   
	   
	   

endmodule