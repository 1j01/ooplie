(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.Ooplie = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Context, Pattern, stringify_tokens, tokenize;

tokenize = require("./tokenize");

Pattern = require("./Pattern");

stringify_tokens = require("./Token").stringify_tokens;

module.exports = Context = (function() {
  function Context(arg) {
    var ref;
    ref = arg != null ? arg : {}, this.console = ref.console, this.supercontext = ref.supercontext;
    this.patterns = [
      new Pattern({
        match: ["output <text>", "output <text> to the console", "log <text>", "log <text> to the console", "print <text>", "print <text> to the console", "say <text>"],
        bad_match: ["puts <text>", "println <text>", "print line <text>", "printf <text>", "console.log <text>", "writeln <text>", "output <text> to the terminal", "log <text> to the terminal", "print <text> to the terminal"],
        fn: (function(_this) {
          return function(arg1) {
            var text;
            text = arg1.text;
            _this.console.log(_this.eval_tokens(text));
          };
        })(this)
      }), new Pattern({
        match: ["run JS <text>", "run JavaScript <text>", "run <text> as JS", "run <text> as JavaScript", "execute JS <text>", "execute JavaScript <text>", "execute <text> as JS", "execute <text> as JavaScript", "eval JS <text>", "eval JavaScript <text>", "eval <text> as JS", "eval <text> as JavaScript"],
        bad_match: ["eval <text>", "execute <text>", "JavaScript <text>", "JS <text>"],
        fn: (function(_this) {
          return function(arg1) {
            var console, text;
            text = arg1.text;
            console = _this.console;
            return eval(_this.eval_tokens(text));
          };
        })(this)
      }), new Pattern({
        match: ["<a> ^ <b>", "<a> to the power of <b>"],
        bad_match: ["<a> ** <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return Math.pow(_this.eval_tokens(a), _this.eval_tokens(b));
          };
        })(this)
      }), new Pattern({
        match: ["<a> * <b>", "<a> times <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) * _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["<a> / <b>", "<a> divided by <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) / _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["<a> + <b>", "<a> plus <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) + _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["<a> - <b>", "<a> minus <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) - _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["- <b>", "negative <b>"],
        bad_match: ["minus <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return -_this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["+ <b>", "positive <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return +_this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["<a> = <b>", "<a> equals <b>", "<a> is equal to <b>", "<a> is <b>"],
        bad_match: ["<a> == <b>", "<a> === <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) === _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["<a> != <b>", "<a> does not equal <b>", "<a> is not equal to <b>", "<a> isn't <b>"],
        bad_match: ["<a> isnt <b>", "<a> isnt equal to <b>", "<a> isn't equal to <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) !== _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["<a> > <b>", "<a> is greater than <b>"],
        bad_match: ["<a> is more than <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) > _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["<a> < <b>", "<a> is less than <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) < _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["<a> >= <b>", "<a> is greater than or equal to <b>"],
        bad_match: ["<a> is more than or equal to <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) >= _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["<a> <= <b>", "<a> is less than or equal to <b>"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return _this.eval_tokens(a) <= _this.eval_tokens(b);
          };
        })(this)
      }), new Pattern({
        match: ["true", "yes", "on"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return true;
          };
        })(this)
      }), new Pattern({
        match: ["false", "no", "off"],
        fn: (function(_this) {
          return function(arg1) {
            var a, b;
            a = arg1.a, b = arg1.b;
            return false;
          };
        })(this)
      }), new Pattern({
        match: ["If <condition>, <actions>", "If <condition> then <actions>", "<actions> if <condition>"],
        fn: (function(_this) {
          return function(arg1) {
            var actions, condition;
            condition = arg1.condition, actions = arg1.actions;
            if (_this.eval_tokens(condition)) {
              return _this.eval_tokens(actions);
            }
          };
        })(this)
      }), new Pattern({
        match: ["Unless <condition>, <actions>", "Unless <condition> then <actions>", "<actions> unless <condition>"],
        fn: (function(_this) {
          return function(arg1) {
            var actions, condition;
            condition = arg1.condition, actions = arg1.actions;
            if (!_this.eval_tokens(condition)) {
              return _this.eval_tokens(actions);
            }
          };
        })(this)
      }), new Pattern({
        match: ["If <condition>, <actions>, else <alt_actions>", "If <condition> then <actions>, else <alt_actions>", "If <condition> then <actions> else <alt_actions>", "<actions> if <condition> else <alt_actions>"],
        bad_match: ["if <condition>, then <actions>, else <alt_actions>", "if <condition>, then <actions>, else, <alt_actions>", "if <condition>, <actions>, else, <alt_actions>"],
        fn: (function(_this) {
          return function(arg1) {
            var actions, alt_actions, condition;
            condition = arg1.condition, actions = arg1.actions, alt_actions = arg1.alt_actions;
            if (_this.eval_tokens(condition)) {
              return _this.eval_tokens(actions);
            } else {
              return _this.eval_tokens(alt_actions);
            }
          };
        })(this)
      })
    ];
    this.classes = [];
    this.objects = [];
    this.variables = {};
  }

  Context.prototype.subcontext = function(arg) {
    var console;
    console = (arg != null ? arg : {}).console;
    if (console == null) {
      console = this.console;
    }
    return new Context({
      console: console,
      supercontext: this
    });
  };

  Context.prototype["eval"] = function(text) {
    var result;
    result = null;
    this.interpret(text, function(err, res) {
      if (err) {
        throw err;
      }
      return result = res;
    });
    return result;
  };

  Context.prototype.eval_tokens = function(tokens) {
    var bad_match, i, j, last_token, len, match, pattern, ref, str, token;
    if (tokens.every(function(token) {
      var ref;
      return (ref = token.type) === "string" || ref === "number";
    })) {
      if (tokens.some(function(token) {
        return token.type === "string";
      })) {
        str = "";
        for (i = 0, len = tokens.length; i < len; i++) {
          token = tokens[i];
          str += token.value;
        }
        return str;
      } else if (tokens.length) {
        last_token = tokens[tokens.length - 1];
        return last_token.value;
      }
    } else if (tokens.length) {
      bad_match = null;
      ref = this.patterns;
      for (j = ref.length - 1; j >= 0; j += -1) {
        pattern = ref[j];
        match = pattern.match(tokens);
        if (match != null) {
          if (match.bad || match.near) {
            bad_match = match;
          } else {
            break;
          }
        }
      }
      if (match) {
        return pattern.fn(match);
      } else if (bad_match) {
        throw new Error("For `" + (stringify_tokens(tokens)) + "`, use " + bad_match.pattern.prefered + " instead");
      } else {
        throw new Error("I don't understand `" + (stringify_tokens(tokens)) + "`");
      }
    }
  };

  Context.prototype.interpret = function(text, callback) {
    var handle_line, i, len, line_tokens, ref, result, token;
    if (text.match(/^((Well|So|Um|Uh),? )?(Hi|Hello|Hey|Greetings|Hola)/i)) {
      return callback(null, (text.match(/^[A-Z]/) ? "Hello" : "hello") + (text.match(/\.|!/) ? "." : ""));
    } else if (text.match(/^((Well|So|Um|Uh),? )?(What'?s up|Sup)/i)) {
      return callback(null, (text.match(/^[A-Z]/) ? "Not much" : "not much") + (text.match(/\?|!/) ? "." : ""));
    } else if (text.match(/^(>?[:;8X]-?[()O3PCDS]|[D()OC]-?[:;8X]<?)$/i)) {
      return callback(null, text);
    } else if (text.match(/^(!*\?+!*|(please |plz )?(((I )?(want|need)[sz]?|display|show( me)?|view) )?(the |some )?help|^(gimme|give me|lend me) ((the |some )?)help| a hand( here)?)/i)) {
      return callback(null, "Sorry, I can't help.");
    } else if (text.match(/^(clr|clear)( console)?( output)?|cls$/i)) {
      if (this.console != null) {
        this.console.clear();
        return callback(null, "Console cleared.");
      } else {
        return callback(new Error("No console to clear."));
      }
    } else {
      result = void 0;
      line_tokens = [];
      handle_line = (function(_this) {
        return function() {
          var e, error;
          if (line_tokens.length) {
            try {
              result = _this.eval_tokens(line_tokens);
            } catch (error) {
              e = error;
              callback(e);
            }
          }
          return line_tokens = [];
        };
      })(this);
      ref = tokenize(text);
      for (i = 0, len = ref.length; i < len; i++) {
        token = ref[i];
        if (token.type !== "comment") {
          if (token.type === "newline") {
            handle_line();
          } else {
            line_tokens.push(token);
          }
        }
      }
      handle_line();
      return callback(null, result);
    }
  };

  return Context;

})();


},{"./Pattern":2,"./Token":3,"./tokenize":5}],2:[function(require,module,exports){
var Pattern, stringify_matcher, stringify_tokens,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

stringify_tokens = require("./Token").stringify_tokens;

stringify_matcher = function(matcher) {
  return matcher.join(" ");
};

module.exports = Pattern = (function() {
  function Pattern(arg) {
    var bad_match, match, parse_matchers;
    match = arg.match, bad_match = arg.bad_match, this.fn = arg.fn;
    parse_matchers = function(matcher_defs) {
      var def, j, len, results, segment, segments, value, variable_name, variable_names_used;
      results = [];
      for (j = 0, len = matcher_defs.length; j < len; j++) {
        def = matcher_defs[j];
        segments = def.replace(/\ <\ /g, " &lt; ").replace(/\ >\ /g, " &gt; ").replace(/\ <=\ /g, " &lt;= ").replace(/\ >=\ /g, " &gt;= ").replace(/<([^>]*)(\ )/g, function(m, words, space) {
          return words + "_**";
        }).replace(/>\ /g, ">").replace(/>/g, "> ").trim().split(" ");
        variable_names_used = [];
        results.push((function() {
          var k, len1, results1;
          results1 = [];
          for (k = 0, len1 = segments.length; k < len1; k++) {
            segment = segments[k];
            if (segment.match(/^<.*>$/)) {
              variable_name = segment.replace(/[<>]/g, "").replace(/_\*\*/g, " ");
              if (indexOf.call(variable_names_used, variable_name) >= 0) {
                throw new Error("Variable name `" + variable_name + "` used twice in pattern `" + def + "`");
              }
              if (variable_name === "pattern") {
                throw new Error("Reserved pattern variable `pattern` used in pattern `" + def + "`");
              }
              variable_names_used.push(variable_name);
              results1.push({
                type: "variable",
                name: variable_name,
                toString: function() {
                  return "<" + this.name + ">";
                }
              });
            } else {
              value = segment.replace(/&lt;/g, "<").replace(/&gt;/g, ">");
              results1.push({
                type: value.match(/\w/) ? "word" : "punctuation",
                value: value,
                toString: function() {
                  return this.value;
                }
              });
            }
          }
          return results1;
        })());
      }
      return results;
    };
    this.matchers = parse_matchers(match);
    this.bad_matchers = parse_matchers(bad_match != null ? bad_match : []);
    this.prefered = match[0];
  }

  Pattern.prototype.match_with = function(tokens, matcher) {
    var current_variable_tokens, i, j, len, matching, ref, ref1, token, variables;
    variables = {};
    current_variable_tokens = null;
    i = 0;
    for (j = 0, len = tokens.length; j < len; j++) {
      token = tokens[j];
      if (i >= matcher.length) {
        return;
      }
      matching = matcher[i];
      if (matching.type === "variable") {
        if (current_variable_tokens != null) {
          if (token.type === ((ref = matcher[i + 1]) != null ? ref.type : void 0) && token.value === ((ref1 = matcher[i + 1]) != null ? ref1.value : void 0)) {
            current_variable_tokens = null;
            i += 2;
          } else {
            current_variable_tokens.push(token);
          }
        } else {
          current_variable_tokens = [];
          variables[matching.name] = current_variable_tokens;
          current_variable_tokens.push(token);
        }
      } else {
        current_variable_tokens = null;
        if (token.type === matching.type && token.value === matching.value) {
          i += 1;
        } else {
          return;
        }
      }
    }
    if (current_variable_tokens != null) {
      i += 1;
    }
    if (i === matcher.length) {
      variables.pattern = this;
      return variables;
    }
  };

  Pattern.prototype.match = function(tokens) {
    var j, k, len, len1, match, matcher, ref, ref1;
    ref = this.matchers;
    for (j = 0, len = ref.length; j < len; j++) {
      matcher = ref[j];
      match = this.match_with(tokens, matcher);
      if (match != null) {
        return match;
      }
    }
    ref1 = this.bad_matchers;
    for (k = 0, len1 = ref1.length; k < len1; k++) {
      matcher = ref1[k];
      match = this.match_with(tokens, matcher);
      if (match != null) {
        match.bad = true;
        return match;
      }
    }
  };

  return Pattern;

})();


},{"./Token":3}],3:[function(require,module,exports){
var Token;

module.exports = Token = (function() {
  function Token(type, col, row, value) {
    this.type = type;
    this.col = col;
    this.row = row;
    this.value = value;
  }

  Token.prototype.toString = function() {
    return Token.stringify_tokens(this);
  };

  Token.stringify_tokens = function(tokens) {
    var i, len, ref, str, token;
    str = "";
    for (i = 0, len = tokens.length; i < len; i++) {
      token = tokens[i];
      if (token.type === "punctuation") {
        if ((ref = token.value) === "," || ref === "." || ref === ";" || ref === ":") {
          str += token.value;
        } else {
          str += " " + token.value;
        }
      } else if (token.type === "string") {
        str += " " + (JSON.stringify(token.value));
      } else if (token.type === "comment") {
        str += "#" + token.value;
      } else {
        str += " " + token.value;
      }
    }
    return str.trim();
  };

  return Token;

})();


},{}],4:[function(require,module,exports){
var Context, Pattern, Token, tokenize;

Context = require('./Context');

Pattern = require('./Pattern');

Token = require('./Token');

tokenize = require('./tokenize');

module.exports = {
  Context: Context,
  Pattern: Pattern,
  Token: Token,
  tokenize: tokenize
};


},{"./Context":1,"./Pattern":2,"./Token":3,"./tokenize":5}],5:[function(require,module,exports){
var Token, check_indentation;

Token = require('./Token');

check_indentation = function(source) {
  var char_name, column_index, indentation, j, k, len, len1, line, line_index, previous_indentation, previous_indentation_char, ref, results;
  previous_indentation = "";
  ref = source.replace(/\r/g, "").split("\n");
  results = [];
  for (line_index = j = 0, len = ref.length; j < len; line_index = ++j) {
    line = ref[line_index];
    indentation = line.match(/^\s*/)[0];
    for (column_index = k = 0, len1 = previous_indentation.length; k < len1; column_index = ++k) {
      previous_indentation_char = previous_indentation[column_index];
      if (indentation[column_index]) {
        if (indentation[column_index] !== previous_indentation_char) {
          char_name = (function() {
            switch (indentation[column_index]) {
              case "\t":
                return "tab";
              case " ":
                return "space";
              default:
                return JSON.stringify(indentation[column_index]);
            }
          })();
          throw new Error("Mixed indentation between lines " + line_index + " and " + (line_index + 1) + " at column " + (column_index + 1));
        }
      }
    }
    results.push(previous_indentation = indentation);
  }
  return results;
};

module.exports = function(source) {
  var char, col, current_token_string, current_type, finish_token, handle_indentation, i, indent_level, is_last_newline_before_quote, j, len, match, next_char, next_type, prev_char, previous_was_escape, quote_char, ref, ref1, row, start_string, string_content_indentation, string_content_on_first_line, string_content_started, string_first_newline_cannot_be_ignored, string_first_newline_found, string_indent_level, tokens, whitespace_after;
  check_indentation(source);
  tokens = [];
  row = 1;
  col = 1;
  current_type = null;
  next_type = null;
  current_token_string = "";
  quote_char = null;
  string_content_on_first_line = false;
  string_first_newline_found = false;
  string_content_started = false;
  string_content_indentation = null;
  indent_level = 0;
  handle_indentation = function(i, row, col) {
    var indentation, ref, results;
    indentation = "";
    while (true) {
      i += 1;
      if ((ref = source[i]) != null ? ref.match(/[\t\ ]/) : void 0) {
        indentation += source[i];
      } else {
        break;
      }
    }
    if (indentation.length > indent_level) {
      tokens.push(new Token("indent", row, col, indentation));
      indent_level = indentation.length;
    }
    results = [];
    while (indentation.length < indent_level) {
      tokens.push(new Token("dedent", row, col, indentation));
      results.push(indent_level -= 1);
    }
    return results;
  };
  start_string = function(char) {
    next_type = "string";
    quote_char = char;
    string_content_on_first_line = false;
    string_first_newline_found = false;
    string_content_started = false;
    return string_content_indentation = null;
  };
  finish_token = function() {
    if (current_type === "number") {
      tokens.push(new Token(current_type, row, col, parseFloat(current_token_string)));
    } else if (current_type != null) {
      tokens.push(new Token(current_type, row, col, current_token_string));
    }
    current_token_string = "";
    return current_type = null;
  };
  previous_was_escape = false;
  for (i = j = 0, len = source.length; j < len; i = ++j) {
    char = source[i];
    prev_char = (ref = source[i - 1]) != null ? ref : "";
    next_char = (ref1 = source[i + 1]) != null ? ref1 : "";
    next_type = current_type;
    if (current_type === "comment") {
      if (char === "\n") {
        next_type = null;
        if (next_type !== current_type) {
          finish_token();
        }
        current_type = next_type;
        tokens.push(new Token("newline", row, col, "\n"));
        handle_indentation(i, row, col);
      } else {
        current_token_string += char;
      }
    } else if (current_type === "string") {
      if (previous_was_escape) {
        previous_was_escape = false;
      } else if (char === "\\") {
        switch (next_char) {
          case "n":
            current_token_string += "\n";
            break;
          case "r":
            current_token_string += "\r";
            break;
          case "t":
            current_token_string += "\t";
            break;
          case "v":
            current_token_string += "\v";
            break;
          case "b":
            current_token_string += "\b";
            break;
          case "0":
            current_token_string += "\0";
            break;
          case "\\":
            current_token_string += "\\";
            break;
          case "'":
            current_token_string += "'";
            break;
          case '"':
            current_token_string += '"';
            break;
          default:
            throw new Error("Unknown backslash escape \\" + char + " (Do you need to escape the backslash?)");
        }
        previous_was_escape = true;
      } else if (char === quote_char) {
        finish_token();
        next_type = null;
      } else if (char === "\n") {
        whitespace_after = source.slice(i).match(/^\s*/m);
        is_last_newline_before_quote = source[i + whitespace_after.length] === quote_char;
        if (string_first_newline_found || string_first_newline_cannot_be_ignored) {
          if (!is_last_newline_before_quote) {
            current_token_string += char;
          }
        }
        string_first_newline_found = true;
      } else if (char.match(/[\t\ ]/)) {
        match = source.slice(0, i + 1).match(/\n([\t\ ]*)$/);
        if (match != null) {
          string_indent_level = match[1].length;
          if (string_indent_level > indent_level + 1) {
            current_token_string += char;
          }
        } else {
          current_token_string += char;
        }
      } else {
        if (!string_first_newline_found) {
          string_first_newline_cannot_be_ignored = true;
        }
        current_token_string += char;
      }
    } else if (char === "\n") {
      next_type = null;
      if (next_type !== current_type) {
        finish_token();
      }
      current_type = next_type;
      tokens.push(new Token("newline", row, col, "\n"));
      handle_indentation(i, row, col);
    } else {
      if (char.match(/\d/)) {
        next_type = "number";
      } else if (char === ".") {
        if (next_char.match(/\d/)) {
          next_type = "number";
        } else {
          next_type = "punctuation";
        }
      } else if (char === "-") {
        if (next_char.match(/\d/) && !prev_char.match(/\d/)) {
          next_type = "number";
        } else {
          next_type = "punctuation";
        }
      } else if (char === "#") {
        next_type = "comment";
      } else if (char.match(/[,!?@#$%^&*\(\)\[\]\{\}<>\/\|\\\-+=~:;]/)) {
        next_type = "punctuation";
      } else if (char.match(/[a-z]/i)) {
        next_type = "word";
      } else if (char === "'") {
        if (current_type === "word" && next_char.match(/[a-z]/i)) {
          next_type = "word";
        } else {
          start_string(char);
        }
      } else if (char === '"') {
        start_string(char);
      } else if (char.match(/\s/)) {
        next_type = null;
      } else {
        next_type = "unknown";
      }
      if (next_type !== current_type) {
        finish_token();
      } else if (next_type === "punctuation" && current_type === "punctuation") {
        if (!(((prev_char === "?" || prev_char === "!") && (char === "?" || char === "!")) || (prev_char === "." && char === ".") || ((prev_char === "<" || prev_char === ">") && char === "=") || (prev_char === "=" && (char === "<" || char === ">")) || (prev_char === "=" && char === "=") || (prev_char === "!" && char === "="))) {
          finish_token();
        }
      }
      current_type = next_type;
      if (next_type !== "string" && next_type !== "comment") {
        current_token_string += char;
      }
    }
    if (char === "\n") {
      row++;
      col = 1;
    } else {
      col += 1;
    }
  }
  if (current_type === "string") {
    throw new Error("Missing end quote (" + quote_char + ") for string at row " + row + ", column " + col);
  }
  finish_token();
  handle_indentation(i, row, col);
  return tokens;
};


},{"./Token":3}]},{},[4])(4)
});