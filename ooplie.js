(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.Ooplie = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Context, Lexer, Pattern;

Lexer = require("./lex").Lexer;

Pattern = require("./Pattern");

module.exports = Context = (function() {
  function Context(arg) {
    var ref;
    ref = arg != null ? arg : {}, this.console = ref.console, this.supercontext = ref.supercontext;
    this.lexer = new Lexer;
    this.patterns = [
      new Pattern({
        match: ["If <condition>, <actions>", "If <condition> then <actions>", "<actions> if <condition>"],
        fn: (function(_this) {
          return function(arg1) {
            var actions, condition;
            condition = arg1.condition, actions = arg1.actions;
            if (_this.eval_expression(condition)) {
              return _this.eval_expression(actions);
            }
          };
        })(this)
      }), new Pattern({
        match: [],
        fn: (function(_this) {
          return function(condition, actions) {
            if (!condition) {
              return perform(actions);
            }
          };
        })(this)
      }), new Pattern({
        match: ["output <text>", "output <text> to the console", "log <text>", "log <text> to the console", "print <text>", "print <text> to the console", "say <text>"],
        bad_match: ["puts <text>", "println <text>", "print line <text>", "printf <text>", "console.log <text>", "writeln <text>", "output <text> to the terminal", "log <text> to the terminal", "print <text> to the terminal"],
        fn: (function(_this) {
          return function(arg1) {
            var text;
            text = arg1.text;
            _this.console.log(_this.eval_expression(text));
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
            return eval(_this.eval_expression(text));
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

  Context.prototype.eval_expression = function(tokens) {
    var i, last_token, len, str, token;
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
    } else if (tokens.length === 1) {
      token = tokens[0];
      if (token.type === "word") {
        switch (token.value) {
          case "true":
            return true;
          case "false":
            return false;
          default:
            throw new Error("I don't understand the expression `" + (stringify_tokens(tokens)) + "`");
        }
      }
    } else {
      throw new Error("I don't understand the expression `" + (stringify_tokens(tokens)) + "`");
    }
  };

  Context.prototype.interpret = function(text, callback) {
    var handle_expression, handle_line, handle_statement, i, len, line_tokens, ref, result, stringify_tokens, token;
    if (text.match(/^((Well|So|Um|Uh),? )?(Hi|Hello|Hey|Greetings|Hola)/i)) {
      return callback(null, (text.match(/^[A-Z]/) ? "Hello" : "hello") + (text.match(/\.|!/) ? "." : ""));
    } else if (text.match(/^((Well|So|Um|Uh),? )?(What'?s up|Sup)/i)) {
      return callback(null, (text.match(/^[A-Z]/) ? "Not much" : "not much") + (text.match(/\?|!/) ? "." : ""));
    } else if (text.match(/^>?[:;8X][()O3PCD]$/i)) {
      return callback(null, text);
    } else if (text.match(/^(!*\?+!*|(I (want|need) |display|show|view)?help)/i)) {
      return callback(null, "Sorry, I can't help.");
    } else if (text.match(/^(clr|clear)( console| output)?$/i)) {
      if (this.console != null) {
        this.console.clear();
        return callback(null, "Console cleared.");
      } else {
        return callback(new Error("No console to clear."));
      }
    } else {
      result = void 0;
      stringify_tokens = function(tokens) {
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
          } else {
            str += " " + token.value;
          }
        }
        return str.trim();
      };
      handle_expression = (function(_this) {
        return function(tokens) {
          return _this.eval_expression(tokens);
        };
      })(this);
      handle_statement = (function(_this) {
        return function(tokens) {
          var bad_match, i, len, match, pattern, ref;
          bad_match = null;
          ref = _this.patterns;
          for (i = 0, len = ref.length; i < len; i++) {
            pattern = ref[i];
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
            return result = pattern.fn(match);
          } else if (bad_match) {
            throw new Error("For `" + (stringify_tokens(tokens)) + "`, use " + pattern.prefered + " instead");
          } else {
            throw new Error("I don't understand");
          }
        };
      })(this);
      line_tokens = [];
      handle_line = (function(_this) {
        return function() {
          var e, error;
          if (line_tokens.length) {
            try {
              result = handle_statement(line_tokens);
            } catch (error) {
              e = error;
              if (e.message !== "I don't understand") {
                throw e;
              }
              result = handle_expression(line_tokens);
            }
          }
          return line_tokens = [];
        };
      })(this);
      ref = this.lexer.lex(text);
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


},{"./Pattern":2,"./lex":3}],2:[function(require,module,exports){
var Pattern;

module.exports = Pattern = (function() {
  function Pattern(arg) {
    var bad_match, match, parse_matchers;
    match = arg.match, bad_match = arg.bad_match, this.fn = arg.fn;
    parse_matchers = function(matcher_defs) {
      var def, j, len, results, segment, segments;
      results = [];
      for (j = 0, len = matcher_defs.length; j < len; j++) {
        def = matcher_defs[j];
        segments = def.replace(/<([^>]*)(\ )/g, function(m, words, space) {
          return words + "_";
        }).replace(/>\ /g, ">").replace(/>/g, "> ").trim().split(" ");
        results.push((function() {
          var k, len1, results1;
          results1 = [];
          for (k = 0, len1 = segments.length; k < len1; k++) {
            segment = segments[k];
            if (segment.match(/^<.*>$/)) {
              results1.push({
                type: "variable",
                name: segment.replace(/[<>]/g, ""),
                toString: function() {
                  return "<" + this.name + ">";
                }
              });
            } else {
              results1.push({
                type: segment.match(/\w/) ? "word" : "punctuation",
                value: segment,
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
    var current_variable_tokens, i, j, len, matching, token, variables;
    variables = {};
    current_variable_tokens = null;
    i = 0;
    for (j = 0, len = tokens.length; j < len; j++) {
      token = tokens[j];
      matching = matcher[i];
      if (matching.type === "variable") {
        if (current_variable_tokens != null) {
          if (token.type === matcher[i + 1].type && token.value === matcher[i + 1].value) {
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
    if (matching.type === "variable") {
      i += 1;
    }
    if (i === matcher.length) {
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


},{}],3:[function(require,module,exports){
var Lexer, Token;

Lexer = (function() {
  function Lexer() {}

  Lexer.prototype.check_indentation = function(source) {
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

  Lexer.prototype.tokenize = function(source) {
    var char, col, current_token_string, current_type, finish_token, handle_indentation, i, indent_level, is_last_newline_before_quote, j, len, match, next_char, next_type, previous_was_escape, quote_char, ref, row, start_string, string_content_indentation, string_content_on_first_line, string_content_started, string_first_newline_cannot_be_ignored, string_first_newline_found, string_indent_level, tokens, whitespace_after;
    this.check_indentation(source);
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
      next_char = (ref = source[i + 1]) != null ? ref : "";
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
        } else if (char === "." || char === "-") {
          if (next_char.match(/\d/)) {
            next_type = "number";
          } else {
            next_type = "punctuation";
          }
        } else if (char === "#") {
          next_type = "comment";
        } else if (char.match(/[,!?@#$%^&*\(\)\[\]\{\}<>\|\\\-+=~:;]/)) {
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

  Lexer.prototype.lex = function(source) {
    var tokens;
    tokens = this.tokenize(source);
    return tokens;
  };

  return Lexer;

})();

Token = (function() {
  function Token(type, col1, row1, value) {
    this.type = type;
    this.col = col1;
    this.row = row1;
    this.value = value;
  }

  Token.prototype.toString = function() {
    if (this.type === "comment") {
      return "#" + this.value;
    } else {
      return this.value;
    }
  };

  return Token;

})();

module.exports = {
  Lexer: Lexer,
  Token: Token
};


},{}],4:[function(require,module,exports){
var Context, Lexer, Token, ref;

Context = require('./Context');

ref = require('./lex'), Lexer = ref.Lexer, Token = ref.Token;

module.exports = {
  Context: Context,
  Lexer: Lexer,
  Token: Token
};


},{"./Context":1,"./lex":3}]},{},[4])(4)
});