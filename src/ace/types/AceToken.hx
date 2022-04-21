package ace.types;
import js.lib.RegExp;

/**
 * ...
 * @author YellowAfterlife
 */
@:forward abstract AceToken(AceTokenImpl) from AceTokenImpl to AceTokenImpl {
	public inline function new(type:String, value:String) {
		this = { type: type, value: value };
	}
	
	/** shortcut for value.length */
	public var length(get, never):Int;
	private inline function get_length():Int {
		return this.value.length;
	}
	
	/** type or `null` if `this == null` */
	public var ncType(get, never):AceTokenType;
	private inline function get_ncType():AceTokenType {
		return AceMacro.nca(this, this.type);
	}
	
	/** value or `null` if `this == null` */
	public var ncValue(get, never):String;
	private inline function get_ncValue():String {
		return AceMacro.nca(this, this.value);
	}
	
	/** Returns whether `value` is an identifier (/^\w+$/) */
	public inline function isIdent():Bool return __isIdent.test(this.value);
	private static var __isIdent:RegExp = new RegExp("^\\w+$");
}
typedef AceTokenImpl = { type:AceTokenType, value:String, ?index:Int, ?start:Int };
