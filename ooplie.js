(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.Ooplie = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Context, Pattern, Token, stringify_tokens, tokenize;

tokenize = require("./tokenize");

Pattern = require("./Pattern");

stringify_tokens = (Token = require("./Token")).stringify_tokens;

module.exports = Context = (function() {
  function Context(arg) {
    var ref;
    ref = arg != null ? arg : {}, this.console = ref.console, this.supercontext = ref.supercontext;
    this.patterns = [
      new Pattern({
        match: ["output <text>", "output <text> to the console", "log <text>", "log <text> to the console", "print <text>", "print <text> to the console", "say <text>"],
        bad_match: ["puts <text>", "println <text>", "print line <text>", "printf <text>", "console.log <text>", "writeln <text>", "output <text> to the terminal", "log <text> to the terminal", "print <text> to the terminal"],
        fn: (function(_this) {
          return function(v) {
            _this.console.log(v("text"));
          };
        })(this)
      }), new Pattern({
        match: ["run JS <text>", "run JavaScript <text>", "run <text> as JS", "run <text> as JavaScript", "execute JS <text>", "execute JavaScript <text>", "execute <text> as JS", "execute <text> as JavaScript", "eval JS <text>", "eval JavaScript <text>", "eval <text> as JS", "eval <text> as JavaScript"],
        bad_match: ["eval <text>", "execute <text>", "JavaScript <text>", "JS <text>"],
        fn: (function(_this) {
          return function(v) {
            var console;
            console = _this.console;
            return eval(v("text"));
          };
        })(this)
      }), new Pattern({
        match: ["<a> ^ <b>", "<a> to the power of <b>"],
        bad_match: ["<a> ** <b>"],
        fn: (function(_this) {
          return function(v) {
            return Math.pow(v("a"), v("b"));
          };
        })(this)
      }), new Pattern({
        match: ["<a> × <b>", "<a> * <b>", "<a> times <b>"],
        bad_match: ["<a> ✖ <b>", "<a> ⨉ <b>", "<a> ⨯ <b>", "<a> ∗ <b>", "<a> ⋅ <b>", "<a> ∙ <b>", "<a> • <b>", "<a> ✗ <b>", "<a> ✘ <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") * v("b");
          };
        })(this)
      }), new Pattern({
        match: ["<a> ÷ <b>", "<a> / <b>", "<a> ∕ <b>", "<a> divided by <b>"],
        bad_match: ["<a> ／ <b>", "<a> ⁄ <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") / v("b");
          };
        })(this)
      }), new Pattern({
        match: ["<a> + <b>", "<a> plus <b>"],
        bad_match: ["<a> ＋ <b>", "<a> ﬩ <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") + v("b");
          };
        })(this)
      }), new Pattern({
        match: ["<a> − <b>", "<a> - <b>", "<a> minus <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") - v("b");
          };
        })(this)
      }), new Pattern({
        match: ["− <b>", "- <b>", "negative <b>", "the opposite of <b>"],
        bad_match: ["minus <b>"],
        fn: (function(_this) {
          return function(v) {
            return -v("b");
          };
        })(this)
      }), new Pattern({
        match: ["+ <b>", "positive <b>"],
        bad_match: ["plus <b>"],
        fn: (function(_this) {
          return function(v) {
            return +v("b");
          };
        })(this)
      }), new Pattern({
        match: ["<a> = <b>", "<a> equals <b>", "<a> is equal to <b>", "<a> is <b>"],
        bad_match: ["<a> == <b>", "<a> === <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") === v("b");
          };
        })(this)
      }), new Pattern({
        match: ["<a> ≠ <b>", "<a> != <b>", "<a> does not equal <b>", "<a> is not equal to <b>", "<a> isn't <b>"],
        bad_match: ["<a> isnt <b>", "<a> isnt equal to <b>", "<a> isn't equal to <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") !== v("b");
          };
        })(this)
      }), new Pattern({
        match: ["<a> > <b>", "<a> is greater than <b>"],
        bad_match: ["<a> is more than <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") > v("b");
          };
        })(this)
      }), new Pattern({
        match: ["<a> < <b>", "<a> is less than <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") < v("b");
          };
        })(this)
      }), new Pattern({
        match: ["<a> ≥ <b>", "<a> >= <b>", "<a> is greater than or equal to <b>"],
        bad_match: ["<a> is more than or equal to <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") >= v("b");
          };
        })(this)
      }), new Pattern({
        match: ["<a> ≤ <b>", "<a> <= <b>", "<a> is less than or equal to <b>"],
        fn: (function(_this) {
          return function(v) {
            return v("a") <= v("b");
          };
        })(this)
      }), new Pattern({
        match: ["If <condition>, <body>", "If <condition> then <body>", "<body> if <condition>"],
        fn: (function(_this) {
          return function(v) {
            if (v("condition")) {
              return v("body");
            }
          };
        })(this)
      }), new Pattern({
        match: ["Unless <condition>, <body>", "Unless <condition> then <body>", "<body> unless <condition>"],
        fn: (function(_this) {
          return function(v) {
            if (!v("condition")) {
              return v("body");
            }
          };
        })(this)
      }), new Pattern({
        match: ["If <condition>, <body>, else <alt_body>", "If <condition> then <body>, else <alt_body>", "If <condition> then <body> else <alt_body>", "<body> if <condition> else <alt_body>"],
        bad_match: ["if <condition>, then <body>, else <alt_body>", "if <condition>, then <body>, else, <alt_body>", "if <condition>, <body>, else, <alt_body>"],
        fn: (function(_this) {
          return function(v) {
            if (v("condition")) {
              return v("body");
            } else {
              return v("alt_body");
            }
          };
        })(this)
      })
    ];
    this.classes = [];
    this.objects = [];
    this.variables = {};
    this.constants = {
      "true": true,
      "yes": true,
      "on": true,
      "false": false,
      "no": false,
      "off": false,
      "null": null,
      "infinity": Infinity,
      "∞": Infinity,
      "pi": Math.PI,
      "π": Math.PI,
      "tau": Math.PI * 2,
      "τ": Math.PI * 2,
      "e": Math.E,
      "the golden ratio": (1 + Math.sqrt(5)) / 2,
      "phi": (1 + Math.sqrt(5)) / 2,
      "φ": (1 + Math.sqrt(5)) / 2,
      "Pythagoras's constant": Math.SQRT2
    };
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
    var advance, apply_operator, index, is_binary_operator, is_right_associative_operator, is_unary_operator, parse_expression, parse_primary, peek, precedence_of;
    index = 0;
    peek = function() {
      return tokens[index + 1];
    };
    advance = function() {
      return index += 1;
    };
    parse_primary = (function(_this) {
      return function() {
        var bad_match, i, j, k, l, len, len1, len2, m, match, n, next_literal_tokens, next_tokens, next_word_tok_str, next_word_tokens, pattern, ref, ref1, ref2, ref3, str, tok_str, token;
        next_tokens = tokens.slice(index);
        if (next_tokens.length === 0) {
          return;
        }
        next_literal_tokens = [];
        for (i = j = 0, len = next_tokens.length; j < len; i = ++j) {
          token = next_tokens[i];
          if ((ref = token.type) === "string" || ref === "number") {
            next_literal_tokens.push(token);
          } else {
            break;
          }
        }
        next_word_tokens = [];
        for (i = k = 0, len1 = next_tokens.length; k < len1; i = ++k) {
          token = next_tokens[i];
          if (token.type === "word") {
            next_word_tokens.push(token);
          } else {
            break;
          }
        }
        if (next_literal_tokens.length) {
          if (next_literal_tokens.some(function(token) {
            return token.type === "string";
          })) {
            str = "";
            for (l = 0, len2 = next_tokens.length; l < len2; l++) {
              token = next_tokens[l];
              str += token.value;
            }
            index += next_literal_tokens.length;
            return str;
          } else if (next_literal_tokens.length > 1) {
            throw new Error("Consecutive numbers, " + next_literal_tokens[0].value + " and " + next_literal_tokens[1].value);
          } else {
            return next_literal_tokens[0].value;
          }
        } else {
          tok_str = stringify_tokens(next_tokens);
          next_word_tok_str = stringify_tokens(next_word_tokens);
          if (next_word_tokens.length) {
            if (next_word_tok_str in _this.constants) {
              return _this.constants[next_word_tok_str];
            }
            if (next_word_tok_str in _this.variables) {
              return _this.variables[next_word_tok_str];
            }
          } else {
            if (tok_str in _this.constants) {
              return _this.constants[tok_str];
            }
            if (tok_str in _this.variables) {
              return _this.variables[tok_str];
            }
          }
          token = tokens[index];
          if (token.type === "punctuation" && ((ref1 = token.value) === "+" || ref1 === "-")) {
            advance();
            if (token.value === "-") {
              return -parse_primary();
            } else {
              return +parse_primary();
            }
          }
          ref2 = _this.patterns;
          for (m = ref2.length - 1; m >= 0; m += -1) {
            pattern = ref2[m];
            match = pattern.match(next_tokens);
            if (match != null) {
              break;
            }
          }
          if (match != null) {
            return pattern.fn(function(var_name) {
              return _this.eval_tokens(match[var_name]);
            });
          } else {
            ref3 = _this.patterns;
            for (n = ref3.length - 1; n >= 0; n += -1) {
              pattern = ref3[n];
              bad_match = pattern.bad_match(next_tokens);
              if (bad_match != null) {
                break;
              }
            }
            if (bad_match != null) {
              throw new Error("For `" + tok_str + "`, use " + bad_match.pattern.prefered + " instead");
            } else {
              throw new Error("I don't understand `" + tok_str + "`");
            }
          }
        }
      };
    })(this);
    is_unary_operator = function(token) {
      var ref;
      if (token == null) {
        return false;
      }
      return token.type === "punctuation" && ((ref = token.value) === "+" || ref === "-") && is_binary_operator(tokens[tokens.indexOf(token) - 1]);
    };
    is_binary_operator = function(token) {
      var ref;
      if (token == null) {
        return false;
      }
      return token.type === "punctuation" && ((ref = token.value) === "*" || ref === "/" || ref === "+" || ref === "-" || ref === "^" || ref === "=" || ref === "!=" || ref === "<=" || ref === ">=" || ref === "<" || ref === ">") && !is_binary_operator(tokens[tokens.indexOf(token) - 1]);
    };
    is_right_associative_operator = function(token) {
      if (token == null) {
        return false;
      }
      return token.type === "punctuation" && ((token.value === "^") || is_unary_operator(token));
    };
    precedence_of = function(token) {
      if (is_unary_operator(token)) {
        return 1;
      } else {
        switch (token.value) {
          case "^":
            return 3;
          case "*":
          case "/":
            return 2;
          case "+":
          case "-":
            return 1;
          case "=":
          case "!=":
          case "<=":
          case ">=":
          case "<":
          case ">":
            return 0;
          default:
            return 0;
        }
      }
    };
    apply_operator = function(op_token, lhs, rhs) {
      console.log("apply_operator", lhs, op_token.value, rhs, tokens);
      if (isNaN(lhs)) {
        throw new Error("Non-number " + lhs + " as left-hand-side of " + op_token.value);
      }
      if (isNaN(rhs)) {
        throw new Error("Non-number " + rhs + " as right-hand-side of " + op_token.value);
      }
      if (is_unary_operator(op_token)) {
        switch (op_token.value) {
          case "+":
            return +rhs;
          case "-":
            return -rhs;
          default:
            throw new Error("Unknown unary operator (for now at least): " + op_token.value);
        }
      } else {
        switch (op_token.value) {
          case "^":
            return Math.pow(lhs, rhs);
          case "*":
            return lhs * rhs;
          case "/":
            return lhs / rhs;
          case "+":
            return lhs + rhs;
          case "-":
            return lhs - rhs;
          case "=":
            return lhs === rhs;
          case "!=":
            return lhs !== rhs;
          case "<=":
            return lhs <= rhs;
          case ">=":
            return lhs >= rhs;
          case "<":
            return lhs < rhs;
          case ">":
            return lhs > rhs;
          default:
            throw new Error("Unknown binary operator (for now at least): " + op_token.value);
        }
      }
    };
    parse_expression = function(lhs, min_precedence) {
      var lookahead, op, rhs;
      lookahead = peek();
      while (is_binary_operator(lookahead) && precedence_of(lookahead) >= min_precedence) {
        op = lookahead;
        advance();
        advance();
        rhs = parse_primary();
        lookahead = peek();
        while ((is_binary_operator(lookahead) && precedence_of(lookahead) > precedence_of(op)) || (is_right_associative_operator(lookahead) && precedence_of(lookahead) === precedence_of(op))) {
          rhs = parse_expression(rhs, precedence_of(lookahead));
          lookahead = peek();
        }
        lhs = apply_operator(op, lhs, rhs);
      }
      return lhs;
    };
    return parse_expression(parse_primary(), 0);
  };

  Context.prototype.interpret = function(text, callback) {
    var handle_line, j, len, line_tokens, ref, result, token;
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
      for (j = 0, len = ref.length; j < len; j++) {
        token = ref[j];
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
    var j, len, match, matcher, ref;
    ref = this.matchers;
    for (j = 0, len = ref.length; j < len; j++) {
      matcher = ref[j];
      match = this.match_with(tokens, matcher);
      if (match != null) {
        return match;
      }
    }
  };

  Pattern.prototype.bad_match = function(tokens) {
    var j, len, match, matcher, ref;
    ref = this.bad_matchers;
    for (j = 0, len = ref.length; j < len; j++) {
      matcher = ref[j];
      match = this.match_with(tokens, matcher);
      if (match != null) {
        return match;
      }
    }
  };

  Pattern.prototype.match_near = function() {};

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
      } else if (char === "#") {
        next_type = "comment";
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
        next_type = "punctuation";
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