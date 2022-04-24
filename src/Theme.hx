package ;
import js.Browser;
import js.html.Element;
import js.html.SelectElement;

/**
 * ...
 * @author YellowAfterlife
 */
class Theme {
	public static var themeSelect:SelectElement;
	public static function set(name:String) {
		var path = "ace/theme/" + name;
		Main.editor.setTheme(path, function() {
			var ctr = Main.editor.container;
			var css = Browser.window.getComputedStyle(ctr);
			var bg = css.backgroundColor;
			var fg = css.color;
			
			inline function applyColors(el:Element) {
				el.style.backgroundColor = bg;
				el.style.color = fg;
			}
			applyColors(StatusBar.element);
			//applyColors(themeSelect);
		});
		Main.output.setTheme(path);
	}
	public static function init() {
		themeSelect = cast Browser.document.getElementById("theme");
		var themeName = Storage.get("theme");
		if (themeName == null || themeName == "") themeName = "github";
		set(themeName);
		
		themeSelect.value = themeName;
		themeSelect.onchange = function(_) {
			var themeName = themeSelect.value;
			Storage.set("theme", themeName);
			set(themeName);
		}
	}
}