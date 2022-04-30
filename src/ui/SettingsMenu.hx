package ui;
import compiler.Printer;
import js.Browser;
import js.html.Element;
import js.html.Event;
import js.html.InputElement;
import js.html.MouseEvent;

/**
 * ...
 * @author YellowAfterlife
 */
class SettingsMenu {
	public static function init() {
		var doc = Browser.document;
		doc.getElementById("code-settings").onclick = function(_) {
			(cast ace.Ace).config.loadModule("ace/ext/settings_menu", function(module) {
				module.init(Main.editor);
				untyped (cast Main.editor).showSettingsMenu();
			});
		};
		
		var menu = doc.querySelector(".menu");
		doc.addEventListener("mousedown", function(e:MouseEvent) {
			if (menu.style.display != "") return;
			var el:Element = cast e.target;
			while (el != null) {
				if (el == menu) return;
				el = el.parentElement;
			}
			menu.style.display = "none";
		});
		
		for (bg in doc.querySelectorAll(".popup-bg")) {
			bg.addEventListener("click", function(_) {
				bg.parentElement.style.display = "none";
			});
		}
		
		var showPC:InputElement = cast js.Browser.document.getElementById("showPC");
		Printer.printPC = showPC.checked = Storage.get("showPC") == "true";
		showPC.onchange = function(e:Event) {
			Printer.printPC = showPC.checked;
			Storage.set("showPC", "" + showPC.checked);
			Main.updateOutput();
		}
	}
}