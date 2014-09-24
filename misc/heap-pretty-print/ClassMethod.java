import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class ClassMethod implements Regex {
	//public ArrayList<String> methods;
	HashMap<String,String> methodScope = new HashMap<String,String>();	
	ClassMethod (String m){
		Pattern pattern = Pattern.compile(METHOD_REGEX_GROUP);
		Matcher matcher = pattern.matcher(m);
		while (matcher.find()){
			//methods.add(matcher.group(0));		
			methodScope.put(matcher.group(1), matcher.group(3));
		}
	}
	
	public HashMap<String,String> getScope (){
		return methodScope;
	}
}
