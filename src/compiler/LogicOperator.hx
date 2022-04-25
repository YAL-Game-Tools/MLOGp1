package compiler;
import ace.AceMacro;
import js.lib.RegExp;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(compiler.LogicMacroTools.buildValueNameMap(valNameMap))
enum abstract LogicOperator(String) {
	public static var valNameMap:Map<String, String>;
	public static var isUnary:Map<LogicOperator, Bool> = {
		var m:Map<LogicOperator, Bool> = new Map();
		m[Not] = true;
		m[Abs] = true;
		m[Log] = true;
		m[Log10] = true;
		m[Floor] = true;
		m[Ceil] = true;
		m[Sqrt] = true;
		m[Rand] = true;
		m[Sin] = true;
		m[Cos] = true;
		m[Tan] = true;
		m[Asin] = true;
		m[Acos] = true;
		m[Atan] = true;
		m;
	};
	public static var logOpToBinOp:Map<LogicOperator, String>;
	/**
	 * 
	 */
	public static var binOpToLogOp:Map<String, LogicOperator> = {
		var b2l = new Map();
		var l2b = new Map();
		inline function set(op:String, logOp:LogicOperator):Void {
			b2l[op] = logOp;
			l2b[logOp] = op;
		}
		set("+", Add);
		set("-", Sub);
		set("*", Mul);
		set("/", Div);
		set("//", Idiv);
		set("%", Mod);
		set("**", Pow);
		set("==", Equal);
		set("!=", NotEqual);
		set("<>", NotEqual);
		set("<", LessThan);
		set("<=", LessThanEq);
		set(">", GreaterThan);
		set(">=", GreaterThanEq);
		set("===", StrictEqual);
		set("<<", Shl);
		set(">>", Shr);
		set("&", And);
		set("|", Or);
		set("^", Xor);
		set("&&", LAnd);
		logOpToBinOp = l2b;
		b2l;
	};
	public static inline var rsOps = '\\+|\\-|==?=?|&&?|>[=>]|<[<>]|!=|\\/\\/?|\\*\\*?|%|\\|';
	public static inline var rsSetOps = '\\+|\\-|\\*\\*?|//?|%|<<|>>|&|^|\\|';
	public static var rxOpHere:RegExp = new RegExp("^(?:" + rsOps +")");
	public static var rxIsSetOp:RegExp = new RegExp("^(?:" + rsSetOps +")$");
	var Add = "add";
	var Sub = "sub";
	var Mul = "mul";
	var Div = "div";
	var Idiv = "idiv";
	var Mod = "mod";
	var Pow = "pow";
	var Equal = "equal";
	var NotEqual = "notEqual";
	var LAnd = "land";
	var LessThan = "lessThan";
	var LessThanEq = "lessThanEq";
	var GreaterThan = "greaterThan";
	var GreaterThanEq = "greaterThanEq";
	var StrictEqual = "strictEqual";
	var Shl = "shl";
	var Shr = "shr";
	var Or = "or";
	var And = "and";
	var Xor = "xor";
	/** BITWISE not */
	var Not = "not"; 
	var Max = "max";
	var Min = "min";
	var Angle = "angle";
	var Len = "len";
	var Noise = "noise";
	var Abs = "abs";
	var Log = "log";
	var Log10 = "log10";
	var Floor = "floor";
	var Ceil = "ceil";
	var Sqrt = "sqrt";
	var Rand = "rand";
	var Sin = "sin";
	var Cos = "cos";
	var Tan = "tan";
	var Asin = "asin";
	var Acos = "acos";
	var Atan = "atan";
}