import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class ZvalArray extends Zval {
	public String optionArrayItem;
	public String wholeArray;
	public String[] elements;
	
	public ZvalArray (String type, int refCount, boolean isRef, String oai, String wa) {
		super(type, refCount, isRef);
		this.optionArrayItem = oai;
		this.wholeArray = wa;
		
		elements = wa.split("ListItem");
	}
	
	public String getOAItem() {
		return optionArrayItem;
	}
	
	public String[] getElements() {
		return elements;
	}
	
	
	
 }
