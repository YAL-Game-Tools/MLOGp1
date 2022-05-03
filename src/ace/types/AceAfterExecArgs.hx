package ace.types;
import ace.AceEditor;

/**
 * ...
 * @author YellowAfterlife
 */
extern class AceAfterExecArgs {
	var type:String;
	var editor:AceEditor;
	var args:String;
	var command:AceCommand;
	var returnValue:Dynamic;
	function preventDefault():Void;
	function stopPropagation():Void;
}