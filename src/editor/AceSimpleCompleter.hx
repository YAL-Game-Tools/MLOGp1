package editor;
import ace.AceEditor;
import ace.AceSession;
import ace.types.AceAutoCompleteItem;
import ace.types.AceAutoCompleteItems;
import ace.types.AceAutoCompleter;
import ace.types.AcePos;
import ace.types.AceToken;
import ace.types.AceTokenIterator;
import ace.types.AceTokenType;
import haxe.extern.EitherType;
import js.lib.RegExp;
import tools.Dictionary;

/**
 * ...
 * @author YellowAfterlife
 */
class AceSimpleCompleter implements AceAutoCompleter {
	public var identifierRegexps:Array<RegExp>;
	public var items:AceAutoCompleteItems;
	public var tokenFilter:Dictionary<Bool>;
	public var tokenFilterNot:Bool;
	public var minLength:Int = 2;
	
	public function new(
		items:AceAutoCompleteItems,
		tokenFilterDictOrArray:EitherType<Dictionary<Bool>, Array<AceTokenType>>, not:Bool
	) {
		this.items = items;
		identifierRegexps = [new RegExp("[_" + "a-z" + "A-Z" + "0-9" + "\\u00A2-\\uFFFF]")];
		if (Std.is(tokenFilterDictOrArray, Array)) { // legacy format
			tokenFilter = Dictionary.fromKeys(tokenFilterDictOrArray, true);
		} else tokenFilter = tokenFilterDictOrArray;
		tokenFilterNot = not;
	}
	
	public function getDocTooltip(item:AceAutoCompleteItem):String {
		return item.doc;
	}
	
	public function getCompletions(
		editor:AceEditor, session:AceSession, pos:AcePos, prefix:String, callback:AceAutoCompleteCb
	):Void {
		inline function proc(show:Bool) {
			callback(null, show ? items : []);
		}
		var ml = minLength;
		if (prefix.length < ml) {
			proc(false);
			return;
		}
		var tk:AceToken = session.getTokenAtPos(pos);
		var tkf:Bool = tk != null && tokenFilter.exists(tk.type);
		proc(tkf != tokenFilterNot);
	}
}