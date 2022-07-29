package compiler;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(compiler.LogicMacroTools.buildValueNameMap(valNameMap))
enum abstract LogicCondOperator(String) {
	public static var valNameMap:Map<String, String>;
	public static var opToLogic:Map<String, LogicCondOperator>;
	public static var logicToOp:Map<LogicCondOperator, String> = init();
	private static function init() {
		var l2o = new Map(), o2l = new Map();
		inline function set(o:String, l:LogicCondOperator):Void {
			l2o[l] = o;
			o2l[o] = l;
		}
		set("==", Equal);
		set("===", StrictEqual);
		set("<>", NotEqual);
		set("!=", NotEqual);
		set("<", LessThan);
		set("<=", LessThanEq);
		set(">", GreaterThan);
		set(">=", GreaterThanEq);
		opToLogic = o2l;
		return l2o;
	}
	public inline function toString():String return this;
	public static var rsCondOp = "(?:===?|<[>=]?|>=?|!=)";
	var Equal = "equal";
	var NotEqual = "notEqual";
	var LessThan = "lessThan";
	var LessThanEq = "lessThanEq";
	var GreaterThan = "greaterThan";
	var GreaterThanEq = "greaterThanEq";
	var StrictEqual = "strictEqual";
	var Always = "always";
}