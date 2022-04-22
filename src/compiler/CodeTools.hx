package compiler;
import ace.AceMacro;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(tools.LocalStatic.build())
class CodeTools {
	public static function splitLine(line:String) {
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
		return { line: line, tab: tab, comment: comment };
	}
}