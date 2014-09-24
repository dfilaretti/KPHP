module ATERM-TO-KAST-SYNTAX

	syntax ListWrap ::= "[" ATermList "]" [strict]
                  	  | "[" "]"

	syntax ATerm ::= Id "(" ATermList ")" [strict(2)]
                   | Id "(" ")"
                   | ListWrap
                   | String 
                   | Int

	syntax ATermList ::= ATerm
                       | ATerm "," ATermList [strict]

endmodule

module ATERM-TO-KAST
    imports ATERM-TO-KAST-SYNTAX

	configuration 
		<T color="yellow">
    		<k color="green"> $PGM:K </k>
			<out color="LightPink" stream="stdout"> .List </out>
		</T>

	syntax ResultTerm ::= "res" "(" String ")"
	syntax ATerm ::= ResultTerm
	syntax KResult ::= ResultTerm

	rule Str:String => res("# \"" +String Str +String "\"(.KList)")

	rule I:Int => res("# " +String Int2String(I) +String "(.KList)")

	rule X:Id(res(Str:String)) => res("'" +String Id2String(X) +String "(" +String Str +String ")")

	rule X:Id() => res( "'" +String Id2String(X) +String "(.KList)" )

	rule [ res(Str:String) ] => res("'ListWrap(" +String Str +String ")")

	rule [] => res("'ListWrap(.KList)")

	rule res(Str1:String) , res(Str2:String) => res(Str1 +String ",," +String Str2)

	rule <k> res(Str:String) => . </k>
     	<out>... . => ListItem(Str) ListItem("\n") </out>

endmodule
