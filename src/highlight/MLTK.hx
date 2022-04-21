package highlight;
import ace.types.AceTokenType;

/**
 * ...
 * @author YellowAfterlife
 */
enum abstract MLTK(AceTokenType) from AceTokenType to AceTokenType {
	var Keyword = "keyword";
	var Invalid = "invalid";
	var Pending = "invalid";
	var Comment = "comment";
	var Operator = "keyword.operator";
	var Comma = "keyword.operator";
	var Label = "entity.name.function";
	var Number = "constant.numeric";
	var Boolean = "constant.boolean";
	var Special = "constant.language";
	var AtTag = "language.support.class";
	var Variable = "identifier";
	var CString = "string";
	var LParen = "paren.lparen";
	var RParen = "paren.rparen";
	var Text = "text";
}