package ace.types;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("AceAutocomplete") 
extern class AceEditorCompleter {
	function new();
	function detach():Void;
	var completions:AceAutocompleteCompletions;
	var exactMatch:Bool;
	var autoInsert:Bool;
	var activated:Bool;
	function getPopup():AcePopup;
	function showPopup(editor:AceEditor):Void;
	function insertMatch(data:Any, options:Any):Bool;
	var popup:AcePopup;
	private static inline function __init__():Void {
		(cast js.Browser.window).AceAutocomplete = Ace.require("ace/autocomplete").Autocomplete;
	}
}
extern class AceAutocompleteCompletions {
	var filterText:String;
}