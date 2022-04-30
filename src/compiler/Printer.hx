package compiler;
import compiler.LogicAction;
import compiler.LogicCondOperator;
import haxe.ds.Map;
import js.html.InputElement;
import js.lib.RegExp;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(tools.LocalStatic.build())
class Printer {
	var out:Array<String> = [];
	var labels:Map<String, Int> = new Map();
	var pc = 0;
	var maxJump = 0;
	public static var printPC:Bool = true;
	function new() {
		
	}
	var extraTab = 0;
	function decorate(action:LogicAction, text:String) {
		var tab = "";
		for (_ in 0 ... extraTab) tab += "    ";
		text = StringTools.lpad("", "    ", extraTab) + action.tab + text;
		if (action.notes.length > 0) {
			@:static var rxEndsWithSpace = new RegExp("\\s$");
			@:static var rxStartsWithSpace = new RegExp("^\\s");
			if (text != "" && !rxEndsWithSpace.test(text)) text += " ";
			text += "#";
			if (!rxStartsWithSpace.test(action.notes[0])) text += " ";
			text += action.notes.join(" · ");
		}
		return text;
	}
	function add(action:LogicAction, text:String, incPC:Bool = true) {
		if (printPC && incPC) action.notes.unshift("pc:" + pc);
		text = decorate(action, text);
		if (printPC && incPC) action.notes.shift();
		out.push(text);
		if (incPC) pc++;
	}
	function addSlot(incPC:Bool = true):Int {
		var i = out.length;
		out.push(null);
		if (incPC) pc++;
		return i;
	}
	function fillSlot(slot:Int, action:LogicAction, text:String, ?pc:Int, ?tab:Int) {
		var oldTab = extraTab;
		if (tab != null) extraTab = tab;
		if (printPC && pc != null) action.notes.unshift("pc:" + pc);
		out[slot] = decorate(action, text);
		if (printPC && pc != null) action.notes.shift();
		if (tab != null) extraTab = oldTab;
	}
	function invertCondition(cond:LogicCondOperator) {
		return switch (cond) {
			case Equal: NotEqual;
			case NotEqual: Equal;
			case LessThan: GreaterThanEq;
			case LessThanEq: GreaterThan;
			case GreaterThan: LessThanEq;
			case GreaterThanEq: LessThan;
			default: null;
		}
	}
	function printImpl(action:LogicAction, tab:Int) {
		switch (action.def) {
			case Label(name, act):
				labels[name] = pc;
				print(act, tab);
			case Block(actions):
				for (act in actions) print(act, tab);
			case IfThen(a, op, b, then, null):
				switch (then.def) {
					case Jump(pre, label, ""):
						action.notes.push("dest: " + label);
						add(action, 'jump {{label:$label}} $op $a $b');
					default:
						var invOp = invertCondition(op);
						if (invOp != null) {
							var slotPC = pc;
							var slot = addSlot();
							print(then, then.def.match(Block(_)) ? tab : tab + 1);
							fillSlot(slot, action, 'jump $pc $invOp $a $b', slotPC);
							maxJump = pc;
							out.push(action.tab + '# end if (pc:$slotPC)');
						} else {
							var slot1 = addSlot();
							var slot2 = addSlot();
							fillSlot(slot1, action, 'jump $pc $op $a $b');
							print(then, then.def.match(Block(_)) ? tab : tab + 1);
							action.notes = [];
							fillSlot(slot2, action, 'jump $pc always 0 0');
						}
				}
			case IfThen(a, op, b, then, otrw):
				switch (then.def) {
					case Jump(pre, label, ""):
						// if <cond>
						// - jump label
						// ...else
						action.notes.push("dest: " + label);
						add(action, 'jump {{label:$label}} $op $a $b');
						print(otrw, tab + 1);
					default:
						// if a != 1 jump _else
						// > ...then
						// > jump _endif
						// _else:
						// > ...else
						// _endif:
						var invOp = invertCondition(op);
						if (invOp == null) {
							// if we don't have an inverted operator for that, simply
							// swap then/else branches
							invOp = op;
							var _tmp = then; then = otrw; otrw = _tmp;
						}
						var ifPC = pc, ifSlot = addSlot();
						print(then, tab);
						var thenPC = pc, thenSlot = addSlot();
						fillSlot(ifSlot, action, 'jump $pc $invOp $a $b # if', ifPC);
						print(otrw, tab);
						fillSlot(thenSlot, action, 'jump $pc always 0 0 # else', thenPC);
						maxJump = pc;
						out.push(action.tab + '# end if (pc:$ifPC)');
				}
			case Jump(prefix, label, arg):
				if (arg == null || arg == "") arg = " always 0 0";
				action.notes.push("dest " + label);
				add(action, 'jump {{label:$label}}$arg');
			case Other(text): add(action, text, true);
			case Text(text): add(action, text, false);
		}
	}
	function print(action:LogicAction, tab:Int) {
		var xt = extraTab;
		extraTab = tab;
		printImpl(action, tab);
		extraTab = xt;
	}
	function printAll(actions:Array<LogicAction>) {
		for (action in actions) print(action, 0);
		var code = out.join("\n");
		var needsTrailingEnd = pc > 0 && maxJump >= pc;
		for (label => p in labels) {
			code = StringTools.replace(code, '{{label:$label}}', "" + p);
			if (p >= pc) needsTrailingEnd = true;
		}
		if (needsTrailingEnd) {
			if (!StringTools.endsWith(code, "\n")) code += "\n";
			code += "end";
			if (printPC) code += " # pc:" + pc;
		}
		return code;
	}
	public static function proc(actions:Array<LogicAction>) {
		var printer = new Printer();
		return printer.printAll(actions);
	}
}