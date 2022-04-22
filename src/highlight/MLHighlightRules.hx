package highlight ;
import ace.Ace;
import ace.AceHighlight;
import ace.types.*;
import ace.types.AceLangRule;
import ace.AceMacro.*;
import ace.Ace;
import ace.AceHighlightTools.*;
import compiler.LogicAction;
import compiler.LogicCondOperator;
import compiler.LogicOperator;
import highlight.MLRegStr;
import js.lib.RegExp;
import tools.CharCode;
import highlight.MLRegStr.*;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
@:build(tools.LocalStatic.build())
class MLHighlightRules extends AceHighlight {
	static inline function rsOpt(rs:String, opt:Bool = true) {
		return opt ? "(?:" + rs + ")?" : rs;
	}
	static function makeRules(hl:AceHighlight):AceHighlightRuleset {
		var keywordList = [
			'read', 'write', 'draw', 'print', 'drawflush', 'printflush',
			'getlink', 'control', 'radar', 'sensor', 'set', 'op', 'end', 'jump', 'noop',
			'ubind', 'ucontrol', 'ulocate', 'wait'
		];
		function getExprType(expr:String):AceTokenType {
			var c:CharCode = expr.charCodeAt(0);
			if (c == "@".code) return MLTK.AtTag;
			if (c == '"'.code) return MLTK.CString;
			if (c.isIdent0()) {
				if (expr == "null") return MLTK.Special;
				if (expr == "true" || expr == "false") return MLTK.Boolean;
				return MLTK.Variable;
			}
			if (c == '-'.code || c == '+'.code || c == '.'.code || c.isDigit()) return MLTK.Number;
			return MLTK.Invalid;
		}
		var keywordMap = new Map();
		for (word in keywordList) keywordMap[word] = "keyword";
		var base = [
			rxRule(MLTK.Comment, ~/#.*/),
			rxRule(MLTK.AtTag, ~/@\w+/),
			rxRule(MLTK.Boolean, ~/(?:true|false)\b/),
			rxRule(MLTK.Special, ~/null\b/),
			rule(MLTK.CString, rsString),
			rule(MLTK.Number, rsNumber),
			rule(MLTK.Variable, rsIdent),
			rule(MLTK.LParen, "\\("),
			rule(MLTK.RParen, "\\)"),
			rxRule("text", ~/\s+/),
		];
		var line = [
			rxRule(MLTK.Text, ~/$/, "start"),
		].concat(base);
		
		var start:Array<AceLangRule> = [
			rxRule(MLTK.Label, ~/[a-zA-Z_]\w*\s*:/),
		];
		inline function pushEolRule(dest:Array<AceLangRule>, fn:Bool->AceLangRule) {
			dest.push(fn(true));
			dest.push(fn(false));
		}
		
		function genIfThenRule(eol:Bool) {
			return rulePairsExt({
				onPairMatch: function(tokens:Array<AceToken>, currentState, stack, line, row) {
					@:static var opMapper = [
						"==" => true,
						"!=" => true,
						"<>" => true,
						"<" => true,
						"<=" => true,
						">" => true,
						">=" => true,
						"===" => true,
					];
					tokens[2].type = getExprType(tokens[2].value);
					tokens[4].type = opMapper[tokens[4].value] ? MLTK.Operator : MLTK.Invalid;
					tokens[6].type = getExprType(tokens[6].value);
					return tokens;
				},
				next: "start",
				pairs: [
					"if\\b", MLTK.Keyword,
					"\\s*", MLTK.Text,
					rsOpt(rsExpr, eol), MLTK.Pending, // 2
					"\\s*", MLTK.Text,
					"==|!=|<>|<|<=|>|>=|===|\\S*", MLTK.Operator,
					"\\s*", MLTK.Text,
					rsOpt(rsExpr, eol), MLTK.Pending, // 6
					"\\s*", MLTK.Text,
					"(?:then)?", MLTK.Keyword,
				].concat(eol ? ["($)", MLTK.Text] : []),
			});
		}; pushEolRule(start, genIfThenRule);
		
		function genJumpRule(eol:Bool) { // `jump label`
			return rulePairsExt({
				onPairMatch: function(tokens:Array<AceToken>, currentState, stack, line, row) {
					@:static var rxStartsWithDigit = new RegExp("^\\d");
					tokens[2].type = rxStartsWithDigit.test(tokens[2].value) ? MLTK.Number : MLTK.Label;
					tokens[4].type = LogicCondOperator.valNameMap.exists(tokens[4].value) ? MLTK.Keyword : MLTK.Invalid;
					return tokens;
				},
				next: eol ? null : "jump",
				pairs: [
					"jump\\b", MLTK.Keyword,
					"\\s*", MLTK.Text,
					"\\w*", MLTK.Pending,
					"\\s*", MLTK.Text,
					"(?:" + rsIdent + ")?", MLTK.Pending,
				].concat(eol ? ["($)", MLTK.Text] : []),
			});
		}; pushEolRule(start, genJumpRule);
		
		function genSetFuncRule(eol:Bool) { // `v = func(`
			return rulePairsExt({
				onPairMatch: function(tokens:Array<AceToken>, currentState, stack, line, row) {
					@:static var rxStartsWithDigit = new RegExp("^\\d");
					tokens[2].type = rxStartsWithDigit.test(tokens[2].value) ? MLTK.Number : MLTK.Label;
					tokens[4].type = LogicOperator.valNameMap.exists(tokens[4].value) ? MLTK.Keyword : MLTK.Invalid;
					return tokens;
				},
				next: eol ? null : "line",
				rawPairs: [
					'($rsIdent)', MLTK.Variable,
					"(\\s*)", MLTK.Text,
					
					"(=)", MLTK.Operator,
					"(\\s*)", MLTK.Text,
					
					'($rsIdent)', MLTK.Variable, // 4: func
					"(\\s*)", MLTK.Text,
					
					"(\\()", MLTK.LParen,
				].concat(eol ? ["($)", MLTK.Text] : []),
			});
		}; pushEolRule(start, genSetFuncRule);
		
		pushEolRule(start, function(eol:Bool) return rulePairsExt({ // r = a, r = a op b
			rawPairs: [
				'($rsIdent)', MLTK.Variable,
				"(\\s*)", MLTK.Text,
				
				"(=)", MLTK.Operator,
				"(\\s*)", MLTK.Text,
			].concat(eol ? ["($)", MLTK.Text] : []),
			next: eol ? null : "set",
		}));
		
		function genOpRule(eol:Bool) {
			return rulePairsExt({
				onPairMatch: function(tokens:Array<AceToken>, currentState, stack, line, row) {
					tokens[2].type = LogicOperator.valNameMap.exists(tokens[2].value) ? MLTK.Keyword : MLTK.Invalid;
					return tokens;
				},
				next: eol ? null : "line",
				pairs: [
					"op\\b", MLTK.Keyword,
					"\\s*", MLTK.Text,
					"(?:" + rsIdent + ")?", MLTK.Pending,
				].concat(eol ? ["($)", MLTK.Text] : []),
			});
		}; pushEolRule(start, genOpRule);
		
		start = start.concat([
			rxRule(function(word) {
				return jsOr(keywordMap[word], MLTK.Variable);
			}, ~/[a-zA-Z_]\w*$/),
			rxRule(function(word) {
				return jsOr(keywordMap[word], MLTK.Variable);
			}, ~/[a-zA-Z_]\w*/, "line"),
			rxRule(MLTK.Comment, ~/#.*/),
			rxRule(MLTK.Invalid, ~/\S.*/),
		]);
		
		return {
			"start": start,
			"line": line,
			"jump": [
				
			].concat(line),
			"set": [
				rule(function(word) {
					return LogicOperator.valNameMap.exists(word) ? MLTK.Keyword : getExprType(word);
				}, rsIdent),
			].concat(line),
		}
	}
	public function new() {
		rules = makeRules(this);
		normalizeRules();
	}
	public static function define(require:AceRequire, exports:AceExports, module:AceModule) {
		var oop = require("../lib/oop");
		var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;
		//
		oop.inherits(MLHighlightRules, TextHighlightRules);
		exports.HighlightRules = MLHighlightRules;
	}
	public static function init() {
		Ace.define("ace/mode/mlog_highlight_rules", [
			"require", "exports", "module",
			"ace/lib/oop", "ace/mode/doc_comment_highlight_rules", "ace/mode/text_highlight_rules"
		], define);
	}
}
