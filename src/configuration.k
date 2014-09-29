require "init.k"

module CONFIGURATION
	imports INIT

// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Configuration} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

configuration
	<M multiplicity="*">	
		<mode multiplicity="*"> $MODE:Mode </mode>
		<pgm multiplicity="*"> $PGM:K </pgm>
		<initState multiplicity="*"> $CFG:Bag </initState> 
	</M>	
	
	<kphp multiplicity="*">
		<script color="pink">
			<declarations> .K </declarations>
			<commands> .K </commands>
			//<k> buildInitState ~> $PGM:K </k>
			<k> .K </k>
		</script>	
		<tables color="yellow">
			<functions> .Map </functions>
    		<classes> .Map </classes>
    		<constants> .Map </constants>
    		<classInstanceCounters> .Map </classInstanceCounters>
    	</tables>	
		<br/>
	    <scopes color="green">
			<currentScope> .K </currentScope>
			<globalScope> .K </globalScope>
        	<globalStaticScope> .K </globalStaticScope> 
        	<superGlobalScope> .K </superGlobalScope>
		</scopes>
		<heap color="red"> .Map </heap>
		<br/>
		<control color="cyan">	
			<functionStack> .List </functionStack>
			<exceptionStack> .List </exceptionStack>
			<loopStack> .List </loopStack> 
			<context color="pink">
				<currentForeachItem> .K </currentForeachItem> 
				<object> .K </object>
                <class> .K </class> 
                <function> .K </function>
			</context>
			<br/>
			<functionArgumentsDeclaration> .K </functionArgumentsDeclaration>
			<processedFunBody> .K  </processedFunBody>
			<processedStaticDeclarations> .K </processedStaticDeclarations>
		</control>	
     	<br/> 		
     	<IO color="magenta">
     		
     		
     		<in stream="stdin"> .List </in>
     		<out stream="stdout"> .List </out>	
            
            
            /*            
            <in> .List </in>
     		<out> .List </out>	
            */

            <exitStatus> .K </exitStatus>
     		<errorManagement> .K </errorManagement>
     		<varDumpLevel> .K </varDumpLevel>
     	</IO>
		<br/>
		<instrumentation color="red">
			<cleanTraceOnTermination> .K </cleanTraceOnTermination> 
			<isTerminated> .K </isTerminated> 
			<label> .K </label>
		</instrumentation>     		
		
		// temporary stuff needed for breakpoints
		<trash> .Map </trash>
		<lastUsedLoc> .K </lastUsedLoc>		
		// --------------------------------------
		
		<gc color="blue"> 
			<locationsToCollect> .List </locationsToCollect>
			<gcEnabled> .K </gcEnabled>
		</gc>
		<trace> .List </trace> 
    </kphp>

endmodule
