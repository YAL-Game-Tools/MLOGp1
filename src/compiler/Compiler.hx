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
	
	function action(def:LogicActionDef) {
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
	
	function readIfThen(line:String) {
		var q = new CodeReader(line);
		q.skipLineSpaces();
		var a = q.readExpr();
		q.skipLineSpaces();
		var c = q.read();
		var op:LogicCondOperator;
		switch (c) {
			case "=".code:
				if (q.skipIfEqu("=".code)) {
					op = q.skipIfEqu("=".code) ? StrictEqual : Equal;
				} else op = Equal;
			case "!".code if (q.skipIfEqu("=".code)): op = NotEqual;
			case "<".code: op = q.skipIfEqu(">".code) ? NotEqual : q.skipIfEqu("=".code) ? LessThanEq : LessThan;
			case ">".code: op = q.skipIfEqu("=".code) ? GreaterThan : GreaterThanEq;
			default:
				if (c.isIdent0()) {
					q.pos--;
					op = cast q.readIdent();
				} else throw "Expected an operator";
		}
		q.skipLineSpaces();
		var b = q.readExpr();
		q.skipLineSpaces();
		if (q.skipIfIdentEquals("then")) q.skipLineSpaces();
		return action(IfThen(a, op, b, readAction(q.substring(q.pos, q.length))));
	}
	function readSetLine(result:String, resIndex:String, op:String, line:String):LogicAction {
		var q = new CodeReader(line);
		var arg = q.readExpr();
		q.skipLineSpaces();
		
		if (op != null && resIndex != null) {
			throw 'Only simple assignments are supported for memory access.';
		}
		
		if (resIndex != null) {
			if (q.loop) throw "Trailing data after memory assignment value.";
			return action(Other('write $arg $result $resIndex'));
		} else if (op != null) { // a += b
			if (q.loop) throw 'Only simple operations (e.g. `a $op= b`) are supported.';
			var func = LogicOperator.binOpToLogOp[op];
			if (func == null) throw '$op= is not a recognized operator.';
			return action(Other('op $func $result $result $arg'));
		} else if (q.skipIfEqu("(".code)) { // r = f(a[, b])
			if (resIndex != null) throw "Cannot write function results to memory.";
			if (!LogicOperator.valNameMap.exists(arg)) {
				throw '$arg is not a known function/operator.';
			}
			var func = arg;
			q.skipLineSpaces();
			var args = [q.readExpr()];
			q.skipLineSpaces();
			var argc = LogicOperator.isUnary[cast func] ? 1 : 2;
			for (_ in 1 ... argc) {
				if (q.skipIfEqu(",".code)) {
					// OK!
				} else if (q.skipIfEqu(")".code)) {
					throw '$func() takes $argc argument${argc!=1?"s":""}.';
				} else throw "Expected a comma or closing parenthesis after an argument.";
				q.skipLineSpaces();
				args.push(q.readExpr());
				q.skipLineSpaces();
			}
			if (q.skipIfEqu(",".code)) {
				throw '$func() takes $argc argument${argc!=1?"s":""}.';
			} else if (!q.skipIfEqu(")".code)) {
				throw "Expected a closing parenthesis.";
			} else if (argc == 1) {
				return action(Other('op $func $result ${args[0]} 0'));
			} else {
				return action(Other('op $func $result ${args[0]} ${args[1]}'));
			}
		} else if (q.skipIfEqu("[".code)) { // a = b[i]
			if (resIndex != null) throw "Cannot move data between memory cells directly.";
			q.skipLineSpaces();
			var srcIndex = q.readExpr();
			q.skipLineSpaces();
			if (!q.skipIfEqu("]".code)) throw "Expected a closing ] after an index.";
			if (q.loop) throw "Trailing data after a memory read.";
			return action(Other('read $result $arg $srcIndex'));
		} else if (q.peek().isIdent0()) { // a = b op c
			var func = q.readIdent();
			if (!LogicOperator.valNameMap.exists(func)) throw '$func is not a known function/operator';
			q.skipLineSpaces();
			var arg2 = q.readExpr();
			q.skipLineSpaces();
			return action(Other('op $func $result $arg $arg2'));
		} else { // a = b
			var mt = LogicOperator.rxOpHere.exec(q.getRest());
			if (mt != null) { // a = b + c
				var op = mt[0];
				var func = LogicOperator.binOpToLogOp[op];
				if (func == null) throw '$op is not a known binary operator.';
				q.skip(op.length);
				q.skipLineSpaces();
				var arg2 = q.readExpr();
				q.skipLineSpaces();
				if (q.loop) throw "Trailing data after binary operation";
				return action(Other('op $func $result $arg $arg2'));
			} else { // a = b
				q.skipLineSpaces();
				if (q.loop) throw "Trailing data after assignment";
				return action(Other('set $result $arg'));
			}
		}
	}
	function readAction(line:String):LogicAction {
		@:static var rxLabel = new RegExp('^(($rsIdent)\\s*:\\s*)(.*)');
		var mt = rxLabel.exec(line);
		if (mt != null) {
			nextNotes.push(mt[1]);
			var labelAction = readAction(mt[3]);
			return action(Label(mt[2], labelAction));
		}
		
		@:static var rxIf = new RegExp("^if\\b\\s*(.*)");
		mt = rxIf.exec(line);
		if (mt != null) return readIfThen(mt[1]);
		
		
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
			return readSetLine(mt[1], mt[2], mt[3], mt[4]);
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
				while (q.loop) {
					args.push(q.readMacroExpr());
					q.skipLineSpaces();
					if (q.skipIfEqu(")".code)) {
						closed = true; break;
					} else if (q.skipIfEqu(",".code)) {
						// OK!
					} else throw "Expected a `)` or `,` in macro arguments.";
				}
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
		
		@:static var rxAction = new RegExp("^[_a-zA-Z]");
		if (rxAction.test(line)) {
			return action(Other(line));
		} else return action(Text(line));
	}
	
	function procLine(line:String, row:Int) {
		var parts = CodeTools.splitLine(line);
		nextTab = parts.tab;
		line = parts.line;
		if (parts.comment != null) nextNotes.push(parts.comment);
		
		try {
			actions.push(readAction(line));
		} catch (x:Exception) {
			annotations.push({ row: row, column: 0, type: "error", text: x.message });
			actions.push(new LogicAction(nextTab, Text("noop"), [x.message, line]));
		}
	}
	
	function procAll() {
		while (loop) {
			var row = index;
			var line = lines[index++];
			procLine(line, row);
		}
	}
	public static function proc(code:String) {
		var comp = new Compiler(code);
		comp.procAll();
		Main.editor.session.setAnnotations(comp.annotations);
		return Printer.proc(comp.actions);
	}
}
