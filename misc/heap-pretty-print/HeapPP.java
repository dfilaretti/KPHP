import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class HeapPP implements Regex 
{
	public static final String[] searchList=new String[]{"classes","functions","heap","globalScope","superGlobalScope","globalStaticScope", "currentScope"};
	private HashMap<String,String> tagContentPair;
	
	public String convertToOpeningTag(String s){
		return "<"+s+">";
	}
	public String convertToClosingTag(String tag){
		String str=tag.replace("<", "</");
		return str;
	}
	
	public HeapPP(String fileName){
		String curTag=null;
		this.tagContentPair=new HashMap<String,String>();
		
		try {
			Scanner scan=new Scanner(new File(fileName));
			
			while(scan.hasNextLine()){
				String curLine=scan.nextLine();
				
				//not inside a cell
				if(curTag==null){
				for(int i=0; i<searchList.length; i++){
				int index=curLine.indexOf(this.convertToOpeningTag(searchList[i]));
				if(index==-1)
					continue;
				
				else{			
					curTag=this.convertToOpeningTag(searchList[i]);
					String content=curLine.substring(index+curTag.length());
					tagContentPair.put(curTag, content+"\n");
				}
				
				}
				
				}
				
				//inside a desired cell
				else{
					String closingTagName=this.convertToClosingTag(curTag);
					int endIndex=curLine.indexOf(closingTagName);
					
					if(endIndex==-1)
					{
						tagContentPair.put(curTag,tagContentPair.get(curTag)+curLine+"\n");
					}
					
					else{
						String lastC=curLine.substring(0,endIndex);
						tagContentPair.put(curTag,tagContentPair.get(curTag)+lastC+"\n");
						
						curTag=null;
					}
					
				}
				
				
							
			}
			
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	public String getCellContent(String tagName){
		String val=tagContentPair.get(tagName);
		if(val!=null)
			return val;
		
		else{
			System.out.println("No records for the tag "+tagName);
			return "";
		}
	}
	
	public static String addSlash(String str){
		String newStr=str.replace("'","\\'");		
		newStr=newStr.replace("\"","\\\"");		
		newStr=newStr.replaceAll("\\s", "");		
		return newStr;
	}
	
	public static String reverseAddSlash(String str){
		String newStr=str.replace("\\'",",");		
		newStr=newStr.replace("\\\"","\"");		
		return newStr;
	}
	
	public static String numberOnly(String str){
		String newStr=str.replaceAll("[^0-9]","");
		return newStr;
	}
	
	public static String removeQuotes(String str){
		String newStr=str.replace("\\\"","");
		newStr=newStr.replace("\\'","");
		return newStr;
	}

	 
	public static void main(String[] args) throws FileNotFoundException {
	FileOutputStream bos = new FileOutputStream(args[0] + ".gv");	System.setOut(new PrintStream(bos));
	HeapPP obj=new HeapPP(args[0]); 
	String mem = addSlash(obj.getCellContent(obj.convertToOpeningTag("heap")));
	String functions = addSlash(obj.getCellContent(obj.convertToOpeningTag("functions")));
	String classes = addSlash(obj.getCellContent(obj.convertToOpeningTag("classes")));
	String globScope = numberOnly(obj.getCellContent(obj.convertToOpeningTag("globalScope")));
	String superGlobalScope = numberOnly(obj.getCellContent(obj.convertToOpeningTag("superGlobalScope")));
	String globStaticScope = numberOnly(obj.getCellContent(obj.convertToOpeningTag("globalStaticScope")));
	String crntScope = numberOnly(obj.getCellContent(obj.convertToOpeningTag("currentScope")));

	
		
	HashMap<String,Zval> memory = new HashMap<String,Zval>();	
	HashMap<String, ClassMethod> classMethods = new HashMap<String,ClassMethod>();	
	
		Pattern pattern = Pattern.compile(MNODE_REGEX);
		Matcher matcher = pattern.matcher(mem);
		
		while (matcher.find()) 
		{	    
		    if (matcher.group(7).equals("array")){
		    	memory.put(numberOnly(matcher.group(1)), new ZvalArray(matcher.group(7),Integer.valueOf(matcher.group(8)), Boolean.valueOf(matcher.group(9)), matcher.group(4), matcher.group(5)) );
		    }
		    else if (matcher.group(7).equals("object")){
		    	memory.put(numberOnly(matcher.group(1)), new ZvalOID(matcher.group(7),Integer.valueOf(matcher.group(8)), Boolean.valueOf(matcher.group(9)), matcher.group(3)));
		    }
		    else {
		    	memory.put(numberOnly(matcher.group(1)), new ZvalScalar(matcher.group(7),Integer.valueOf(matcher.group(8)), Boolean.valueOf(matcher.group(9)), matcher.group(3)));
		    }
		    
		}
System.out.println("digraph G {");	


//mem subgraph
		
if(args[1].equals("basic"))	{	
	System.out.println("subgraph cluster_mem {");
	System.out.println("style=filled;");
	System.out.println("color=lightgrey;");
	System.out.println("label = \"mem\"; ");

	for (Entry<String, Zval> entry : memory.entrySet()) {
	    String key = entry.getKey();
	    System.out.println(key);
		System.out.println("[");
		System.out.println("shape=none");
		if (key.equals(globScope)||key.equals(crntScope)||key.equals(globStaticScope)||key.equals(superGlobalScope)){
			System.out.println("color=green");
		}
		if (entry.getValue().getIsRef()){
		System.out.println("style=filled");
    		System.out.println("fillcolor=orange");
    		}    	
		
		System.out.println("label = <<table>");
		
		
	    if (entry.getValue().getClass().equals(ZvalArray.class)){
	    	ZvalArray value = (ZvalArray) entry.getValue();
	    	   	
	    	if (value.getElements().length == 1){
   		System.out.println("<tr><td>   </td></tr>");
		}
	    	for (String s: value.getElements()){
	    		Pattern pattern1 = Pattern.compile(AITEM_REGEX_GROUP);
	    		Matcher matcher1 = pattern1.matcher(s);
	    		if (matcher1.find()){
	    			//public,private,protected
	    			
	    			if(s.equals(value.getOAItem())){
if(matcher1.group(2).equals("pro")){System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\" bgcolor=\"red\">" + "(protected) " + reverseAddSlash(matcher1.group(1)) + "</td></tr>");}
else if(matcher1.group(2).contains("pri")){System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\" bgcolor=\"red\">" + matcher1.group(2).replace("pri","private") + " " + reverseAddSlash(matcher1.group(1)) + "</td></tr>");}
else{System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\" bgcolor=\"red\">" + "(public) " + reverseAddSlash(matcher1.group(1)) + "</td></tr>");}
	    			}else{
if(matcher1.group(2).equals("pro")){System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\">" + "(protected) " + reverseAddSlash(matcher1.group(1)) + "</td></tr>");}
else if(matcher1.group(2).contains("pri")){System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\">" + matcher1.group(2).replace("pri","private") + " " + reverseAddSlash(matcher1.group(1)) + "</td></tr>");}
else{System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\">" + "(public) " + reverseAddSlash(matcher1.group(1)) + "</td></tr>");}
	    			}
	    		}
	    	}
	    	System.out.println("</table>>");
	    	System.out.println("]");    	
	    	
	    	//arrows
	    	for (String s: value.getElements()){    		
	    		Pattern pattern1 = Pattern.compile(AITEM_REGEX_GROUP);
	    		Matcher matcher1 = pattern1.matcher(s);
	    		if (matcher1.find()){
	    			System.out.println(key + ":" + removeQuotes(matcher1.group(1)) + " -> " + numberOnly(matcher1.group(3)) + ";");
	    		}
	    	}
	    }
	    
	    else if (entry.getValue().getClass().equals(ZvalOID.class)){
	    	ZvalOID value = (ZvalOID) entry.getValue();
	    	
	    	System.out.println("<tr><td>object of class " + value.getObjClass() + "</td></tr>");
	    	System.out.println("</table>>");
	    	System.out.println("]");    
	    	
	    	//arrow
	    	System.out.println(key + " -> " + numberOnly(value.getObjLoc()) + ";");
	    }
	    
	    else {
	    	ZvalScalar value = (ZvalScalar) entry.getValue();
	    	
	    	System.out.println("<tr><td>" + reverseAddSlash(value.getScalarValue()) + "</td></tr>");
	    	System.out.println("</table>>");
	    	System.out.println("]"); 
	    }
	}
	System.out.println("}");

}else{
System.out.println("subgraph cluster_mem {");
System.out.println("style=filled;");
System.out.println("color=lightgrey;");
System.out.println("label = \"mem\"; ");

for (Entry<String, Zval> entry : memory.entrySet()) {
    String key = entry.getKey();
    System.out.println(key);
	System.out.println("[");
	System.out.println("shape=none");
	if (key.equals(globScope)||key.equals(crntScope)||key.equals(globStaticScope)||key.equals(superGlobalScope)){
			System.out.println("color=green");
		}
	
	System.out.println("label = <<table>");
	
	if (entry.getValue().getIsRef()){
		System.out.println("<tr><td>" + key + "</td><td>" + entry.getValue().getType()+ "</td><td bgcolor=\"orange\" >" + entry.getValue().getRefCount() + "</td></tr>");
	}
	else {
		System.out.println("<tr><td>" + key + "</td><td>" + entry.getValue().getType()+ "</td><td>" + entry.getValue().getRefCount() + "</td></tr>");
	}
	
    if (entry.getValue().getClass().equals(ZvalArray.class)){
    	ZvalArray value = (ZvalArray) entry.getValue();
    	    	   	
    	for (String s: value.getElements()){
    		Pattern pattern1 = Pattern.compile(AITEM_REGEX_GROUP);
    		Matcher matcher1 = pattern1.matcher(s);
    		if (matcher1.find()){
    			//public,private,protected
if(s.equals(value.getOAItem())){
if(matcher1.group(2).equals("pro")){System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\"  bgcolor=\"red\">" + reverseAddSlash(matcher1.group(1)) + "</td><td bgcolor=\"red\">protected</td><td bgcolor=\"red\">" + numberOnly(matcher1.group(3)) +"</td></tr>");}
else if(matcher1.group(2).contains("pri")){System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\"  bgcolor=\"red\">" +   reverseAddSlash(matcher1.group(1)) + "</td><td bgcolor=\"red\">" + matcher1.group(2).replace("pri","private") + "</td><td bgcolor=\"red\">" + numberOnly(matcher1.group(3)) +"</td></tr>");}
else{System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\"  bgcolor=\"red\">" + reverseAddSlash(matcher1.group(1)) + "</td><td bgcolor=\"red\">public</td><td bgcolor=\"red\">" + numberOnly(matcher1.group(3)) +"</td></tr>");}
	    			}else{
if(matcher1.group(2).equals("pro")){System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\" >" + reverseAddSlash(matcher1.group(1)) + "</td><td>protected</td><td>" + numberOnly(matcher1.group(3)) +"</td></tr>");}
else if(matcher1.group(2).contains("pri")){System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\" >" +   reverseAddSlash(matcher1.group(1)) + "</td><td>" + matcher1.group(2).replace("pri","private") + "</td><td>" + numberOnly(matcher1.group(3)) +"</td></tr>");}
else{System.out.println("<tr><td port=\"" + removeQuotes(matcher1.group(1)) + "\" >" + reverseAddSlash(matcher1.group(1)) + "</td><td>public</td><td>" + numberOnly(matcher1.group(3)) +"</td></tr>");}
	    			}

    		}
    	}
    	System.out.println("</table>>");
    	System.out.println("]");    	
    	
    	//arrows
    	for (String s: value.getElements()){    		
    		Pattern pattern1 = Pattern.compile(AITEM_REGEX_GROUP);
    		Matcher matcher1 = pattern1.matcher(s);
    		if (matcher1.find()){
    			System.out.println(key + ":" + removeQuotes(matcher1.group(1)) + " -> " + numberOnly(matcher1.group(3)) + ";");
    		}
    	}
    }
    
    else if (entry.getValue().getClass().equals(ZvalOID.class)){
    	ZvalOID value = (ZvalOID) entry.getValue();    	   	
    	System.out.println("<tr><td>" + numberOnly(value.getObjLoc()) + "</td><td>" + value.getObjClass() + "</td><td>" + value.getObjInt() + "</td></tr>");
    	System.out.println("</table>>");
    	System.out.println("]");    
    	
    	//arrow
    	System.out.println(key + " -> " + numberOnly(value.getObjLoc()) + ";");
    }
    
    else {
    	ZvalScalar value = (ZvalScalar) entry.getValue();    	
    	System.out.println("<tr><td COLSPAN=\"3\">" + reverseAddSlash(value.getScalarValue()) + "</td></tr>");
    	System.out.println("</table>>");
    	System.out.println("]"); 
    }
}
System.out.println("}");
}

