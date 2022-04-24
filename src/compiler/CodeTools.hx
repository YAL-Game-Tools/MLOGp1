package compiler;
import ace.AceMacro;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(tools.LocalStatic.build())
class CodeTools {
	public static function splitLine(line:String):CodeTuple {
		@:static var rxTabs = AceMacro.jsRx(~/^(\s*)(.*)/);
		var mtTabs = rxTabs.exec(line);
		var tab = mtTabs[1];
		line = mtTabs[2];
		
		var p = 0;
		var start = 0;
		var comment:String = null;
		while (p < line.length) {
			var c = line.charCodeAt(p++);
			if (c == '"'.code) {
				while (line.charCodeAt(p++) != '"'.code && p < line.length) {};
			} else if (c == '#'.code) {
				comment = line.substring(p);
				line = line.substring(0, p - 1);
				break;
			}
		}
		return new CodeTuple(tab, line, comment);
	}
}
class CodeTuple {
	public var tab:String;
	public var line:String;
	public var comment:String;
	public function new(tab:String, line:String, comment:String) {
		this.tab = tab;
		this.line = line;
		this.comment = comment;
	}
	public function copy():CodeTuple {
		return new CodeTuple(tab, line, comment);
	}
}