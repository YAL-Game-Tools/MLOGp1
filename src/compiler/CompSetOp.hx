package compiler;

/**
 * ...
 * @author YellowAfterlife
 */
class CompSetOp {
	public static function proc(comp:Compiler, result:String, resIndex:String, op:String, line:String):LogicAction {
		var q = new CodeReader(line);
		var arg = q.readExpr();
		q.skipLineSpaces();
		
		if (op != null && resIndex != null) {
			throw 'Only simple assignments are supported for memory access.';
		}
		
		if (resIndex != null) {
			if (q.loop) throw "Trailing data after memory assignment value.";
			return comp.action(Other('write $arg $result $resIndex'));
		} else if (op != null) { // a += b
			if (q.loop) throw 'Only simple operations (e.g. `a $op= b`) are supported.';
			var func = LogicOperator.binOpToLogOp[op];
			if (func == null) throw '$op= is not a recognized operator.';
			return comp.action(Other('op $func $result $result $arg'));
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
				return comp.action(Other('op $func $result ${args[0]} 0'));
			} else {
				return comp.action(Other('op $func $result ${args[0]} ${args[1]}'));
			}
		} else if (q.skipIfEqu("[".code)) { // a = b[i]
			if (resIndex != null) throw "Cannot move data between memory cells directly.";
			q.skipLineSpaces();
			var srcIndex = q.readExpr();
			q.skipLineSpaces();
			if (!q.skipIfEqu("]".code)) throw "Expected a closing ] after an index.";
			if (q.loop) throw "Trailing data after a memory read.";
			return comp.action(Other('read $result $arg $srcIndex'));
		} else if (q.peek().isIdent0()) { // a = b op c
			var func = q.readIdent();
			if (!LogicOperator.valNameMap.exists(func)) throw '$func is not a known function/operator';
			q.skipLineSpaces();
			var arg2 = q.readExpr();
			q.skipLineSpaces();
			return comp.action(Other('op $func $result $arg $arg2'));
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
				return comp.action(Other('op $func $result $arg $arg2'));
			} else { // a = b
				q.skipLineSpaces();
				if (q.loop) throw "Trailing data after assignment";
				return comp.action(Other('set $result $arg'));
			}
		}
	}
}