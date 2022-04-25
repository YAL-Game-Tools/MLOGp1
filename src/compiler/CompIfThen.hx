package compiler;
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
		if (!q.loop) { // `if a ?? b [then]<eol>...actions<eol>endif`
			var thenActions = [];
			var elseActions = null;
			
			@:static var rxElse = new RegExp("^\\s*else\\b\\s*(.+)?");
			@:static var rxEndIf = new RegExp("^\\s*endif\\b");
			var closed = false;
			while (comp.loop) {
				var line = comp.next();
				var mt = rxElse.exec(line);
				if (mt != null) {
					if (mt[1] == null) {
						elseActions = [];
						while (comp.loop) {
							line = comp.next();
							if (rxEndIf.test(line)) { closed = true; break; }
							elseActions.push(comp.readLine(line));
						}
					} else {
						elseActions = [comp.readAction(mt[1])];
						closed = true;
					}
					break;
				}
				if (rxEndIf.test(line)) { closed = true; break; }
				thenActions.push(comp.readLine(line));
			}
			if (!closed) throw "Unclosed if-block";
			return comp.action(IfThen(a, op, b,
				thenActions.length == 1 ? thenActions[0] : comp.action(Block(thenActions)),
				elseActions == null ? null : (
					elseActions.length == 1 ? elseActions[0] : comp.action(Block(elseActions))
				)
			));
		} else {
			return comp.action(IfThen(a, op, b, comp.readAction(q.substring(q.pos, q.length)), null));
		}
	}
}