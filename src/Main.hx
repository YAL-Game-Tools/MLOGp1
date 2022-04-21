package;

import ace.Ace;
import ace.AceEditor;
import compiler.Compiler;
import highlight.MLHighlightRules;
import js.Browser;
import js.Lib;
import js.html.KeyboardEvent;
import js.html.SelectElement;
import js.html.Storage;

/**
 * ...
 * @author YellowAfterlife
 */
class Main {
	public static var editor:AceEditor;
	public static var output:AceEditor;
	public static var storage:Storage;
	static inline var storagePrefix:String = "mlog1";
	static function main() {
		editor = ace.Ace.edit("editor");
		output = ace.Ace.edit("output");
		(cast Browser.window).aceEditor = editor;
		highlight.MLHighlightRules.init();
		(cast Browser.window).AceMLogInit();
		editor.session.setMode("ace/mode/mlog");
		output.session.setMode("ace/mode/mlog");
		var lang = Ace.require("ace/lib/lang");
		var delayCompile = lang.delayedCall(function() {
			output.setValue(compiler.Compiler.proc(editor.getValue()));
			output.clearSelection();
		});
		(cast editor).on("change", function() {
			delayCompile.delay(1000);
		});
		
		var themeSelect:SelectElement = cast Browser.document.getElementById("theme");
		storage = Browser.getLocalStorage();
		if (storage != null) {
			var code = storage.getItem('$storagePrefix/code');
			if (code != null && code != "") {
				editor.setValue(code);
				editor.clearSelection();
			}
			var themeName = storage.getItem('$storagePrefix/theme');
			if (themeName == null || themeName == "") themeName = "github";
			themeSelect.value = themeName;
			editor.setTheme("ace/theme/" + themeName);
			output.setTheme("ace/theme/" + themeName);
		} else {
			editor.setTheme("ace/theme/github");
			output.setTheme("ace/theme/github");
		}
		
		themeSelect.onchange = function(_) {
			var themeName = themeSelect.value;
			if (storage != null) storage.setItem('$storagePrefix/theme', themeName);
			editor.setTheme("ace/theme/" + themeName);
			output.setTheme("ace/theme/" + themeName);
		}
		
		Browser.document.addEventListener("keydown", function(e:KeyboardEvent) {
			if (e.ctrlKey && (e.key == "Enter" || e.key == "S")) {
				var code = editor.getValue();
				if (storage != null) storage.setItem('$storagePrefix/code', code);
				code = compiler.Compiler.proc(code);
				Browser.navigator.clipboard.writeText(code);
				e.preventDefault();
			}
		});
		Browser.window.onbeforeunload = function(_) {
			if (storage != null) storage.setItem('$storagePrefix/code', editor.getValue());
			return null;
		}
	}
	
}