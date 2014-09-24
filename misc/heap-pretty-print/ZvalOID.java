import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class ZvalOID extends Zval {
	ZvalOID(String type, int refCount, boolean isRef, String obj) {
		super(type, refCount, isRef);
		this.zvalOID = obj;
		Pattern pattern = Pattern.compile(OID_REGEX_GROUP);
		Matcher matcher = pattern.matcher(obj);
			if (matcher.find()) 
				{
				this.objLoc = matcher.group(1);
				this.objClass = matcher.group(2);
				this.objInt = matcher.group(3);


				}
	}
	
	public String zvalOID;
	public String objLoc;
	public String objClass;
	public String objInt;
	
	
	public String getOID() {
		return zvalOID;
	}
	public String getObjLoc() {
		return objLoc;
	}
	public String getObjClass() {
			return objClass;
	}
	public String getObjInt() {
			return objInt;
	}
}
