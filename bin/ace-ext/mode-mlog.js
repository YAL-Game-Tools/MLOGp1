/**
 * ...
 * @author YellowAfterlife
 */
function AceMLogInit() {
ace.define("ace/mode/matching_brace_outdent",["require","exports","module","ace/range"], function(require, exports, module) {
"use strict";

var Range = require("../range").Range;

var MatchingBraceOutdent = function() {};

(function() {

	this.checkOutdent = function(line, input) {
		if (! /^\s+$/.test(line))
			return false;

		return /^\s*\}/.test(input);
	};

	this.autoOutdent = function(doc, row) {
		var line = doc.getLine(row);
		var match = line.match(/^(\s*\})/);

		if (!match) return 0;

		var column = match[1].length;
		var openBracePos = doc.findMatchingBracket({row: row, column: column});

		if (!openBracePos || openBracePos.row == row) return 0;

		var indent = this.$getIndent(doc.getLine(openBracePos.row));
		doc.replace(new Range(row, 0, row, column-1), indent);
	};

	this.$getIndent = function(line) {
		return line.match(/^\s*/)[0];
	};

}).call(MatchingBraceOutdent.prototype);

exports.MatchingBraceOutdent = MatchingBraceOutdent;
}); // ace.define("ace/mode/matching_brace_outdent", ...)

ace.define("ace/mode/mlog",["require","exports","module",
	"ace/lib/oop",
	"ace/mode/text",
	"ace/mode/mlog_highlight_rules",
	"ace/mode/matching_brace_outdent",
	"ace/mode/behaviour/cstyle",
	//"ace/mode/folding/cstyle",
], function(require, exports, module) {
"use strict";

var oop = require("../lib/oop");
var TextMode = require("./text").Mode;
var HighlightRules = require("./mlog_highlight_rules").HighlightRules;
var MatchingBraceOutdent = require("./matching_brace_outdent").MatchingBraceOutdent;
var CstyleBehaviour = require("./behaviour/cstyle").CstyleBehaviour;
//var CStyleFoldMode = require("./folding/cstyle").FoldMode;

var Mode = function() {
	this.HighlightRules = HighlightRules;
	
	this.$outdent = new MatchingBraceOutdent();
	this.$behaviour = new CstyleBehaviour();
	//this.foldingRules = new CStyleFoldMode();
};
oop.inherits(Mode, TextMode);

(function() {
	this.lineCommentStart = "#";
	//this.blockComment = {start: "/*", end: "*/"};
	
	this.getNextLineIndent = function(state, line, tab) {
		var indent = this.$getIndent(line);

		var tokenizedLine = this.getTokenizer().getLineTokens(line, state);
		var tokens = tokenizedLine.tokens;
		
		if (tokens.length && tokens[tokens.length-1].type.indexOf("comment") >= 0) {
			return indent;
		}

		if (state == "start") {
			//var match = line.match(/^.*[\{\(\[]\s*$/);
			//if (match) indent += tab;
		}

		return indent;
	};

	this.checkOutdent = function(state, line, input) {
		return this.$outdent.checkOutdent(line, input);
	};

	this.autoOutdent = function(state, doc, row) {
		this.$outdent.autoOutdent(doc, row);
	};

	this.$id = "ace/mode/mlog";
}).call(Mode.prototype);

exports.Mode = Mode;
});
}

function AceHighlight(){}
