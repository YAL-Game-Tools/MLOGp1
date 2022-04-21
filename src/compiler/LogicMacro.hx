package compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;

/**
 * ...
 * @author YellowAfterlife
 */
class LogicMacro {
	public static macro function buildValueNameMap(nameVar:Expr):Array<Field> {
		var targetName = switch (nameVar.expr) {
			case EConst(CIdent(id)): id;
			default: throw "expected a target name";
		}
		var fields:Array<Field> = Context.getBuildFields();
		var target:Field = null;
		var init = [macro var m = new Map()];
		for (field in fields) {
			if (field.access != null && field.access.indexOf(AStatic) >= 0) {
				if (field.name == targetName) target = field;
				continue;
			}
			switch (field.kind) {
				case FVar(_, x): init.push(macro m[$x] = $v{field.name});
				default:
			}
		}
		if (target == null) throw "target field not found";
		init.push(macro m);
		switch (target.kind) {
			case FVar(t, _): target.kind = FVar(t, macro $b{init});
			default: throw "invalid target field kind";
		}
		return fields;
	}
}