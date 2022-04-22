package compiler;
import compiler.LogicCondOperator;
import compiler.LogicOperator;
import highlight.MLRegStr;
import js.lib.RegExp;

/**
 * ...
 * @author YellowAfterlife
 */
class Simplifier {
	public static function proc(code:String) {
		var pairs:Array<SimplifierPair> = code.split("\n").map(function(line) {
			return { text: line, pc: -1 };
		});
		var pc = 0;
		var pcToPair:Map<Int, SimplifierPair> = new Map();
		for (pair in pairs) {
			var parts = CodeTools.splitLine(pair.text);
			function set(newLine:String) {
				newLine = parts.tab + newLine;
				if (parts.comment != null) {
					@:static var rxEndsWithSpace = new RegExp("\\s$");
					if (!rxEndsWithSpace.test(newLine)) newLine += " ";
					newLine += "#";
					@:static var rxStartsWithSpace = new RegExp("^\\s");
					if (!rxStartsWithSpace.test(newLine)) newLine += " ";
					newLine += parts.comment;
				}
				pair.text = newLine;
			}
			var line = parts.line;
			
			@:static var rxIncPC = new RegExp("^" +MLRegStr.rsIdent);
			if (rxIncPC.test(line)) {
				pcToPair[pc] = pair;
				pair.pc = pc++;
			}
			
			@:static var rxSet = new RegExp("^set\\s+(" + MLRegStr.rsIdent + ")\\b\\s*"
				+ "(" + MLRegStr.rsExpr + ")\\s*$");
			var mt = rxSet.exec(line);
			if (mt != null) {
				set(mt[1] + " = " + mt[2]);
				continue;
			}
			
			@:static var rxOp = new RegExp("^op\\b\\s*"
				+ "(" + MLRegStr.rsIdent + ")\\s*"
				+ "(" + MLRegStr.rsIdent + ")\\s*"
				+ "(" + MLRegStr.rsExpr + ")\\s*"
				+ "(" + MLRegStr.rsExpr + ")");
			mt = rxOp.exec(line);
			if (mt != null) {
				var op:LogicOperator = cast mt[1], r = mt[2], a = mt[3], b = mt[4];
				var binOp = LogicOperator.logOpToBinOp[op];
				if (binOp != null) {
					if (r == a && LogicOperator.rxIsSetOp.test(binOp)) {
						set('$r $binOp= $b');
					} else {
						set('$r = $a $binOp $b');
					}
				} else if (LogicOperator.isUnary[op]) {
					set('$r = $op($a)');
				}
				continue;
			}
			
			@:static var rxRead = new RegExp("^(read|write)\\s+"
				+ "(" + MLRegStr.rsExpr + ")\\s*"
				+ "(" + MLRegStr.rsIdent + ")\\s*"
				+ "(" + MLRegStr.rsExpr + ")");
			mt = rxRead.exec(line);
			if (mt != null) {
				var kw = mt[1], v = mt[2], m = mt[3], i = mt[4];
				if (kw == 'write') {
					set('$m[$i] = $v');
				} else set('$v = $m[$i]');
				continue;
			}
		}
		
		var pcToLabel:Map<Int, String> = new Map();
		var labelID = 1;
		for (pair in pairs) {
			@:static var rxJump = new RegExp("^jump\\s+"
				+ "(\\d+)\\s*"
				+ "(" + MLRegStr.rsIdent + ")\\s*"
				+ "(" + MLRegStr.rsExpr + ")\\s*"
				+ "(" + MLRegStr.rsExpr + ")\\s*"
				+ "(?:#|$)");
			var mt = rxJump.exec(pair.text);
			if (mt == null) continue;
			
			var dest = Std.parseInt(mt[1]);
			if (!pcToPair.exists(dest)) continue;
			if (dest == pair.pc) continue;
			
			var label = pcToLabel[dest];
			if (label == null) {
				var dstPair = pcToPair[dest];
				label = "L" + (labelID++);
				pcToLabel[dest] = label;
				@:static var rxAddLabel = new RegExp("(^\\s*)(.*)");
				var lmt = rxAddLabel.exec(dstPair.text);
				if (lmt == null) continue;
				dstPair.text = lmt[1] + label + ": " + lmt[2];
			}
			var cmp:LogicCondOperator = cast mt[2];
			if (cmp != LogicCondOperator.Always) {
				var op = LogicCondOperator.logicToOp[cmp];
				pair.text = "if " + mt[3] + " " + 
					(op != null ? op : (cast cmp:String)) +
					" " + mt[4] + " jump " + label;
			} else {
				pair.text = "jump " + label;
			}
		}
		return pairs.map(pair->pair.text).join("\n");
	}
}
typedef SimplifierPair = { text:String, pc:Int }