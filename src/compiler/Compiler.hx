package compiler ;
using StringTools;
import ace.AceMacro.*;
import ace.types.AceAnnotation;
import compiler.CodeReader;
import compiler.CodeTools.CodeTuple;
import compiler.LogicOperator;
import haxe.Exception;
import highlight.MLHighlightRules;
import highlight.MLRegStr;
import js.lib.RegExp;
import compiler.LogicAction;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(tools.LocalStatic.build())
class Compiler {
	var lines:Array<String>;
	var index:Int = 0;
	var length:Int;
	var actions:Array<LogicAction> = [];
	var annotations:Array<AceAnnotation> = [];
	public var macros:Map<String, MagicMacro> = new Map();
	
	function new(code:String) {
		lines = code.split("\n");
		length = lines.length;
	}
	
	public inline function next():String return lines[index++];
	public var loop(get, never):Bool;
	inline function get_loop():Bool return index < length;
	
	var nextTab:String = "";
	var nextNotes:Array<String> = [];
	
	public function action(def:LogicActionDef) {
		var result = new LogicAction(nextTab, def, nextNotes);
		nextNotes = [];
		return result;
	}
	
	static inline var rsValue:String = (
		"[_a-zA-Z]\\w*"
		+ "|(\\-\\s*)?\\d+(?:\\.\\d*)"
		+ '|"[^"]*"'
	);
	static inline var rsIdent:String = "[_a-zA-Z]\\w*";
	
	public function readAction(line:String):LogicAction {
		@:static var rxLabel = new RegExp('^(($rsIdent)\\s*:\\s*)(.*)');
		var mt = rxLabel.exec(line);
		if (mt != null) {
			nextNotes.push(mt[1]);
			var labelAction = readAction(mt[3]);
			return action(Label(mt[2], labelAction));
		}
		
		@:static var rxIf = new RegExp("^if\\b\\s*(.*)");
		mt = rxIf.exec(line);
		if (mt != null) return CompIfThen.proc(this, mt[1]);
		
		{ // check for act1; act2
			var parts = [];
			var p = 0;
			var start = 0;
			while (p < line.length) {
				var c = line.charCodeAt(p++);
				if (c == '"'.code) {
					while (line.charCodeAt(p++) != '"'.code && p < line.length) {};
				} else if (c == ';'.code) {
					parts.push(line.substring(start, p - 1));
					start = p;
					break;
				}
			}
			if (start > 0) {
				parts.push(line.substring(start));
				var actions = [for (part in parts) readAction(part.trim())];
				return action(Block(actions));
			}
		}
		
		@:static var rxMacroDef = new RegExp('^macro\\s+(' + MLRegStr.rsIdent + ')(.*)');
		mt = rxMacroDef.exec(line);
		if (mt != null) {
			var tup = new CodeTuple(nextTab, mt[2], nextNotes.shift());
			MagicMacro.read(this, mt[1], mt[2], tup);
			nextNotes.push("macro: " + mt[1]);
			return action(Text(""));
		}
		
		@:static var rxJump = new RegExp("^(jump\\s+)([_a-zA-Z]\\w*)(.*)");
		mt = rxJump.exec(line);
		if (mt != null) {
			@:static var rxAlways = new RegExp("^\\s*always");
			var arg = mt[3];
			if (rxAlways.test(arg)) arg = "";
			return action(Jump(mt[1], mt[2], arg));
		}
		
		@:static var rxSetOp = new RegExp('^($rsIdent)\\s*'
			+ '(?:\\[\\s*(' + MLRegStr.rsExpr + ')\\s*\\]\\s*)?' // index
			+ '(' + LogicOperator.rsSetOps + ')?='
			+ '\\s*(.+)'
		);
		mt = rxSetOp.exec(line);
		if (mt != null) {
			return CompSetOp.proc(this, mt[1], mt[2], mt[3], mt[4]);
		}
		
		@:static var rxMacro = new RegExp("^(" + MLRegStr.rsIdent + ")\\s*(.*)");
		mt = rxMacro.exec(line);
		if (mt != null && macros.exists(mt[1])) {
			var mcr = macros[mt[1]];
			var args = [];
			var q = new CodeReader(mt[2]);
			q.skipLineSpaces();
			if (q.skipIfEqu("(".code)) { // macro(a, b)
				var closed = false;
				if (q.skipIfEqu(")".code)) {
					closed = true;
				} else while (q.loop) {
					args.push(q.readMacroExpr());
					q.skipLineSpaces();
					if (q.skipIfEqu(")".code)) {
						closed = true; break;
					} else if (q.skipIfEqu(",".code)) {
						// OK!
					} else throw "Expected a `)` or `,` in macro arguments.";
				}
				if (!closed) throw "Unclosed macro call";
			} else { // macro a b
				while (q.loop) {
					args.push(q.readMacroExpr());
					q.skipLineSpaces();
				}
			}
			if (args.length != mcr.argNames.length) {
				throw mcr.name + " takes " + mcr.argNames.length
					+ " arguments, got " + args.length;
			}
			var tups = mcr.proc(args, nextTab);
			var _tab = nextTab;
			var actions = [for (tup in tups) {
				if (tup.comment != null) nextNotes.push(tup.comment);
				readAction(tup.line); // ->
			}];
			nextTab = _tab;
			return action(Block(actions));
		}
		
		@:static var rxEndMacro = new RegExp("^endmacro\\b");
		if (rxEndMacro.test(line)) throw "endmacro without a macro";
		
		@:static var rxEndIf = new RegExp("^endif\\b");
		if (rxEndIf.test(line)) throw "endif without an if";
		
		@:static var rxPrint = new RegExp("^print(flush)?\\b\\s*(.*)");
		mt = rxPrint.exec(line);
		if (mt != null) {
			var q = new CodeReader(mt[2]);
			var flushTarget = null;
			if (mt[1] != null) {
				flushTarget = q.readExpr();
				q.skipLineSpaces();
			}
			var out = [];
			while (q.loop) {
				out.push(action(Other("print " + q.readExpr())));
				q.skipLineSpaces();
			}
			if (flushTarget != null) out.push(action(Other("printflush " + flushTarget)));
			return out.length == 1 ? out[1] : action(Block(out));
		}
		
		@:static var rxAction = new RegExp("^[_a-zA-Z]");
		if (rxAction.test(line)) {
			return action(Other(line));
		} else return action(Text(line));
	}
	public function readLine(rawLine:String, ?row:Int) {
		if (row == null) row = index - 1;
		
		var tup = CodeTools.splitLine(rawLine);
		var oldTab = nextTab;
		nextTab = tup.tab;
		if (tup.comment != null) nextNotes.push(tup.comment);
		
		var result:LogicAction;
		try {
			result = readAction(tup.line);
		} catch (x:Exception) {
			annotations.push({ row: row, column: 0, type: "error", text: x.message });
			result = new LogicAction(nextTab, Text("noop"), [x.message, rawLine]);
		}
		nextTab = oldTab;
		return result;
	}
	
	function procAll() {
		while (loop) {
			actions.push(readLine(next()));
		}
	}
	public static function proc(code:String) {
		var comp = new Compiler(code);
		comp.procAll();
		Main.editor.session.setAnnotations(comp.annotations);
		return Printer.proc(comp.actions);
	}
}
