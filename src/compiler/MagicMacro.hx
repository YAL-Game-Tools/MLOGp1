package compiler;
import compiler.CodeReader;
import compiler.CodeTools;
import compiler.Compiler;
import js.lib.RegExp;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(tools.LocalStatic.build())
class MagicMacro {
	public var name:String;
	public var lines:Array<CodeTuple> = [];
	public var argNames:Array<String> = [];
	var argMap:Map<String, Int> = new Map();
	public function new(name:String) {
		this.name = name;
	}
	public function proc(argExprs:Array<String>, tab:String):Array<CodeTuple> {
		var lines = this.lines.map(l -> l.copy());
		for (tup in lines) {
			tup.tab = tab + tup.tab;
			var start = 0;
			var out = "";
			var q = new CodeReader(tup.line);
			inline function flush(till:Int) {
				out += q.substring(start, till);
			}
			while (q.loop) {
				var c = q.peek();
				if (q.skipCommon(c)) continue;
				if (c.isIdent0()) {
					var idStart = q.pos;
					var id = q.readIdent();
					var i = argMap[id];
					if (i != null) {
						flush(idStart);
						out += argExprs[i];
						start = q.pos;
					}
				} else q.skip();
			}
			if (start > 0) {
				flush(q.pos);
				tup.line = out;
			}
		}
		return lines;
	}
	public static function read(comp:Compiler, name:String, firstLine:String, firstData:CodeTuple) {
		var m = new MagicMacro(name);
		
		var q = new CodeReader(firstLine);
		q.skipLineSpaces();
		if (q.skipIfEqu("(".code)) {
			var closed = false;
			q.skipLineSpaces();
			if (q.skipIfEqu(")".code)) {
				closed = true;
			} else while (q.loop) {
				q.skipLineSpaces();
				if (!q.peek().isIdent0()) throw "Expected a macro argument name";
				var argName = q.readIdent();
				m.argMap[argName] = m.argNames.length;
				m.argNames.push(argName);
				q.skipLineSpaces();
				if (q.skipIfEqu(")".code)) {
					closed = true;
					break;
				}
				if (q.skipIfEqu(",".code)) {
					// OK!
				} else throw "Expected a `)` or a `,` after an argument name.";
			}
			if (!closed) throw "Unclosed argument list in a macro";
			q.skipLineSpaces();
		}
		
		if (!q.loop) { // `macro name<eol>...exprs<eol>endmacro`
			q.skipLineSpaces();
			@:static var rxEnd = new RegExp("^endmacro\\s*$");
			var closed = false;
			while (comp.loop) {
				var line = comp.next();
				var tup = CodeTools.splitLine(line);
				var mt = rxEnd.exec(tup.line);
				if (mt != null) { closed = true; break; }
				m.lines.push(tup);
			}
			if (!closed) throw "Unclosed macro block";
		} else {
			m.lines.push(new CodeTuple(firstData.tab, q.getRest(), firstData.comment));
		}
		comp.macros.set(name, m);
	}
}