//functions subgraph
//if (args[2].equals("sf")) {
System.out.println("subgraph cluster_functions {");
System.out.println("style=filled;");
System.out.println("color=lightpink;");
System.out.println("label = \"functions\"; ");
System.out.println("node [style=filled,color=yellow];");
Pattern pattern2 = Pattern.compile(FNODE_REGEX);
Matcher matcher2 = pattern2.matcher(functions);	
while(matcher2.find()){
	System.out.println("\""+ matcher2.group(1) + "\";");
	}
//interaction between mem and functions
Matcher matcher22 = pattern2.matcher(functions);	
while(matcher22.find()){
	System.out.println("\""+ matcher22.group(1) + "\" -> " + numberOnly(matcher22.group(3)) + ";");
}
System.out.println("}");
//}



//classes subgraph
//if (args[3].equals("sc")) {
System.out.println("subgraph cluster_classes {");
System.out.println("style=filled;");
System.out.println("color=darkgreen;");
System.out.println("label = \"classes\";");
System.out.println("node [shape=diamond, peripheries=2, style=filled,color=lightblue];");
Pattern pattern3 = Pattern.compile(CNODE_REGEX);
Matcher matcher3 = pattern3.matcher(classes);	
while(matcher3.find()){	
	classMethods.put(matcher3.group(1), new ClassMethod(matcher3.group(5)));	
	System.out.println(matcher3.group(1) + " -> " + matcher3.group(2) + ";");	
	System.out.println(matcher3.group(1) + " -> " + numberOnly(matcher3.group(11)) + ";" );	
}
System.out.println("}");
//}




//methods subgraph
//if (args[4].equals("sm")) {
System.out.println("subgraph cluster_methods {");
System.out.println("style=filled;");
System.out.println("color=purple;");
System.out.println("label = \"methods\";");
System.out.println("node [shape=ellipse, peripheries=2, style=filled,color=yellow];");
for (Entry<String, ClassMethod> entry : classMethods.entrySet()) {    
    for (Entry<String,String> entry2 : entry.getValue().getScope().entrySet()) {
	System.out.println(entry.getKey() + " -> \"" + entry2.getKey() + "\";");	
	System.out.println("\"" + entry2.getKey() + "\" ->" + numberOnly(entry2.getValue()) + ";" );	
    }
}
System.out.println("}");
//}

System.out.println("}");
}

}

