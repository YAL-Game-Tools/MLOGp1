package ace;
import ace.AceEditor;
import haxe.DynamicAccess;
import haxe.Json;
import js.Browser;

/**
 * ...
 * @author YellowAfterlife
 */
class AceExtras {
	static function loadConfig():DynamicAccess<Dynamic> {
		try {
			var text = Storage.get("aceOptions");
			if (text == null || text == "") return null;
			return Json.parse(text);
		} catch (e:Dynamic) {
			Console.error("Error loading Ace options: " + e);
			return null;
		};
	}
	static function hookSetOption(obj:Dynamic):Void {
		if (obj.setOption_raw != null) return;
		obj.setOption_raw = obj.setOption;
		obj.setOption = function(key:String, val:Dynamic) {
			if (key == "theme") {
				Theme.set(val);
			} else {
				obj.setOption_raw(key, val);
				
				// sync?
				if (obj == Main.editor) {
					(cast Main.output).setOption_raw(key, val);
				}
				else if (obj == Main.editor.renderer) {
					(cast Main.output.renderer).setOption_raw(key, val);
				}
				else if (obj == Main.output) {
					(cast Main.editor).setOption_raw(key, val);
				}
				else if (obj == Main.output.renderer) {
					(cast Main.editor.renderer).setOption_raw(key, val);
				} else return;
			}
			
			// save:
			var opts:DynamicAccess<Dynamic> = (cast Main.editor).getOptions();
			opts.remove("enableLiveAutocompletion");
			opts.remove("enableSnippets");
			opts.remove("mode");
			Storage.set("aceOptions", Json.stringify(opts));
			Console.log("Ace settings saved.");
		};
	}
	public static function bind(editor:AceEditor) {
		// load Ace options:
		var opts = loadConfig();
		if (opts != null) {
			opts.set("enableSnippets", true);
			opts.remove("mode");
			var theme = opts["theme"];
			opts.remove("theme");
			editor.setOptions(opts);
			if (theme != null) Theme.set(theme);
		}
		editor.setOption("fixedWidthGutter", true);
		// flush Ace options on changes (usually only via Ctrl+,):
		hookSetOption(editor);
		hookSetOption(editor.renderer);
	}
	public static function post() {
		var editor = Main.editor;
		if (editor.getOption("fontFamily") == null) {
			var np = Browser.window.navigator.platform;
			np = np != null ? np.toLowerCase() : "";
			var isMac = np.indexOf("mac") >= 0;
			var font = isMac ? "Menlo, monospace" : "Consolas, Courier New, monospace";
			editor.setOption("fontFamily", font);
			editor.setOption("printMargin", false);
		}
	}
}