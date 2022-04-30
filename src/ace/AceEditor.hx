package ace ;
import ace.AceSession;
import ace.types.AceSelection;
import haxe.Constraints.Function;
import haxe.extern.EitherType;
import js.html.Element;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("ace") extern class AceEditor {
	function getValue():String;
	function setValue(val:String):Void;
	inline function setValueAndClearSelection(val:String):Void {
		setValue(val);
		clearSelection();
	}
	function setTheme(path:String, ?cb:Void->Void):Void;
	function setOption(name:String, val:Dynamic):Void;
	function setOptions(opts:Dynamic):Void;
	function getOption(name:String):Dynamic;
	function getOptions():Dynamic;
	function clearSelection():Void;
	function on(event:String, fn:Function):Void;
	var session:AceSession;
	var renderer:Dynamic;
	var container:Element;
	var selection:AceSelection;
}
