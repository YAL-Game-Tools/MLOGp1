package editor;
import ace.AceEditor;
import ace.types.AceAfterExecArgs;
import ace.types.AceAutoCompleteItem;
import ace.types.AceAutoCompleteItems;
import ace.types.AceAutoCompleter;
import ace.types.AceEditorCompleter;
import editor.AceSimpleCompleter;
import highlight.MLTK;
import js.lib.RegExp;

/**
 * ...
 * @author YellowAfterlife
 */
class AceCompleters {
	var completers:Array<AceAutoCompleter> = [];
	var editor:AceEditor;
	var varItems:AceAutoCompleteItems = [];
	var varMap:Map<String, Bool> = new Map();
	public function mark(name:String, kind:String) {
		if (varMap.exists(name)) return;
		varMap[name] = true;
		varItems.push(new AceAutoCompleteItem(name, kind));
	}
	public function clearVars() {
		varItems.clear();
		varMap.clear();
	}
	
	function new(editor:AceEditor) {
		this.editor = editor;
		completers.push(initAtCompleter());
		var ac = new AceSimpleCompleter(varItems, [], true);
		ac.items = varItems;
		completers.push(ac);
	}
	
	function initAtCompleter() {
		var items:AceAutoCompleteItems = [];
		for (id in data.MinAutoData.blocks) {
			items.push(new AceAutoCompleteItem("@" + id, "block"));
		}
		for (id in data.MinAutoData.units) {
			items.push(new AceAutoCompleteItem("@" + id, "unit"));
		}
		for (id in data.MinAutoData.items) {
			items.push(new AceAutoCompleteItem("@" + id, "item"));
		}
		for (id in data.MinAutoData.liquids) {
			items.push(new AceAutoCompleteItem("@" + id, "liquid"));
		}
		for (id in data.MinData.sensorVars) {
			items.push(new AceAutoCompleteItem("@" + id, "sensor"));
		}
		for (id in data.MinData.specialVars) {
			items.push(new AceAutoCompleteItem("@" + id, "special"));
		}
		var comp = new AceSimpleCompleter(items, [MLTK.AtTag], false);
		comp.minLength = 1;
		comp.identifierRegexps = [new RegExp("[@]")];
		return comp;
	}
	
	function showPopup() {
		var c = editor.completer;
		if (c == null) {
			editor.completer = c = new AceEditorCompleter();
		}
		c.showPopup(editor);
	}
	function onAfterExec(e:AceAfterExecArgs) {
		if (e.command.name == "insertstring") {
			switch (e.args) {
				case "@": {
					//var tk = editor.session.getTokenAtPos(editor.selection.lead);
					//if (tk != null && tk.type == MLTK.AtTag) showPopup();
				}
			}
		}
	}
	
	function bind() {
		editor.setOptions({
			enableLiveAutocompletion: completers,
			enableSnippets: true,
		});
		editor.commands.on("afterExec", onAfterExec);
	}
	public static var inst:AceCompleters;
	public static function proc(editor:AceEditor) {
		var cc = new AceCompleters(editor);
		cc.bind();
		return cc;
	}
}