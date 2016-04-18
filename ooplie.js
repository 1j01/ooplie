(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.Ooplie = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Context, Pattern, Token, default_operators, stringify_tokens, tokenize;

tokenize = require("./tokenize");

Pattern = require("./Pattern");

stringify_tokens = (Token = require("./Token")).stringify_tokens;

default_operators = require("./default-operators");

module.exports = Context = (function() {
  function Context(arg) {
    var operator, ref;
    ref = arg != null ? arg : {}, this.console = ref.console, this.supercontext = ref.supercontext;
    this.patterns = [].concat(require("./library/conditionals"), require("./library/console"), require("./library/eval-js"), require("./library/eval-ooplie"));
    this.classes = [];
    this.instances = [];
    this.variables = {};
    this.constants = require("./constants");
    this.operators = (function() {
      var j, len, results;
      results = [];
      for (j = 0, len = default_operators.length; j < len; j++) {
        operator = default_operators[j];
        results.push(operator);
      }
      return results;
    })();
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
    var handle_line, j, len, line_tokens, ref, result, token;
    result = void 0;
    line_tokens = [];
    handle_line = (function(_this) {
      return function() {
        if (line_tokens.length) {
          result = _this.eval_tokens(line_tokens);
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
    return result;
  };

  Context.prototype.eval_tokens = function(tokens) {
    var advance, index, parse_expression, parse_primary, peek;
    index = 0;
    peek = (function(_this) {
      return function() {
        return tokens[index + 1];
      };
    })(this);
    advance = (function(_this) {
      return function(advance_by) {
        if (advance_by == null) {
          advance_by = 1;
        }
        return index += advance_by;
      };
    })(this);
    parse_primary = (function(_this) {
      return function() {
        var bad_match, following_value, get_var_value, i, j, k, l, len, len1, len2, len3, len4, len5, lookahead_index, lookahead_token, m, match, matcher, n, next_literal_tokens, next_tokens, next_word_tok_str, next_word_tokens, o, operator, pattern, ref, ref1, ref2, ref3, result, returns, str, tok_str, token;
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
        tok_str = stringify_tokens(next_tokens);
        next_word_tok_str = stringify_tokens(next_word_tokens);
        ref1 = _this.patterns;
        for (l = 0, len2 = ref1.length; l < len2; l++) {
          pattern = ref1[l];
          match = pattern.match(next_tokens);
          if (match != null) {
            break;
          }
        }
        if (match != null) {
          get_var_value = function(var_name) {
            return _this.eval_tokens(match[var_name]);
          };
          returns = pattern.fn(get_var_value, _this);
          return returns;
        } else {
          ref2 = _this.patterns;
          for (m = 0, len3 = ref2.length; m < len3; m++) {
            pattern = ref2[m];
            bad_match = pattern.bad_match(next_tokens);
            if (bad_match != null) {
              break;
            }
          }
          if (bad_match != null) {
            throw new Error("For `" + tok_str + "`, use " + bad_match.pattern.prefered + " instead");
          }
        }
        if (next_literal_tokens.length) {
          if (next_literal_tokens.some(function(token) {
            return token.type === "string";
          })) {
            str = "";
            for (n = 0, len4 = next_tokens.length; n < len4; n++) {
              token = next_tokens[n];
              str += token.value;
            }
            advance(next_literal_tokens.length);
            return str;
          } else if (next_literal_tokens.length > 1) {
            throw new Error("Consecutive numbers, " + next_literal_tokens[0].value + " and " + next_literal_tokens[1].value);
          } else {
            return next_literal_tokens[0].value;
          }
        } else {
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
          if (token.type === "punctuation" && token.value === "(") {
            lookahead_index = index;
            while (true) {
              lookahead_index += 1;
              lookahead_token = tokens[lookahead_index];
              if (lookahead_token != null) {
                if (lookahead_token.type === "punctuation" && lookahead_token.value === ")") {
                  result = _this.eval_tokens(tokens.slice(index + 1, lookahead_index));
                  advance(lookahead_index);
                  return result;
                }
              } else {
                throw new Error("Missing ending parenthesis in `" + tok_str + "`");
              }
            }
          }
          ref3 = _this.operators;
          for (o = 0, len5 = ref3.length; o < len5; o++) {
            operator = ref3[o];
            if (!operator.unary) {
              continue;
            }
            matcher = operator.match(tokens, index);
            if (matcher) {
              advance(matcher.length);
              following_value = parse_primary();
              return operator.fn(following_value);
            }
          }
          throw new Error("I don't understand `" + tok_str + "`");
        }
      };
    })(this);
    parse_expression = (function(_this) {
      return function(lhs, min_precedence) {
        var lookahead_operator, match_operator, operator, rhs;
        match_operator = function() {
          var j, len, matcher, operator, ref;
          ref = _this.operators;
          for (j = 0, len = ref.length; j < len; j++) {
            operator = ref[j];
            matcher = operator.match(tokens, index);
            if (matcher != null) {
              advance(matcher.length);
              return operator;
            }
          }
        };
        advance();
        lookahead_operator = match_operator();
        while ((lookahead_operator != null ? lookahead_operator.binary : void 0) && lookahead_operator.precedence >= min_precedence) {
          operator = lookahead_operator;
          if (lookahead_operator.binary && (tokens[index] == null)) {
            throw new Error("binary operator at end of expression");
          }
          rhs = parse_primary();
          advance();
          lookahead_operator = match_operator();
          while (((lookahead_operator != null ? lookahead_operator.binary : void 0) && lookahead_operator.precedence > operator.precedence) || ((lookahead_operator != null ? lookahead_operator.right_associative : void 0) && lookahead_operator.precedence === operator.precedence)) {
            if (lookahead_operator.binary && (tokens[index] == null)) {
              throw new Error("binary operator at end of expression");
            }
            advance(-2);
            rhs = parse_expression(rhs, lookahead_operator.precedence);
            advance(2);
            lookahead_operator = match_operator();
          }
          lhs = operator.fn(lhs, rhs);
        }
        if (lookahead_operator != null ? lookahead_operator.unary : void 0) {
          throw new Error("unary operator at end of expression?");
        }
        return lhs;
      };
    })(this);
    return parse_expression(parse_primary(), 0);
  };

  return Context;

})();


},{"./Pattern":3,"./Token":4,"./constants":5,"./default-operators":6,"./library/conditionals":7,"./library/console":8,"./library/eval-js":9,"./library/eval-ooplie":10,"./tokenize":12}],2:[function(require,module,exports){
var Operator, Pattern,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Pattern = require("./Pattern");

module.exports = Operator = (function(superClass) {
  extend(Operator, superClass);

  function Operator(arg) {
    var binary, right_associative, unary;
    this.precedence = arg.precedence, right_associative = arg.right_associative, binary = arg.binary, unary = arg.unary;
    Operator.__super__.constructor.apply(this, arguments);
    if (this.precedence == null) {
      throw new Error("Operator constructor requires {precedence}");
    }
    this.right_associative = right_associative != null ? right_associative : false;
    if (binary != null) {
      this.unary = !binary;
      this.binary = !this.unary;
    } else {
      this.binary = !unary;
      this.unary = !this.binary;
    }
    if (this.unary && !this.right_associative) {
      throw new Error("Non-right-associative unary operators are probably not supported");
    }
  }

  Operator.prototype.match = function(tokens, index) {
    var i, j, len, len1, matcher, matching, ref, segment, segment_index, token;
    ref = this.matchers;
    for (i = 0, len = ref.length; i < len; i++) {
      matcher = ref[i];
      matching = true;
      for (segment_index = j = 0, len1 = matcher.length; j < len1; segment_index = ++j) {
        segment = matcher[segment_index];
        token = tokens[index + segment_index];
        matching = (token != null ? token.type : void 0) === segment.type && (token != null ? token.value : void 0) === segment.value;
        if (!matching) {
          break;
        }
      }
      if (matching) {
        return matcher;
      }
    }
  };

  Operator.prototype.bad_match = function() {
    throw new Error("Not implemented!");
  };

  return Operator;

})(Pattern);


},{"./Pattern":3}],3:[function(require,module,exports){
var Pattern, stringify_matcher, stringify_tokens, tokenize,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

tokenize = require("./tokenize");

stringify_tokens = require("./Token").stringify_tokens;

stringify_matcher = function(matcher) {
  return matcher.join(" ");
};

module.exports = Pattern = (function() {
  function Pattern(arg) {
    var bad_match, match, parse_matchers;
    match = arg.match, bad_match = arg.bad_match, this.fn = arg.fn;
    parse_matchers = function(matcher_defs) {
      var current_variable_name, def, index, j, k, len, len1, ref, results, segments, token, tokens, variable_names_used;
      results = [];
      for (j = 0, len = matcher_defs.length; j < len; j++) {
        def = matcher_defs[j];
        tokens = tokenize(def);
        segments = [];
        variable_names_used = [];
        current_variable_name = null;
        for (index = k = 0, len1 = tokens.length; k < len1; index = ++k) {
          token = tokens[index];
          if (token.type === "punctuation") {
            if (token.value === "<") {
              if (current_variable_name != null) {
                throw new Error("Unexpected `<` within variable name in pattern `" + def + "`");
              } else if (((ref = tokens[index + 1]) != null ? ref.type : void 0) === "word") {
                current_variable_name = "";
              } else {
                segments.push({
                  type: token.type,
                  value: token.value,
                  toString: function() {
                    return this.value;
                  }
                });
              }
            } else if (token.value === ">") {
              if (current_variable_name != null) {
                if (indexOf.call(variable_names_used, current_variable_name) >= 0) {
                  throw new Error("Variable name `" + current_variable_name + "` used twice in pattern `" + def + "`");
                }
                if (current_variable_name === "pattern") {
                  throw new Error("Reserved pattern variable `pattern` used in pattern `" + def + "`");
                }
                variable_names_used.push(current_variable_name);
                segments.push({
                  type: "variable",
                  name: current_variable_name,
                  toString: function() {
                    return "<" + this.name + ">";
                  }
                });
                current_variable_name = null;
              } else {
                segments.push({
                  type: token.type,
                  value: token.value,
                  toString: function() {
                    return this.value;
                  }
                });
              }
            } else if (current_variable_name != null) {
              current_variable_name += token.value;
            } else {
              segments.push({
                type: token.type,
                value: token.value,
                toString: function() {
                  return this.value;
                }
              });
            }
          } else {
            if (current_variable_name != null) {
              if (current_variable_name.slice(-1).match(/[a-z]/i)) {
                current_variable_name += " ";
              }
              current_variable_name += token.value;
            } else {
              segments.push({
                type: token.type,
                value: token.value,
                toString: function() {
                  return this.value;
                }
              });
            }
          }
        }
        results.push(segments);
      }
      return results;
    };
    this.matchers = parse_matchers(match);
    this.bad_matchers = parse_matchers(bad_match != null ? bad_match : []);
    this.prefered = match[0];
  }

  Pattern.prototype.match_with = function(tokens, matcher) {
    var current_variable_tokens, i, j, len, next_segment, segment, token, token_matches, variables;
    variables = {};
    current_variable_tokens = null;
    token_matches = function(token, segment) {
      return (token != null ? token.type : void 0) === segment.type && token.value.toLowerCase() === segment.value.toLowerCase();
    };
    i = 0;
    for (j = 0, len = tokens.length; j < len; j++) {
      token = tokens[j];
      if (i >= matcher.length) {
        return;
      }
      segment = matcher[i];
      if (segment.type === "variable") {
        if (current_variable_tokens != null) {
          next_segment = matcher[i + 1];
          if ((next_segment != null) && token_matches(token, next_segment)) {
            current_variable_tokens = null;
            i += 2;
          } else {
            current_variable_tokens.push(token);
          }
        } else {
          current_variable_tokens = [];
          variables[segment.name] = current_variable_tokens;
          current_variable_tokens.push(token);
        }
      } else {
        current_variable_tokens = null;
        if (token_matches(token, segment)) {
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
    } else {

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


},{"./Token":4,"./tokenize":12}],4:[function(require,module,exports){
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


},{}],5:[function(require,module,exports){
module.exports = {
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
  "Pythagoras's constant": Math.SQRT2,
  "Archimedes' constant": Math.PI
};


},{}],6:[function(require,module,exports){
var Operator;

Operator = require("./Operator");

module.exports = [
  new Operator({
    match: ["^", "to the power of"],
    bad_match: ["**"],
    precedence: 3,
    right_associative: true,
    fn: function(lhs, rhs) {
      return Math.pow(lhs, rhs);
    }
  }), new Operator({
    match: ["×", "*", "times"],
    bad_match: ["✖", "⨉", "⨯", "∗", "⋅", "∙", "•", "✗", "✘"],
    precedence: 2,
    fn: function(lhs, rhs) {
      return lhs * rhs;
    }
  }), new Operator({
    match: ["÷", "/", "∕", "divided by"],
    bad_match: ["／", "⁄"],
    precedence: 2,
    fn: function(lhs, rhs) {
      return lhs / rhs;
    }
  }), new Operator({
    match: ["+", "plus"],
    bad_match: ["＋", "﬩"],
    precedence: 1,
    fn: function(lhs, rhs) {
      return lhs + rhs;
    }
  }), new Operator({
    match: ["−", "-", "minus"],
    precedence: 1,
    fn: function(lhs, rhs) {
      return lhs - rhs;
    }
  }), new Operator({
    match: ["−", "-", "negative", "the opposite of"],
    bad_match: ["minus"],
    precedence: 1,
    right_associative: true,
    unary: true,
    fn: function(rhs) {
      return -rhs;
    }
  }), new Operator({
    match: ["+", "positive"],
    bad_match: ["plus"],
    precedence: 1,
    right_associative: true,
    unary: true,
    fn: function(rhs) {
      return +rhs;
    }
  }), new Operator({
    match: ["≥", ">=", "is greater than or equal to"],
    bad_match: ["is more than or equal to"],
    precedence: 0,
    fn: function(lhs, rhs) {
      return lhs >= rhs;
    }
  }), new Operator({
    match: ["≤", "<=", "is less than or equal to"],
    precedence: 0,
    fn: function(lhs, rhs) {
      return lhs <= rhs;
    }
  }), new Operator({
    match: [">", "is greater than"],
    bad_match: ["is more than"],
    precedence: 0,
    fn: function(lhs, rhs) {
      return lhs > rhs;
    }
  }), new Operator({
    match: ["<", "is less than"],
    precedence: 0,
    fn: function(lhs, rhs) {
      return lhs < rhs;
    }
  }), new Operator({
    match: ["≠", "!=", "does not equal", "is not equal to", "isn't", "is not"],
    bad_match: ["isnt", "isnt equal to", "isn't equal to"],
    precedence: 0,
    fn: function(lhs, rhs) {
      return lhs !== rhs;
    }
  }), new Operator({
    match: ["=", "equals", "is equal to", "is"],
    bad_match: ["==", "==="],
    precedence: 0,
    fn: function(lhs, rhs) {
      return lhs === rhs;
    }
  })
];


},{"./Operator":2}],7:[function(require,module,exports){
var Pattern;

Pattern = require("../Pattern");

module.exports = [
  new Pattern({
    match: ["If <condition>, <body>, else <alt body>", "If <condition> then <body>, else <alt body>", "If <condition> then <body> else <alt body>", "<body> if <condition> else <alt body>"],
    bad_match: ["if <condition>, then <body>, else <alt body>", "if <condition>, then <body>, else, <alt body>", "if <condition>, <body>, else, <alt body>", "<condition> ? <body> : <alt body>", "unless <condition>, <alt body> else <body>", "unless <condition>, <alt body>, else <body>", "unless <condition> then <alt body>, else <body>", "unless <condition> then <alt body>, else, <body>", "unless <condition>, then <alt body>, else <body>", "unless <condition>, then <alt body>, else, <body>"],
    fn: (function(_this) {
      return function(v) {
        if (v("condition")) {
          return v("body");
        } else {
          return v("alt body");
        }
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
    match: ["<body> unless <condition> in which case <alt body>", "<body>, unless <condition> in which case <alt body>", "<body> unless <condition>, in which case <alt body>", "<body>, unless <condition>, in which case <alt body>", "<body> unless <condition> in which case just <alt body>", "<body>, unless <condition> in which case just <alt body>", "<body> unless <condition>, in which case just <alt body>", "<body>, unless <condition>, in which case just <alt body>"],
    bad_match: ["Unless <condition>, <body>, else <alt body>", "Unless <condition> then <body>, else <alt body>", "Unless <condition> then <body> else <alt body>", "<body> unless <condition> else <alt body>"],
    fn: (function(_this) {
      return function(v) {
        if (!v("condition")) {
          return v("body");
        } else {
          return v("alt body");
        }
      };
    })(this)
  }), new Pattern({
    match: ["Unless <condition>, <body>", "<body> unless <condition>"],
    bad_match: ["Unless <condition> then <body>"],
    fn: (function(_this) {
      return function(v) {
        if (!v("condition")) {
          return v("body");
        }
      };
    })(this)
  })
];


},{"../Pattern":3}],8:[function(require,module,exports){
var Pattern;

Pattern = require("../Pattern");

module.exports = [
  new Pattern({
    match: ["output <text>", "output <text> to the console", "log <text>", "log <text> to the console", "print <text>", "print <text> to the console", "say <text>"],
    bad_match: ["puts <text>", "println <text>", "print line <text>", "printf <text>", "console.log <text>", "writeln <text>", "output <text> to the terminal", "log <text> to the terminal", "print <text> to the terminal"],
    fn: (function(_this) {
      return function(v, context) {
        context.console.log(v("text"));
      };
    })(this)
  }), new Pattern({
    match: ["clear the console", "clear console"],
    bad_match: ["clear the terminal", "clear terminal", "cls", "clr"],
    fn: (function(_this) {
      return function(v, context) {
        context.console.clear();
      };
    })(this)
  })
];


},{"../Pattern":3}],9:[function(require,module,exports){
var Pattern;

Pattern = require("../Pattern");

module.exports = [
  new Pattern({
    match: ["run JS <text>", "run JavaScript <text>", "run <text> as JS", "run <text> as JavaScript", "execute JS <text>", "execute JavaScript <text>", "execute <text> as JS", "execute <text> as JavaScript", "eval JS <text>", "eval JavaScript <text>", "eval <text> as JS", "eval <text> as JavaScript"],
    bad_match: ["eval <text>", "execute <text>", "JavaScript <text>", "JS <text>"],
    fn: (function(_this) {
      return function(v, context) {
        var console;
        console = context.console;
        return eval(v("text"));
      };
    })(this)
  })
];


},{"../Pattern":3}],10:[function(require,module,exports){
var Pattern;

Pattern = require("../Pattern");

module.exports = [
  new Pattern({
    match: ["run code <text> with Ooplie", "eval code <text> with Ooplie", "execute code <text> with Ooplie", "interpret code <text> with Ooplie", "interpret <text> as English", "run <text> as English", "execute <text> as English", "eval <text> as English", "interpret <text> as Ooplie code", "run <text> as Ooplie code", "execute <text> as Ooplie code", "eval <text> as Ooplie code", "run Ooplie code <text>", "eval Ooplie code <text>", "execute Ooplie code <text>", "interpret Ooplie code <text>", "run English <text>", "eval English <text>", "execute English <text>", "run <text> with Ooplie", "eval <text> with Ooplie", "execute <text> with Ooplie", "interpret <text> with Ooplie"],
    bad_match: ["run Ooplie <text>", "eval Ooplie <text>", "execute Ooplie <text>", "interpret Ooplie <text>", "run <text> as Ooplie", "run code <text> as Ooplie", "execute <text> as Ooplie", "execute <text> as Ooplie", "eval <text> as Ooplie", "eval code <text> as Ooplie", "run code <text> as English", "run English code <text>", "eval English code <text>", "execute English code <text>", "interpret English code <text>", "run English code <text>", "eval <text> as English code", "execute English code <text>", "interpret <text> as English code", "make Ooplie interpret <text>", "have Ooplie interpret <text>", "let Ooplie interpret <text>"],
    fn: (function(_this) {
      return function(v, context) {
        return context["eval"](v("text"));
      };
    })(this)
  })
];


},{"../Pattern":3}],11:[function(require,module,exports){
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


},{"./Context":1,"./Pattern":3,"./Token":4,"./tokenize":12}],12:[function(require,module,exports){
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


},{"./Token":4}]},{},[11])(11)
});