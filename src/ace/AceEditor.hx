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
	function clearSelection():Void;
	function on(event:String, fn:Function):Void;
	var session:AceSession;
	var container:Element;
	var selection:AceSelection;
}
