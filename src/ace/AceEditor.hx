package ace ;
import ace.AceSession;
import haxe.extern.EitherType;
import js.html.Element;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("ace") extern class AceEditor {
	function getValue():String;
	function setValue(val:String):String;
	function setTheme(path:String):Void;
	function setOption(name:String, val:Dynamic):Void;
	function clearSelection():Void;
	var session:AceSession;
	var container:Element;
}
