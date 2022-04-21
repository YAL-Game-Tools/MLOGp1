package ace;
import haxe.extern.EitherType;
import js.html.Element;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("ace") extern class Ace {
	static function edit(el:EitherType<Element, String>):AceEditor;
	static function require(path:String):Dynamic;
	static function define(path:String, require:Array<String>, impl:AceImpl):Void;
}

extern typedef AceRequire = String->Dynamic;
extern typedef AceExports = Dynamic;
extern typedef AceModule = Dynamic;
extern typedef AceImpl = AceRequire->AceExports->AceModule->Void;