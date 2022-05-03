package ace;
import ace.types.AceAnnotation;
import ace.types.AcePos;
import ace.types.AceToken;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("AceSession") extern class AceSession {
	function setMode(mode:String):Void;
	function setAnnotations(annotations:Array<AceAnnotation>):Void;
	
	function getLine(row:Int):String;
	function getTokenAt(row:Int, col:Int):AceToken;
	function getLength():Int;
	inline function getTokenAtPos(pos:AcePos):AceToken {
		return getTokenAt(pos.row, pos.column);
	}
}