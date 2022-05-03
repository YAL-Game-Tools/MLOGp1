package;

import ace.Ace;
import ace.AceEditor;
import editor.AceExtras;
import editor.*;
import compiler.Compiler;
import compiler.Simplifier;
import highlight.MLHighlightRules;
import js.Browser;
import js.Lib;
import js.html.KeyboardEvent;
import js.html.SelectElement;
import js.html.Storage;
import js.html.TextAreaElement;
import ui.SettingsMenu;
import ui.StatusBar;

/**
 * ...
 * @author YellowAfterlife
 */
class Main {
	public static var editor:AceEditor;
	public static var output:AceEditor;
	public static var copyField:TextAreaElement;
	public static function updateOutput() {
		var code = editor.getValue();
		copyField.value = code;
		output.setValueAndClearSelection(Compiler.proc(code));
	}
	static function main() {
		Storage.init();
		
		editor = Ace.edit("editor");
		editor.container.id = "editor";
		(cast Browser.window).aceEditor = editor;
		
		output = Ace.edit("output");
		output.container.id = "output";
		(cast Browser.window).aceOutput = output;
		
		MLHighlightRules.init();
		(cast Browser.window).AceMLogInit();
		
		for (e in [editor, output]) {
			e.session.setMode("ace/mode/mlog");
			AceExtras.bind(e);
		}
		AceExtras.post();
		for (e in [editor, output]) AceCompleters.proc(e);
		
		copyField = cast Browser.document.getElementById("copyfield");
		copyField.value = "Built at " + ace.AceMacro.buildDate() + "\nOutput will go here.";
		
		var lang = Ace.require("ace/lib/lang");
		var delayCompile = lang.delayedCall(function() {
			updateOutput();
		});
		(cast editor).on("change", function() {
			delayCompile.delay(1000);
		});
		
		var code = Storage.get("code");
		if (code != null && code != "") editor.setValueAndClearSelection(code);
		StatusBar.init();
		SettingsMenu.init();
		
		Browser.document.getElementById("simplify").onclick = function(_) {
			editor.setValue(Simplifier.proc(editor.getValue()));
			editor.clearSelection();
		}
		var copy = Browser.document.getElementById("copy");
		function copyToClipboard() {
			var code = editor.getValue();
			Storage.set("code", code);
			code = Compiler.proc(code);
			if (js.Syntax.strictEq(Browser.window.ontouchstart, js.Lib.undefined)) {
				Browser.navigator.clipboard.writeText(code);
			} else try {
				copyField.value = code;
				copyField.select();
				copyField.setSelectionRange(0, code.length);
				Browser.document.execCommand("copy");
			} catch (x:Dynamic) {
				Console.error(x);
				Browser.navigator.clipboard.writeText(code);
			}
		}
		copy.onclick = function(e) copyToClipboard();
		
		Browser.document.addEventListener("keydown", function(e:KeyboardEvent) {
			if (e.ctrlKey && (e.key == "Enter" || e.key == "S")) {
				e.preventDefault();
				copyToClipboard();
			}
		});
		Browser.window.onbeforeunload = function(_) {
			Storage.set("code", editor.getValue());
			return null;
		}
	}
	
}