
public abstract class Zval implements Regex {	
	public String zvalType;
	public int zvalRefCount;
	public boolean zvalIsRef;
	
	Zval(String type, int refCount, boolean isRef){
		this.zvalType = type;
		this.zvalRefCount = refCount;
		this.zvalIsRef = isRef;
	}
	
	public String getType() {
		return zvalType;
	}
	
	public int getRefCount() {
		return zvalRefCount;
	}
	
	public boolean getIsRef() {
		return zvalIsRef;
	}
}
