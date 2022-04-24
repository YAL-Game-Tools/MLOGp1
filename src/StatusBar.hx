package ;
import ace.Ace;
import ace.AceMacro.jsRx;
import compiler.CodeTools;
import compiler.LogicCondOperator;
import highlight.MLHighlightRules;
import highlight.MLRegStr;
import js.Browser;
import js.html.Element;
import js.lib.RegExp;
import highlight.MLRegStr.*;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(tools.LocalStatic.build())
class StatusBar {
	public static var element:Element;
	public static var span:Element;
	static function getHTML_1(line:String) {
		if (StringTools.trim(line) == "") return "";
		
		@:static var rxLabel = new RegExp("^(?:\\w+\\s*:\\s*)(.*)");
		var mt = rxLabel.exec(line);
		if (mt != null) return getHTML_1(mt[1]);
		
		@:static var rxIfPrefix = new RegExp("^if\\b"
			+ "\\s*" + '(?:$rsExpr)'
			+ "\\s*" + LogicCondOperator.rsCondOp
			+ "\\s*" + '(?:$rsExpr)'
			+ "\\s*" + "(?:then\\b\\s*)?"
			+ "(.*)");
		mt = rxIfPrefix.exec(line);
		if (mt != null) return getHTML_1(mt[1]);
		
		@:static var rxIf = jsRx(~/^if\b/);
		if (rxIf.test(line)) return "<b>if</b> expr1 op expr2 action"
			+ " · ops: <tt>==</tt>, <tt>!=</tt>, <tt>===</tt>, "
			+ "<tt>&lt;</tt>, <tt>&lt;=</tt>, <tt>&gt;</tt>, <tt>&gt;=</tt>";
		
		@:static var rxGetLink = jsRx(~/^getlink\b/);
		if (rxGetLink.test(line)) return "<b>getlink</b> resultVar index";
		
		@:static var rxJump = jsRx(~/^jump\b/);
		if (rxJump.test(line)) return "<b>jump</b> labelNameOrOffset";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+idle\b/);
		if (rxUControl.test(line)) return "<b>ucontrol idle</b> (no args) · default state";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+stop\b/);
		if (rxUControl.test(line)) return "<b>ucontrol stop</b> (no args) · stops moving/building/mining";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+move\b/);
		if (rxUControl.test(line)) return "<b>ucontrol move</b> x y · move to an exact position";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+approach\b/);
		if (rxUControl.test(line)) return "<b>ucontrol approach</b> x y radius · approach a position with a radius";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+boost\b/);
		if (rxUControl.test(line)) return "<b>ucontrol boost</b> enable · start/stop boosting";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+pathfind\b/);
		if (rxUControl.test(line)) return "<b>ucontrol pathfind</b> (no args) · pathfind to enemy spawn";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+target\b/);
		if (rxUControl.test(line)) return "<b>ucontrol target</b> x y shoot · shoot at a position";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+targetp\b/);
		if (rxUControl.test(line)) return "<b>ucontrol targetp</b> unit shoot · shoot a target with velocity prediction";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+itemDrop\b/);
		if (rxUControl.test(line)) return "<b>ucontrol itemDrop</b> targetBuilding amount · drop an item";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+itemTake\b/);
		if (rxUControl.test(line)) return "<b>ucontrol itemTake</b> sourceBuilding itemType amount · take an item";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+payDrop\b/);
		if (rxUControl.test(line)) return "<b>ucontrol payDrop</b> (no args) · drop the current payload";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+payTake\b/);
		if (rxUControl.test(line)) return "<b>ucontrol payTake</b> takeUnits · pick up paylload at current location";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+payEnter\b/);
		if (rxUControl.test(line)) return "<b>ucontrol payEnter</b> · enter/land on the payload block below the unit";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+mine\b/);
		if (rxUControl.test(line)) return "<b>ucontrol mine</b> x y · mine at a position";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+flag\b/);
		if (rxUControl.test(line)) return "<b>ucontrol flag</b> flagValue · change the unit's numeric flag";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+build\b/);
		if (rxUControl.test(line)) return "<b>ucontrol build</b> x y blockType rotation config · build a structure";
		
		@:static var rxUControl = jsRx(~/^ucontrol\s+within\b/);
		if (rxUControl.test(line)) return "<b>ucontrol within</b> x y radius resultVar · check whether unit is near a position";
		
		@:static var rxUControl = jsRx(~/^ucontrol\b/);
		if (rxUControl.test(line)) {
			@:static var ttUControl = "<b>ucontrol</b> " + MLHighlightRules.uControl.join("|");
			return ttUControl;
		}
		
		@:static var rxPrint = jsRx(~/^print\b/);
		if (rxPrint.test(line)) return "<b>print</b> expr";
		
		@:static var rxPrintFlush = jsRx(~/^printflush\b/);
		if (rxPrintFlush.test(line)) return "<b>printflush</b> messageBlock";
		
		return "";
	}
	static function getHTML() {
		var editor = Main.editor;
		var row = editor.selection.lead.row;
		var line = editor.session.getLine(row);
		
		line = CodeTools.splitLine(line).line;
		
		return getHTML_1(line);
	}
	static function update() {
		span.innerHTML = getHTML();
	}
	public static function init() {
		element = Browser.document.getElementById("statusbar");
		span = element.querySelector("span");
		var editor = Main.editor;
		
		var lang = Ace.require("ace/lib/lang");
		var dc = lang.delayedCall(update);
		var dcUpdate = function() dc.delay(50);
		editor.on("changeStatus", dcUpdate);
		editor.on("changeSelection", dcUpdate);
		editor.on("keyboardActivity", dcUpdate);
		dc.delay(350);
	}
}