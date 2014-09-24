--- PREREQUISITES ---

In order to use this tool you need to install Graphviz: http://graphviz.org

--- INTRO ---

heap-pp is a tool for converting an XML configuration 
(as obtained by running KPHP) into a nice graphical 
representation of it. It produces a GraphViz (*.gv) file
as output. GraphViz can be obtained at http://www.graphviz.org.
 
--- USAGE ---

The tool has two output modes.

 + verbose mode: it produces an 'exact' representation of the 
   configuration information, showing all the low-level details:
	
           java HeapPP your-config.xml verbose
 
 + basic mode: produces more compact graphical representation 
   of the configuration.

           java HeapPP your-config.xml basic
           
NOTE: in both cases, the tool produces an output file 'your-config.xml.gv'.

The XML configuration file can be obtained in the following way
(assuming the command is run from the main kphp source folders):

           krun --parser "java -jar parser/parser.jar" --output-file config.xml myPgm.php

Note than an example configuration 'example-configuration.xml', is 
provided in this folder.                      
