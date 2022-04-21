package compiler;
import ace.AceMacro;
import js.lib.RegExp;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(compiler.LogicMacro.buildValueNameMap(valNameMap))
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
	public static var binOpMapper:Map<String, LogicOperator> = {
		var m = new Map();
		m["+"] = Add;
		m["-"] = Sub;
		m["*"] = Mul;
		m["/"] = Div;
		m["//"] = Idiv;
		m["%"] = Mod;
		m["**"] = Pow;
		m["=="] = Equal;
		m["!="] = NotEqual;
		m["<>"] = NotEqual;
		m["<"] = LessThan;
		m["<="] = LessThanEq;
		m[">"] = GreaterThan;
		m[">="] = GreaterThanEq;
		m["==="] = StrictEqual;
		m["<<"] = Shl;
		m[">>"] = Shr;
		m["&"] = And;
		m["|"] = Or;
		m["^"] = Xor;
		m["&&"] = LAnd;
		m;
	};
	public static inline var rsOps = '==?=?|&&?|>[=>]|<[<>]|!=|\\/\\/?|\\*\\*?|%|\\|]';
	public static inline var rsSetOps = '\\+|-|\\*\\*?|//?|%|<<|>>|&|^|\\|';
	public static var rxOpHere:RegExp = new RegExp("^(?:" + rsOps +")");
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