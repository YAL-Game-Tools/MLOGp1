package compiler;
import tools.CharCode;
import tools.StringReader;

/**
 * ...
 * @author YellowAfterlife
 */
class CodeReader extends StringReader {
	public function readNumber() {
		var start = pos;
		var c = read();
		if (c == "+".code || c == "-".code) {
			skipLineSpaces();
			c = read();
		}
		if (c == "0".code) {
			if (skipIfEqu("x".code)) {
				while (loop) {
					if (peek().isHexDigit()) skip(); else break;
				}
				return substring(start, pos);
			}
			if (skipIfEqu("b".code)) {
				while (loop) {
					if (peek().isBinDigit()) skip(); else break;
				}
				return substring(start, pos);
			}
		}
		if (!c.isDigit()) throw "expected a number";
		while (loop) {
			if (peek().isDigit()) skip(); else break;
		}
		if (skipIfEqu(".".code)) {
			while (loop) {
				if (peek().isDigit()) skip(); else break;
			}
		}
		if (skipIfEqu("e".code)) {
			while (loop) {
				if (peek().isDigit()) skip(); else break;
			}
		}
		return substring(start, pos);
	}
	public function readExpr():String {
		var start = pos;
		var c:CharCode = peek();
		switch (c) {
			case "-".code: return readNumber();
			case "@".code: skip(); return "@" + readAtIdent();
			case '"'.code:
				skip();
				while (loop) {
					if (read() == '"'.code) return substring(start, pos);
				}
				throw "Unclosed string";
			case _ if (c.isDigit()): return readNumber();
			case _ if (c.isIdent0()): return readIdent();
			default: throw "Expected an expression";
		}
	}
	public function readMacroExpr():String {
		if (skipIfEqu("{".code)) {
			var start = pos;
			while (loop) {
				if (read() == '}'.code) return substring(start, pos - 1);
			}
			return substring(start, pos);
		} else return readExpr();
	}
	public function skipCommon(?peekChar:CharCode):Bool {
		if (peekChar == null) peekChar = peek();
		if (peekChar == '"'.code) {
			skip();
			while (loop) {
				if (read() == '"'.code) break;
			}
			return true;
		}
		return false;
	}
}