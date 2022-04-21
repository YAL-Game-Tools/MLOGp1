package ace;
import ace.types.*;
import haxe.Constraints.Function;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("AceHighlight") extern class AceHighlight {
	@:native("$rules") var rules:AceHighlightRuleset;
	function createKeywordMapper(obj:Dynamic<String>, def:String):Function;
	function normalizeRules():Void;
}