Instruction for running kphp

1: Prerequisites
--------------------------------

KPHP requires The K Framework 3.4, which is the latest stable version. 
It can be downloaded at http://www.kframework.org/imgs/releases/k-stable.zip 
but note we provide a copy in ../third-party

2: The examples folder
--------------------------------

The examples folder contains a series of hello-world.php examples showing the 
basic usage of the various features (execution, model checking, symbolic execution), 
as well as the examples discussed in the paper. Each example contains instructions 
on how to run it.

3: Compiling kphp
--------------------------------

A K definition is compiled via the kompile command followed by the name of the file 
to be compiled. In our case kompile php.k .
Compiling without any additional options generates an executable version of the 
semantics (see following section). In order to be able to perform model checking and/or 
symbolic execution, it is necessary to provide additional options to kompile . 
See sections below.

4: Using the kphp interpreter
--------------------------------

NOTE: All the example commands shown here and in the comments in the examples are 
meant to be executed in the kphp/src folder.

 - Compile kphp for execution: kompile php.k
 - Run a program: scripts/kphp helloworld.php

Note: the kphp command is actually a simple wrapper (written by us) around the standard 
krun utility of the K toolchain. The command above is the same as the more verbose 
krun --parser="java -jar parser/parser.jar" helloworld.php , which also specifies 
the parser we intend to use.

5: Model checking a PHP script against an LTL property
--------------------------------

NOTE: there is currently an issue with the K tools which causes an exception 
to be thrown when checking a false LTL property on a program which prints 
some output on stdout . As a temporary solution, it is necessary to disable 
printing on stdout . This is simply done as follow:

 - open the configuration.k file
 - remove/comment the string stream="stdout" which is inside the "out" cell.

The semantics must be compiled with a --transition option followed by one or more tags, 
specifying the set of rules we wish to consider transitions.

For most immediate uses, we found it pratical to use the set of rules marked with the [step] tag 
as the set of transitions (and so does our examples from the paper): kompile php.k --transition="step"

However, any number of tags can be used, each combination of tags identifying a different 
set of transition rules and consequently a different notion of observable program state. 
For example, the command kompile php.k --transition="step internal" will tell the compiler 
to also consider [internal] rules as transitions.

Then, execute a program providing an LTL formula to krun : 
krun --parser="java -jar parser/parser.jar" examples/hello-world/hello-world-ltl.php --ltlmc="LtlTrue" 
Or, alternatively, it is also possible to write the LTL formula in a file: 
krun --parser="java -jar parser/parser.jar" examples/hello-world/hello-world-ltl.php --ltlmc helloLTL.txt

6: Symbolic execution
--------------------------------

Symbolic execution must also be enabled via the kompile command: 
kompile php.k --backend symbolic . As an additional argument (in a similar 
fashion to the --transition option used for model checking) it is possible to 
specify which set of rules will be transformed into symbolic ones. Again, for the 
current experiments we used the rules tagged as [step] : 
kompile php.k --backend symbolic --symbolic-rules="step" .

In order to symbolically execute a program, it is necessary to give as input 
an initial path contidion as well as a set of (possibly) sybolic inputs: 
krun --parser="java -jar parser/parser.jar" examples/hello-world/hello-world-symbolic.php -cPC="true" -cIN="ListItem(#symInt(x))"

7: Using state space search options
--------------------------------

Each case it encounters non determinism, the tool, by default, arbitrary chooses 
one of the available options. The --search option tells krun to instead 
explore all the possible paths in such cases.

The --search option comes really handy when used in conjunction with symbolic 
execution, in that it shows all of the execution paths followed by the symbolic execution.

8: Symbolic Execution + LTL model checking
--------------------------------

It is possible to enable model checking and symbolic execution at the same time. 
See the paper examples.

9: Getting help on K
--------------------------------

The K toolchain contains more options and functionalities that we describes here, 
and is constantly updated. The commands kompile -? and krun -? will provide a 
list of all the available options.
