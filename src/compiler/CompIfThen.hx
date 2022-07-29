package compiler;
import compiler.LogicCondOperator;
import js.lib.RegExp;
import compiler.LogicAction;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(tools.LocalStatic.build())
class CompIfThen {
	public static function proc(comp:Compiler, line:String) {
		var q = new CodeReader(line);
		q.skipLineSpaces();
		var a:String = null;
		var op:LogicCondOperator = null;
		var b:String = null;
		if (q.skipIfEqu("!".code)) {
			q.skipLineSpaces();
			op = LogicCondOperator.Equal;
			b = "false";
		}
		a = q.readExpr();
		q.skipLineSpaces();
		if (op == null) {
			var c = q.read();
			switch (c) {
				case "=".code:
					if (q.skipIfEqu("=".code)) {
						op = q.skipIfEqu("=".code) ? StrictEqual : Equal;
					} else op = Equal;
				case "!".code if (q.skipIfEqu("=".code)): op = NotEqual;
				case "<".code:
					if (q.skipIfEqu(">".code)) { // <>
						op = NotEqual;
					} else if (q.skipIfEqu("=".code)) { // <=
						op = LessThanEq;
					} else op = LessThan;
				case ">".code:
					op = q.skipIfEqu("=".code) ? GreaterThanEq : GreaterThan;
				default:
					if (c.isIdent0()) {
						q.pos--;
						op = cast q.readIdent();
					} else throw "Expected an operator";
			}
			q.skipLineSpaces();
		}
		if (op.toString() == "then") {
			op = LogicCondOperator.NotEqual;
			b = "false";
		}
		if (b == null) {
			b = q.readExpr();
			q.skipLineSpaces();
		}
		if (q.skipIfIdentEquals("then")) q.skipLineSpaces();
		if (!q.loop) { // `if a ?? b [then]<eol>...actions<eol>endif`
			var thenActions = [];
			var elseAction = null;
			
			@:static var rxElse = new RegExp("^\\s*else\\b\\s*(.+)?");
			@:static var rxEndIf = new RegExp("^\\s*endif\\b");
			var closed = false;
			while (comp.loop) {
				var line = comp.next();
				var mt = rxElse.exec(line);
				if (mt != null) {
					if (mt[1] == null) {
						var elseActions = [];
						while (comp.loop) {
							line = comp.next();
							if (rxEndIf.test(line)) { closed = true; break; }
							elseActions.push(comp.readLine(line));
						}
						elseAction = comp.action(Block(elseActions));
					} else {
						elseAction = comp.readAction(mt[1]);
						closed = true;
					}
					break;
				}
				if (rxEndIf.test(line)) { closed = true; break; }
				thenActions.push(comp.readLine(line));
			}
			if (!closed) throw "Unclosed if-block";
			return comp.action(IfThen(a, op, b, comp.action(Block(thenActions)), elseAction));
		} else {
			return comp.action(IfThen(a, op, b, comp.readAction(q.substring(q.pos, q.length)), null));
		}
	}
}