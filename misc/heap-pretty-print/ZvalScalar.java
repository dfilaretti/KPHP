
public class ZvalScalar extends Zval {
	ZvalScalar(String type, int refCount, boolean isRef, String s) {
		super(type, refCount, isRef);
		this.zvalScalarValue = s;
	}

	public String zvalScalarValue;
	
	public String getScalarValue() {
		return zvalScalarValue;
	}
}
