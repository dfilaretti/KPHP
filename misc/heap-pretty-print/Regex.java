import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
public interface Regex {

    /**
     * Regular expression for a space
     */

    public static final String SPACE_REGEX = "[ \t\n\f\r]*";

    public static final String COMMA_REGEX = SPACE_REGEX + "," + SPACE_REGEX;
    public static final String LS_REGEX = SPACE_REGEX + "\\(" + SPACE_REGEX;
    public static final String RS_REGEX = SPACE_REGEX + "\\)" + SPACE_REGEX;
    public static final String LM_REGEX = SPACE_REGEX + "\\[" + SPACE_REGEX;
    public static final String RM_REGEX = SPACE_REGEX + "\\]" + SPACE_REGEX;
    public static final String MAP_REGEX = SPACE_REGEX + "\\|->" + SPACE_REGEX;
    
    public static final String INT_REGEX = "[0-9]+";
    public static final String TF_REGEX = "true|false";
    public static final String VR_REGEX = "@byValue|@byRef";
    public static final String WORD_REGEX = "[0-9_a-zA-Z]+";
    public static final String ID_REGEX = "[^ ,\\[\\]\\{\\}]+";
    public static final String NAT_REGEX = "[^@]+";
    
    public static final String VISI_REGEX = "public|protected|" + LS_REGEX + "private" + LS_REGEX + WORD_REGEX + RS_REGEX + RS_REGEX;     
    public static final String LOC_REGEX = "#symLoc" + LS_REGEX + INT_REGEX + RS_REGEX;
    
    public static final String AITEM_REGEX_GROUP = LM_REGEX + "(" + ID_REGEX + ")" + COMMA_REGEX  + "(" + VISI_REGEX + ")"+ COMMA_REGEX + "(" +LOC_REGEX + ")"+ RM_REGEX;
    public static final String AITEM_REGEX = LM_REGEX + ID_REGEX + COMMA_REGEX + ID_REGEX + COMMA_REGEX + LOC_REGEX + RM_REGEX;

    // !!
    public static final String AAITEM_REGEX = LM_REGEX + ID_REGEX + COMMA_REGEX + ID_REGEX + RM_REGEX;
    
    // ---
    //public static final String OAITEM_REGEX = "none|" + LS_REGEX + AITEM_REGEX + RS_REGEX;
    // ---    

    public static final String OAITEM_REGEX = "none|" + LS_REGEX + AAITEM_REGEX + RS_REGEX;

    public static final String ALITEM_REGEX = "ListItem" + LS_REGEX + AITEM_REGEX + RS_REGEX;    
    public static final String ALIST_REGEX = ".List|(" + ALITEM_REGEX + ")+";
       
    public static final String ARRAY_REGEX_GROUP = LS_REGEX + "Array" + LS_REGEX + "(" + OAITEM_REGEX + ")" + COMMA_REGEX + "(" + ALIST_REGEX  + ")"+ RS_REGEX + RS_REGEX;

    public static final String OID_REGEX = LS_REGEX + "OID" + LS_REGEX + LOC_REGEX + COMMA_REGEX + ID_REGEX + COMMA_REGEX + INT_REGEX + RS_REGEX + RS_REGEX;
    public static final String OID_REGEX_GROUP = LS_REGEX + "OID" + LS_REGEX + "(" + LOC_REGEX + ")" + COMMA_REGEX + "(" + ID_REGEX + ")" + COMMA_REGEX + "(" + INT_REGEX + ")" + RS_REGEX + RS_REGEX;
   // public static final String VALUE_REGEX = "(" + ARRAY_REGEX + "|" + ID_REGEX + ")";
    public static final String ZVALUE_REGEX = "zval" + LS_REGEX + "(" + ARRAY_REGEX_GROUP + "|" + ID_REGEX + "|" + OID_REGEX +")" + COMMA_REGEX + "(" + WORD_REGEX +")" + COMMA_REGEX + "(" + INT_REGEX +")"+ COMMA_REGEX + "(" + TF_REGEX +")"+ RS_REGEX;
//mem node loc: group1, zval:group2
	
    public static final String MNODE_REGEX = "(" + LOC_REGEX + ")" + MAP_REGEX + "(" + ZVALUE_REGEX + ")";
    
    public static final String PROP_REGEX = "prop" + LS_REGEX + ID_REGEX + COMMA_REGEX + ID_REGEX + COMMA_REGEX + ID_REGEX + RS_REGEX;
    public static final String PLITEM_REGEX = "ListItem" + LS_REGEX + PROP_REGEX + RS_REGEX;    
    public static final String PLIST_REGEX = ".List|(" + PLITEM_REGEX + ")+";
    
    public static final String FUNCTION_REGEX = "f" + LS_REGEX  + NAT_REGEX + "(" +VR_REGEX + ")" + COMMA_REGEX + "(" + LOC_REGEX + ")" + RS_REGEX;
    public static final String FNODE_REGEX = "(" + ID_REGEX + ")" + MAP_REGEX + FUNCTION_REGEX;
    public static final String METHOD_REGEX = ID_REGEX + MAP_REGEX +"method" + LS_REGEX  + LS_REGEX  + FUNCTION_REGEX + RS_REGEX + COMMA_REGEX + "(" + VISI_REGEX + ")" + COMMA_REGEX + "(" + TF_REGEX + ")" + RS_REGEX;
    public static final String METHOD_REGEX_GROUP = "(" + ID_REGEX + ")" + MAP_REGEX +"method" + LS_REGEX  + LS_REGEX  + FUNCTION_REGEX + RS_REGEX + COMMA_REGEX + "(" + VISI_REGEX + ")" + COMMA_REGEX + "(" + TF_REGEX + ")" + RS_REGEX;
    public static final String METHODS_REGEX = ".Map|(" + METHOD_REGEX + ")+";
    public static final String CLASS_REGEX = "class" + LS_REGEX + "(" + ID_REGEX + ")" + COMMA_REGEX + "(" + PLIST_REGEX + ")" + COMMA_REGEX + "(" + METHODS_REGEX + ")" + COMMA_REGEX + "(" + LOC_REGEX + ")" + RS_REGEX;
    public static final String CNODE_REGEX = "(" + ID_REGEX + ")" + MAP_REGEX + CLASS_REGEX;
}