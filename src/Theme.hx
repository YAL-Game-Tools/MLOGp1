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
		var path = name;
		if (!StringTools.startsWith(path, "ace/")) path = "ace/theme/";
		Main.editor.setTheme(path, function() {
			var ctr = Main.editor.container;
			var css = Browser.window.getComputedStyle(ctr);
			var st = Browser.document.documentElement.style;
			st.setProperty("--ace-bg", css.backgroundColor);
			st.setProperty("--ace-fg", css.color);
		});
		Main.output.setTheme(path);
	}
	public static function init() {
		/*themeSelect = cast Browser.document.getElementById("theme");
		var themeName = Storage.get("theme");
		if (themeName == null || themeName == "") themeName = "github";
		set(themeName);
		
		themeSelect.value = themeName;
		themeSelect.onchange = function(_) {
			var themeName = themeSelect.value;
			Storage.set("theme", themeName);
			set(themeName);
		}*/
	}
}