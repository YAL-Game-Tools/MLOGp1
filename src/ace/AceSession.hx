package ace;
import ace.types.AceAnnotation;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("AceSession") extern class AceSession {
	function setMode(mode:String):Void;
	function setAnnotations(annotations:Array<AceAnnotation>):Void;
}