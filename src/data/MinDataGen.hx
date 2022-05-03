package data;
import sys.io.File;

/**
 * ...
 * @author YellowAfterlife
 */
class MinDataGen {
	public static function main() {
		var input = File.read("logicids.dat");
		var out = new StringBuf();
		out.add([
			"package data;",
			"/** auto-generated! See MinDataGen.hx */",
			"class MinAutoData {",
		].join("\r\n"));
		for (category in ["blocks", "units", "items", "liquids"]) {
			out.add('\r\npublic static var $category = [');
			input.bigEndian = true;
			var n = input.readInt16();
			trace('$category: $n');
			for (i in 0 ... n) {
				if (i > 0) out.add(", ");
				var idn = input.readInt16();
				var id = input.readString(idn);
				out.add('"$id"');
			}
			out.add('];');
		}
		out.add('\r\n}\r\n');
		File.saveContent("MinAutoData.hx", out.toString());
	}
}