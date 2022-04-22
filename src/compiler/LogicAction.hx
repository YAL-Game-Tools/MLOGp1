package compiler;

/**
 * ...
 * @author YellowAfterlife
 */
class LogicAction {
	public var tab:String;
	public var def:LogicActionDef;
	public var notes:Array<String>;
	public function new(tab:String, def:LogicActionDef, notes:Array<String>) {
		this.tab = tab;
		this.def = def;
		this.notes = notes;
	}
}
enum LogicActionDef {
	Label(name:String, action:LogicAction);
	Block(actions:Array<LogicAction>);
	IfThen(a:String, op:LogicCondOperator, b:String, then:LogicAction);
	Jump(prefix:String, label:String, rest:String);
	Other(text:String);
	Text(text:String);
}
