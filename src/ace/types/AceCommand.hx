package ace.types;
import haxe.Constraints.Function;
import haxe.extern.EitherType;
import tools.NativeString;

/**
 * ...
 * @author YellowAfterlife
 */
@:forward abstract AceCommand(AceCommandImpl) from AceCommandImpl to AceCommandImpl {
	
}
typedef AceCommandImpl = {
	?bindKey:AceCommandKey,
	exec:AceEditor->Void,
	/** Used for bindings */
	name:String,
	/** A descriptive name for settings */
	?title:String,
	/** Shown as mouseover in settings */
	?description:String,
	?readOnly:Bool,
	?scrollIntoView:String,
	?multiSelectAction:String,
};

abstract AceCommandKey(Dynamic)
from String from AceCommandKeyPair
to   String to   AceCommandKeyPair {
	public var key(get, never):String;
	private function get_key():String {
		if (this == null || Std.is(this, String)) return this;
		return (this:AceCommandKeyPair).win;
		//return (AceUserAgent.isMac ? (this:AceCommandKeyPair).mac : (this:AceCommandKeyPair).win);
	}
}
typedef AceCommandKeyPair = { win:String, mac:String };

/** command object or name of an existing command */
abstract AceCommandOrName(Dynamic)
from String from AceCommand
to   String to   AceCommand {
	public var name(get, never):String;
	private inline function get_name():String {
		return Std.is(this, String) ? this : (this:AceCommand).name;
	}
	
	public function equals(other:AceCommandOrName) {
		if (Std.is(this, String)) {
			if (Std.is(other, String)) {
				return this == other;
			} else {
				return this == (other:AceCommand).name;
			}
		} else {
			if (Std.is(other, String)) {
				return (this:AceCommand).name == other;
			} else {
				return this == other;
			}
		}
	}
}

/** I can't believe you've done this */
abstract AceOneOrMoreCommandOrName(Dynamic)
from AceCommandOrName from Array<AceCommandOrName>
to   AceCommandOrName   to Array<AceCommandOrName> {
	public var first(get, never):AceCommandOrName;
	private inline function get_first():AceCommandOrName {
		return Std.is(this, Array) ? this[0] : this;
	}
	//
	public inline function isArray():Bool {
		return Std.is(this, Array);
	}
	public inline function asItem():AceCommandOrName {
		return this;
	}
	public inline function asArray():Array<AceCommandOrName> {
		return this;
	}
	public inline function toArray():Array<AceCommandOrName> {
		return isArray() ? asArray() : [asItem()];
	}
	//
	public inline function forEach(fn:AceCommandOrName->Void):Void {
		if (isArray()) {
			for (val in asArray()) fn(val);
		} else fn(asItem());
	}
}

/** command / name / function */
typedef AceCommandInit = EitherType<AceCommandOrName, Function>;