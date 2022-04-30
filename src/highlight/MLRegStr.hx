package highlight;

/**
 * ...
 * @author YellowAfterlife
 */
class MLRegStr {
	public static inline var rsNumber = ("[+-]?" + "(?:"
		+ "0x[0-9a-fA-F]+|"
		+ "0b[01]+|"
		+ "\\d+" + "(?:\\.\\d*)?" + "(?:\\[eE][+-]\\d+)?"
	+ ")\\b");
	public static inline var rsString = '"[^"]*"';
	public static inline var rsIdent = "[_a-zA-Z]\\w*";
	public static inline var rsAtTag = "@[_\\-a-zA-Z][_\\-a-zA-Z0-9]*";
	public static inline var rsExpr = '$rsNumber|$rsString|$rsAtTag|$rsIdent';
}