package ;
import js.Browser;

/**
 * ...
 * @author YellowAfterlife
 */
class Storage {
	public static var isAvailable:Bool;
	static var localStorage:js.html.Storage;
	static inline var storagePrefix:String = "mlog1/";
	public static function init() {
		localStorage = Browser.getLocalStorage();
		isAvailable = localStorage != null;
	}
	public static function get(key:String) {
		return localStorage != null ? localStorage.getItem(storagePrefix + key) : null;
	}
	public static function set(key:String, val:String) {
		if (localStorage != null) localStorage.setItem(storagePrefix + key, val);
	}
}