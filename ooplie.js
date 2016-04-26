(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.Ooplie = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){

},{}],2:[function(require,module,exports){
(function (process){
// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)
function normalizeArray(parts, allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var up = 0;
  for (var i = parts.length - 1; i >= 0; i--) {
    var last = parts[i];
    if (last === '.') {
      parts.splice(i, 1);
    } else if (last === '..') {
      parts.splice(i, 1);
      up++;
    } else if (up) {
      parts.splice(i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up--; up) {
      parts.unshift('..');
    }
  }

  return parts;
}

// Split a filename into [root, dir, basename, ext], unix version
// 'root' is just a slash, or nothing.
var splitPathRe =
    /^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/;
var splitPath = function(filename) {
  return splitPathRe.exec(filename).slice(1);
};

// path.resolve([from ...], to)
// posix version
exports.resolve = function() {
  var resolvedPath = '',
      resolvedAbsolute = false;

  for (var i = arguments.length - 1; i >= -1 && !resolvedAbsolute; i--) {
    var path = (i >= 0) ? arguments[i] : process.cwd();

    // Skip empty and invalid entries
    if (typeof path !== 'string') {
      throw new TypeError('Arguments to path.resolve must be strings');
    } else if (!path) {
      continue;
    }

    resolvedPath = path + '/' + resolvedPath;
    resolvedAbsolute = path.charAt(0) === '/';
  }

  // At this point the path should be resolved to a full absolute path, but
  // handle relative paths to be safe (might happen when process.cwd() fails)

  // Normalize the path
  resolvedPath = normalizeArray(filter(resolvedPath.split('/'), function(p) {
    return !!p;
  }), !resolvedAbsolute).join('/');

  return ((resolvedAbsolute ? '/' : '') + resolvedPath) || '.';
};

// path.normalize(path)
// posix version
exports.normalize = function(path) {
  var isAbsolute = exports.isAbsolute(path),
      trailingSlash = substr(path, -1) === '/';

  // Normalize the path
  path = normalizeArray(filter(path.split('/'), function(p) {
    return !!p;
  }), !isAbsolute).join('/');

  if (!path && !isAbsolute) {
    path = '.';
  }
  if (path && trailingSlash) {
    path += '/';
  }

  return (isAbsolute ? '/' : '') + path;
};

// posix version
exports.isAbsolute = function(path) {
  return path.charAt(0) === '/';
};

// posix version
exports.join = function() {
  var paths = Array.prototype.slice.call(arguments, 0);
  return exports.normalize(filter(paths, function(p, index) {
    if (typeof p !== 'string') {
      throw new TypeError('Arguments to path.join must be strings');
    }
    return p;
  }).join('/'));
};


// path.relative(from, to)
// posix version
exports.relative = function(from, to) {
  from = exports.resolve(from).substr(1);
  to = exports.resolve(to).substr(1);

  function trim(arr) {
    var start = 0;
    for (; start < arr.length; start++) {
      if (arr[start] !== '') break;
    }

    var end = arr.length - 1;
    for (; end >= 0; end--) {
      if (arr[end] !== '') break;
    }

    if (start > end) return [];
    return arr.slice(start, end - start + 1);
  }

  var fromParts = trim(from.split('/'));
  var toParts = trim(to.split('/'));

  var length = Math.min(fromParts.length, toParts.length);
  var samePartsLength = length;
  for (var i = 0; i < length; i++) {
    if (fromParts[i] !== toParts[i]) {
      samePartsLength = i;
      break;
    }
  }

  var outputParts = [];
  for (var i = samePartsLength; i < fromParts.length; i++) {
    outputParts.push('..');
  }

  outputParts = outputParts.concat(toParts.slice(samePartsLength));

  return outputParts.join('/');
};

exports.sep = '/';
exports.delimiter = ':';

exports.dirname = function(path) {
  var result = splitPath(path),
      root = result[0],
      dir = result[1];

  if (!root && !dir) {
    // No dirname whatsoever
    return '.';
  }

  if (dir) {
    // It has a dirname, strip trailing slash
    dir = dir.substr(0, dir.length - 1);
  }

  return root + dir;
};


exports.basename = function(path, ext) {
  var f = splitPath(path)[2];
  // TODO: make this comparison case-insensitive on windows?
  if (ext && f.substr(-1 * ext.length) === ext) {
    f = f.substr(0, f.length - ext.length);
  }
  return f;
};


exports.extname = function(path) {
  return splitPath(path)[3];
};

function filter (xs, f) {
    if (xs.filter) return xs.filter(f);
    var res = [];
    for (var i = 0; i < xs.length; i++) {
        if (f(xs[i], i, xs)) res.push(xs[i]);
    }
    return res;
}

// String.prototype.substr - negative index don't work in IE8
var substr = 'ab'.substr(-1) === 'b'
    ? function (str, start, len) { return str.substr(start, len) }
    : function (str, start, len) {
        if (start < 0) start = str.length + start;
        return str.substr(start, len);
    }
;

}).call(this,require('_process'))
},{"_process":3}],3:[function(require,module,exports){
// shim for using process in browser

var process = module.exports = {};
var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    draining = false;
    if (currentQueue.length) {
        queue = currentQueue.concat(queue);
    } else {
        queueIndex = -1;
    }
    if (queue.length) {
        drainQueue();
    }
}

function drainQueue() {
    if (draining) {
        return;
    }
    var timeout = setTimeout(cleanUpNextTick);
    draining = true;

    var len = queue.length;
    while(len) {
        currentQueue = queue;
        queue = [];
        while (++queueIndex < len) {
            if (currentQueue) {
                currentQueue[queueIndex].run();
            }
        }
        queueIndex = -1;
        len = queue.length;
    }
    currentQueue = null;
    draining = false;
    clearTimeout(timeout);
}

process.nextTick = function (fun) {
    var args = new Array(arguments.length - 1);
    if (arguments.length > 1) {
        for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
        }
    }
    queue.push(new Item(fun, args));
    if (queue.length === 1 && !draining) {
        setTimeout(drainQueue, 0);
    }
};

// v8 likes predictible objects
function Item(fun, array) {
    this.fun = fun;
    this.array = array;
}
Item.prototype.run = function () {
    this.fun.apply(null, this.array);
};
process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function() { return 0; };

},{}],4:[function(require,module,exports){
var Context, Pattern, Token, find_closing_token, stringify_tokens, tokenize;

tokenize = require("./tokenize");

Pattern = require("./Pattern");

stringify_tokens = (Token = require("./Token")).stringify_tokens;

find_closing_token = require("./find-closing-token");

module.exports = Context = (function() {
  function Context(arg) {
    var ref;
    ref = arg != null ? arg : {}, this.console = ref.console, this.supercontext = ref.supercontext;
    this.libraries = [require("./library/operators"), require("./library/constants"), require("./library/conditionals"), require("./library/console"), require("./library/eval-js"), require("./library/eval-ooplie")];
    if (!((typeof window !== "undefined" && window !== null) && (window.require == null))) {
      this.libraries = this.libraries.concat([require("./library/fs"), require("./library/process")]);
    }
    this.classes = [];
    this.instances = [];
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

  Context.prototype.coalesce_libraries = function() {
    var j, k, len, lib, ref, results, v;
    this.patterns = [];
    this.operators = [];
    this.constants = new Map;
    this.variables = new Map;
    ref = this.libraries;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      lib = ref[j];
      this.patterns = this.patterns.concat(lib.patterns);
      this.operators = this.operators.concat(lib.operators);
      results.push((function() {
        var ref1, results1;
        ref1 = lib.constants;
        results1 = [];
        for (k in ref1) {
          v = ref1[k];
          results1.push(this.constants.set(k, v));
        }
        return results1;
      }).call(this));
    }
    return results;
  };

  Context.prototype["eval"] = function(text) {
    var token, tokens;
    this.coalesce_libraries();
    tokens = tokenize(text);
    return this.eval_tokens((function() {
      var j, len, ref, results;
      results = [];
      for (j = 0, len = tokens.length; j < len; j++) {
        token = tokens[j];
        if ((ref = token.type) !== "newline" && ref !== "comment") {
          results.push(token);
        }
      }
      return results;
    })());
  };

  Context.prototype.eval_tokens = function(tokens) {
    var advance, find_longest_match, index, parse_expression, parse_primary, peek;
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
    find_longest_match = (function(_this) {
      return function(tokens, match_fn_type) {
        var j, len, longest_match, match, pattern, ref;
        if (match_fn_type == null) {
          match_fn_type = "match";
        }
        longest_match = void 0;
        ref = _this.patterns;
        for (j = 0, len = ref.length; j < len; j++) {
          pattern = ref[j];
          match = pattern[match_fn_type](tokens);
          if (longest_match == null) {
            longest_match = match;
          }
          if ((match != null ? match.matcher.length : void 0) > (longest_match != null ? longest_match.matcher.length : void 0)) {
            longest_match = match;
          }
        }
        return longest_match;
      };
    })(this);
    parse_primary = (function(_this) {
      return function() {
        var bad_match, bracketed_tokens, bracketed_value, closing_token_index, following_value, get_var_value, i, j, l, len, len1, len2, len3, m, match, matcher, n, next_literal_tokens, next_tokens, next_word_tok_str, next_word_tokens, operator, ref, ref1, returns, str, tok_str, token;
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
        for (i = l = 0, len1 = next_tokens.length; l < len1; i = ++l) {
          token = next_tokens[i];
          if (token.type === "word") {
            next_word_tokens.push(token);
          } else {
            break;
          }
        }
        tok_str = stringify_tokens(next_tokens);
        next_word_tok_str = stringify_tokens(next_word_tokens);
        match = find_longest_match(next_tokens);
        if (match != null) {
          get_var_value = function(var_name) {
            return _this.eval_tokens(match[var_name]);
          };
          returns = match.pattern.fn(get_var_value, _this);
          return returns;
        } else {
          bad_match = find_longest_match(next_tokens, "bad_match");
          if (bad_match != null) {
            throw new Error("For `" + tok_str + "`, use `" + bad_match.pattern.prefered + "` instead");
          }
        }
        if (next_literal_tokens.length) {
          if (next_literal_tokens.some(function(token) {
            return token.type === "string";
          })) {
            str = "";
            for (m = 0, len2 = next_tokens.length; m < len2; m++) {
              token = next_tokens[m];
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
            if (_this.constants.has(next_word_tok_str)) {
              return _this.constants.get(next_word_tok_str);
            }
            if (_this.variables.has(next_word_tok_str)) {
              return _this.variables.get(next_word_tok_str);
            }
          } else {
            if (_this.constants.has(tok_str)) {
              return _this.constants.get(tok_str);
            }
            if (_this.variables.has(tok_str)) {
              return _this.variables.get(tok_str);
            }
          }
          token = tokens[index];
          if (token.type === "punctuation" && token.value === "(" || token.type === "indent") {
            closing_token_index = find_closing_token(tokens, index);
            bracketed_tokens = tokens.slice(index + 1, closing_token_index);
            bracketed_value = _this.eval_tokens(bracketed_tokens);
            advance(closing_token_index - 1);
            return parse_expression(bracketed_value, 0);
          }
          ref1 = _this.operators;
          for (n = 0, len3 = ref1.length; n < len3; n++) {
            operator = ref1[n];
            if (!operator.unary) {
              continue;
            }
            matcher = operator.match(tokens, index);
            if (matcher) {
              advance(matcher.length);
              if (index === tokens.length) {
                throw new Error("missing right operand for `" + operator.prefered + "`");
              }
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
            throw new Error("missing right operand for `" + lookahead_operator.prefered + "`");
          }
          rhs = parse_primary();
          advance();
          lookahead_operator = match_operator();
          while (((lookahead_operator != null ? lookahead_operator.binary : void 0) && lookahead_operator.precedence > operator.precedence) || ((lookahead_operator != null ? lookahead_operator.right_associative : void 0) && lookahead_operator.precedence === operator.precedence)) {
            if (lookahead_operator.binary && (tokens[index] == null)) {
              throw new Error("missing right operand for `" + lookahead_operator.prefered + "`");
            }
            advance(-2);
            rhs = parse_expression(rhs, lookahead_operator.precedence);
            advance(2);
            lookahead_operator = match_operator();
          }
          lhs = operator.fn(lhs, rhs);
        }
        if (lookahead_operator != null ? lookahead_operator.unary : void 0) {
          throw new Error("unary operator at end of expression? (missing right operand?)");
        }
        return lhs;
      };
    })(this);
    return parse_expression(parse_primary(), 0);
  };

  return Context;

})();


},{"./Pattern":7,"./Token":8,"./find-closing-token":9,"./library/conditionals":10,"./library/console":11,"./library/constants":12,"./library/eval-js":13,"./library/eval-ooplie":14,"./library/fs":15,"./library/operators":16,"./library/process":17,"./tokenize":19}],5:[function(require,module,exports){
var Library;

module.exports = Library = (function() {
  function Library(name, arg) {
    this.name = name;
    this.patterns = arg.patterns, this.operators = arg.operators, this.constants = arg.constants;
    if (this.patterns == null) {
      this.patterns = [];
    }
    if (this.operators == null) {
      this.operators = [];
    }
    if (this.constants == null) {
      this.constants = [];
    }
  }

  return Library;

})();


},{}],6:[function(require,module,exports){
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


},{"./Pattern":7}],7:[function(require,module,exports){
var Pattern, find_closing_token, stringify_matcher, stringify_tokens, tokenize,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

tokenize = require("./tokenize");

stringify_tokens = require("./Token").stringify_tokens;

find_closing_token = require("./find-closing-token");

stringify_matcher = function(matcher) {
  return matcher.join(" ");
};

module.exports = Pattern = (function() {
  function Pattern(arg) {
    var bad_match, match, parse_matchers;
    match = arg.match, bad_match = arg.bad_match, this.fn = arg.fn;
    parse_matchers = function(matcher_defs) {
      var current_variable_name, def, i, index, j, len, len1, ref, results, segments, token, tokens, variable_names_used;
      results = [];
      for (i = 0, len = matcher_defs.length; i < len; i++) {
        def = matcher_defs[i];
        tokens = tokenize(def);
        segments = [];
        variable_names_used = [];
        current_variable_name = null;
        for (index = j = 0, len1 = tokens.length; j < len1; index = ++j) {
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
    this.prefered_matcher = this.matchers[0];
  }

  Pattern.prototype.match_with = function(tokens, matcher) {
    var bracketed_tokens, closing_token_index, current_variable_tokens, matcher_index, next_segment, ref, ref1, ref2, segment, token, token_index, token_matches, variables;
    variables = {};
    current_variable_tokens = null;
    token_matches = function(token, segment) {
      return (token != null ? token.type : void 0) === segment.type && token.value.toLowerCase() === segment.value.toLowerCase();
    };
    token_index = 0;
    matcher_index = 0;
    while (token_index < tokens.length) {
      token = tokens[token_index];
      segment = matcher[matcher_index];
      if (segment == null) {
        return;
      }
      if (segment.type === "variable") {
        if (token.type === "newline" && ((ref = (ref1 = tokens[token_index + 1]) != null ? ref1.type : void 0) === "indent" || ref === "dedent")) {
          token_index += 1;
          continue;
        }
        if (variables[segment.name] != null) {
          next_segment = matcher[matcher_index + 1];
          if ((next_segment != null) && token_matches(token, next_segment)) {
            matcher_index += 1;
            continue;
          } else {
            variables[segment.name].push(token);
          }
        } else {
          variables[segment.name] = [token];
        }
        if (token.type === "punctuation" && ((ref2 = token.value) === "(" || ref2 === "[" || ref2 === "{") || token.type === "indent") {
          closing_token_index = find_closing_token(tokens, token_index);
          bracketed_tokens = tokens.slice(token_index + 1, closing_token_index);
          token_index = closing_token_index - 1;
          variables[segment.name] = variables[segment.name].concat(bracketed_tokens);
        }
      } else {
        if (token_matches(token, segment)) {
          matcher_index += 1;
        } else {
          return;
        }
      }
      token_index += 1;
    }
    if (variables[segment.name] != null) {
      matcher_index += 1;
    }
    if (matcher_index === matcher.length) {
      variables.pattern = this;
      variables.matcher = matcher;
      return variables;
    } else {

    }
  };

  Pattern.prototype.match = function(tokens) {
    var i, len, match, matcher, ref;
    ref = this.matchers;
    for (i = 0, len = ref.length; i < len; i++) {
      matcher = ref[i];
      match = this.match_with(tokens, matcher);
      if (match != null) {
        return match;
      }
    }
  };

  Pattern.prototype.bad_match = function(tokens) {
    var i, len, match, matcher, ref;
    ref = this.bad_matchers;
    for (i = 0, len = ref.length; i < len; i++) {
      matcher = ref[i];
      match = this.match_with(tokens, matcher);
      if (match != null) {
        return match;
      }
    }
  };

  Pattern.prototype.match_near = function() {};

  return Pattern;

})();


},{"./Token":8,"./find-closing-token":9,"./tokenize":19}],8:[function(require,module,exports){
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


},{}],9:[function(require,module,exports){
module.exports = function(tokens, start_index) {
  var closing_bracket, ended, level, lookahead_index, lookahead_token, opening_bracket, opening_token;
  opening_token = tokens[start_index];
  lookahead_index = start_index;
  level = 1;
  while (true) {
    lookahead_index += 1;
    lookahead_token = tokens[lookahead_index];
    if (lookahead_token != null) {
      if (opening_token.type === "punctuation") {
        if (lookahead_token.type === "punctuation") {
          opening_bracket = opening_token.value;
          closing_bracket = {
            "(": ")",
            "[": "]",
            "{": "}"
          }[opening_bracket];
          if (lookahead_token.value === opening_bracket) {
            level += 1;
          }
          if (lookahead_token.value === closing_bracket) {
            level -= 1;
          }
        }
      } else {
        if (lookahead_token.type === "indent") {
          level += 1;
        }
        if (lookahead_token.type === "dedent") {
          level -= 1;
        }
      }
      ended = level === 0;
      if (ended) {
        return lookahead_index;
      }
    } else {
      if (opening_token.type === "punctuation") {
        if (opening_token) {
          throw new Error("Missing ending parenthesis in `" + tok_str + "`");
        } else {
          throw new Error("Missing ending bracket in `" + tok_str + "`");
        }
      } else {
        throw new Error("Missing ending... dedent? in `" + tok_str + "`? " + (JSON.stringify(next_tokens)));
      }
    }
  }
};


},{}],10:[function(require,module,exports){
var Library, Pattern;

Pattern = require("../Pattern");

Library = require("../Library");

module.exports = new Library("Conditionals", {
  patterns: [
    new Pattern({
      match: ["If <condition>, <body>", "If <condition> then <body>", "<body> if <condition>"],
      fn: (function(_this) {
        return function(v) {
          if (v("condition")) {
            return v("body");
          }
        };
      })(this)
    }), new Pattern({
      match: ["If <condition>, <body>, else <alt body>", "If <condition>, <body> else <alt body>", "If <condition> then <body>, else <alt body>", "If <condition> then <body> else <alt body>", "<body> if <condition> else <alt body>"],
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
      match: ["Unless <condition>, <body>", "<body> unless <condition>"],
      bad_match: ["Unless <condition> then <body>"],
      fn: (function(_this) {
        return function(v) {
          if (!v("condition")) {
            return v("body");
          }
        };
      })(this)
    }), new Pattern({
      match: ["<body> unless <condition> in which case <alt body>", "<body>, unless <condition> in which case <alt body>", "<body> unless <condition>, in which case <alt body>", "<body>, unless <condition>, in which case <alt body>", "<body> unless <condition> in which case just <alt body>", "<body>, unless <condition> in which case just <alt body>", "<body> unless <condition>, in which case just <alt body>", "<body>, unless <condition>, in which case just <alt body>"],
      bad_match: ["Unless <condition>, <body>, else <alt body>", "Unless <condition> then <body>, else <alt body>", "Unless <condition> then <body> else <alt body>", "<body> unless <condition> else <alt body>", "<body> or if <condition> else <alt body>", "<body>, or if <condition>, <alt body>", "<body>, or if <condition> <alt body>", "<body> or if <condition>, <alt body>"],
      fn: (function(_this) {
        return function(v) {
          if (!v("condition")) {
            return v("body");
          } else {
            return v("alt body");
          }
        };
      })(this)
    })
  ]
});


},{"../Library":5,"../Pattern":7}],11:[function(require,module,exports){
var Library, Pattern;

Pattern = require("../Pattern");

Library = require("../Library");

module.exports = new Library("Console", {
  patterns: [
    new Pattern({
      match: ["Output <text>", "Output <text> to the console", "Log <text>", "Log <text> to the console", "Print <text>", "Print <text> to the console", "Say <text>"],
      bad_match: ["puts <text>", "println <text>", "print line <text>", "printf <text>", "console.log <text>", "writeln <text>", "output <text> to the terminal", "log <text> to the terminal", "print <text> to the terminal"],
      fn: (function(_this) {
        return function(v, context) {
          context.console.log(v("text"));
        };
      })(this)
    }), new Pattern({
      match: ["Clear the console", "Clear console"],
      bad_match: ["Clear the terminal", "Clear terminal", "clear", "cls", "clr"],
      fn: (function(_this) {
        return function(v, context) {
          context.console.clear();
        };
      })(this)
    })
  ]
});


},{"../Library":5,"../Pattern":7}],12:[function(require,module,exports){
var Library;

Library = require("../Library");

module.exports = new Library("Constants", {
  constants: {
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
  }
});


},{"../Library":5}],13:[function(require,module,exports){
var Library, Pattern;

Pattern = require("../Pattern");

Library = require("../Library");

module.exports = new Library("JavaScript Eval", {
  patterns: [
    new Pattern({
      match: ["Run JS <text>", "Run JavaScript <text>", "Run <text> as JS", "Run <text> as JavaScript", "Execute JS <text>", "Execute JavaScript <text>", "Execute <text> as JS", "Execute <text> as JavaScript", "Eval JS <text>", "Eval JavaScript <text>", "Eval <text> as JS", "Eval <text> as JavaScript"],
      bad_match: ["Eval <text>", "Run <text>", "Execute <text>", "JavaScript <text>", "JS <text>"],
      fn: (function(_this) {
        return function(v, context) {
          var console;
          console = context.console;
          return eval(v("text"));
        };
      })(this)
    })
  ]
});


},{"../Library":5,"../Pattern":7}],14:[function(require,module,exports){
var Library, Pattern;

Pattern = require("../Pattern");

Library = require("../Library");

module.exports = new Library("Ooplie Eval", {
  patterns: [
    new Pattern({
      match: ["Interpret <text> as English", "Run <text> as English", "Execute <text> as English", "Eval <text> as English", "Interpret <text> as Ooplie code", "Run <text> as Ooplie code", "Execute <text> as Ooplie code", "Eval <text> as Ooplie code", "Run code <text> with Ooplie", "Eval code <text> with Ooplie", "Execute code <text> with Ooplie", "Interpret code <text> with Ooplie", "Run Ooplie code <text>", "Eval Ooplie code <text>", "Execute Ooplie code <text>", "Interpret Ooplie code <text>", "Run English <text>", "Eval English <text>", "Execute English <text>", "Interpret <text> with Ooplie", "Run <text> with Ooplie", "Eval <text> with Ooplie", "Execute <text> with Ooplie"],
      bad_match: ["Run Ooplie <text>", "Eval Ooplie <text>", "Execute Ooplie <text>", "Interpret Ooplie <text>", "Run <text> as Ooplie", "Run code <text> as Ooplie", "Execute <text> as Ooplie", "Execute <text> as Ooplie", "Eval <text> as Ooplie", "Eval code <text> as Ooplie", "Run code <text> as English", "Run English code <text>", "Eval English code <text>", "Execute English code <text>", "Interpret English code <text>", "Run English code <text>", "Eval <text> as English code", "Execute English code <text>", "Interpret <text> as English code", "Make Ooplie Interpret <text>", "Have Ooplie Interpret <text>", "Let Ooplie Interpret <text>"],
      fn: (function(_this) {
        return function(v, context) {
          return context["eval"](v("text"));
        };
      })(this)
    })
  ]
});


},{"../Library":5,"../Pattern":7}],15:[function(require,module,exports){
var Library, Pattern, fs, path;

fs = require("fs");

path = require("path");

Pattern = require("../Pattern");

Library = require("../Library");

if ((typeof window !== "undefined" && window !== null ? window.require : void 0) != null) {
  fs = window.require("fs");
}

module.exports = new Library("File System", {
  patterns: [
    new Pattern({
      match: ["Make directory <dir>", "Create directory <dir>", "Make folder <dir>", "Create folder <dir>"],
      bad_match: ["Make dir <dir>", "Create dir <dir>", "mkdir <dir>"],
      fn: (function(_this) {
        return function(v) {
          return fs.mkdir(v("dir"));
        };
      })(this)
    }), new Pattern({
      match: ["Make directories <dir>", "Create directories <dir>", "Make folders <dir>", "Create folders <dir>"],
      bad_match: ["Make directories recursively <dir>", "Create directories recursively <dir>", "Make dirs recursively <dir>", "Create dirs recursively <dir>", "Make dirs <dir>", "Create dirs <dir>", "Make path <dir>", "Create path <dir>", "mkdirp <dir>", "mkdirs <dir>"],
      fn: (function(_this) {
        return function(v) {
          throw new Error("Not implemented (needs an npm module)");
        };
      })(this)
    }), new Pattern({
      match: ["Make directories for <file path>", "Create directories <file path>", "Make all the directories for <file path>", "Create all the directories for <file path>", "Make folders for <file path>", "Create folders for <file path>", "Make all the folders for <file path>", "Create all the folders for <file path>"],
      fn: (function(_this) {
        return function(v) {
          var dir;
          dir = path.dirname(v("file path"));
          throw new Error("Not implemented (needs an npm module)");
        };
      })(this)
    }), new Pattern({
      match: ["Write <data> to file <file>", "Write <data> to <file>", "Write <file> with content <data>"],
      fn: (function(_this) {
        return function(v) {
          return fs.writeFileSync(v("file"), v("data"));
        };
      })(this)
    }), new Pattern({
      match: ["Append <data> to <file>", "Write <data> to the end of <file>"],
      bad_match: ["Append <data> to the end of <file>"],
      fn: (function(_this) {
        return function(v) {
          return fs.appendFileSync(v("file"), v("data"));
        };
      })(this)
    }), new Pattern({
      match: ["Read from <file>", "Read file <file>", "Read <data> from <file>", "Read <file>"],
      fn: (function(_this) {
        return function(v) {
          return fs.readFileSync(v("file"), "utf8");
        };
      })(this)
    }), new Pattern({
      match: ["Read from <file> as a buffer", "Read file <file> as a buffer", "Read <file> as a buffer"],
      bad_match: ["Read from <file> as buffer", "Read file <file> as buffer", "Read <file> as buffer"],
      fn: (function(_this) {
        return function(v) {
          return fs.readFileSync(v("file"));
        };
      })(this)
    }), new Pattern({
      match: ["we have permission to read from <file>", "we have permission to read <file>", "I have permission to read from <file>", "I have permission to read <file>", "we can read from <file>", "we can read <file>", "I can read from <file>", "I can read <file>"],
      fn: (function(_this) {
        return function(v) {
          var e, error;
          try {
            fs.accessSync(v("file"), fs.R_OK);
          } catch (error) {
            e = error;
            if (e.code !== "EPERM") {
              throw e;
            }
            return false;
          }
          return true;
        };
      })(this)
    }), new Pattern({
      match: ["we have permission to write to <file>", "we have permission to write <file>", "I have permission to write to <file>", "I have permission to write <file>", "we can write to <file>", "we can write <file>", "I can write to <file>", "I can write <file>"],
      fn: (function(_this) {
        return function(v) {
          var e, error;
          try {
            fs.accessSync(v("file"), fs.W_OK);
          } catch (error) {
            e = error;
            if (e.code !== "EPERM") {
              throw e;
            }
            return false;
          }
          return true;
        };
      })(this)
    }), new Pattern({
      match: ["stdout", "standard out"],
      fn: (function(_this) {
        return function(v) {
          return 1;
        };
      })(this)
    }), new Pattern({
      match: ["stdin", "standard in"],
      fn: (function(_this) {
        return function(v) {
          return 0;
        };
      })(this)
    }), new Pattern({
      match: ["stderr", "standard error"],
      bad_match: ["standarderror", "standard err", "std error", "stderror", "std err"],
      fn: (function(_this) {
        return function(v) {
          return 2;
        };
      })(this)
    }), new Pattern({
      match: ["list directory contents", "list folder contents", "list current directory contents", "list current folder contents", "list contents of the current directory", "list contents of the current folder", "list the contents of the current directory", "list the contents of the current folder", "list files and subdirectories", "list files and directories", "ls"],
      bad_match: ["list dir contents", "list current dir contents", "list contents of the current dir", "list the contents of the current dir"],
      fn: (function(_this) {
        return function(v) {
          var directory;
          directory = ".";
          return fs.readdirSync(directory).map(function(fname) {
            return path.join(directory, fname);
          });
        };
      })(this)
    }), new Pattern({
      match: ["list files", "list files in the current directory", "list the files in the current directory"],
      fn: (function(_this) {
        return function(v) {
          var directory;
          directory = ".";
          return fs.readdirSync(directory).map(function(fname) {
            return path.join(directory, fname);
          }).filter(function(fname) {
            return fs.statSync(fname).isFile();
          });
        };
      })(this)
    }), new Pattern({
      match: ["list subdirectories", "list subfolders", "list directories", "list folders", "list folders in the current directory", "list the folders in the current directory", "list folders in the current folder", "list the folders in the current folder"],
      fn: (function(_this) {
        return function(v) {
          var directory;
          directory = ".";
          return fs.readdirSync(directory).map(function(fname) {
            return path.join(directory, fname);
          }).filter(function(fname) {
            return fs.statSync(fname).isDirectory();
          });
        };
      })(this)
    })
  ]
});


},{"../Library":5,"../Pattern":7,"fs":1,"path":2}],16:[function(require,module,exports){
var Library, Operator;

Operator = require("../Operator");

Library = require("../Library");

module.exports = new Library("Operators", {
  operators: [
    new Operator({
      match: ["^", "to the power of"],
      bad_match: ["**"],
      precedence: 3,
      right_associative: true,
      fn: function(lhs, rhs) {
        return Math.pow(lhs, rhs);
      }
    }), new Operator({
      match: ["×", "*", "times", "multiplied by"],
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
  ]
});


},{"../Library":5,"../Operator":6}],17:[function(require,module,exports){
var Library, Pattern, process;

Pattern = require("../Pattern");

Library = require("../Library");

if (typeof window !== "undefined" && window !== null ? window.global : void 0) {
  process = window.global.process;
}

module.exports = new Library("Process", {
  patterns: [
    new Pattern({
      match: ["Exit the program", "Exit this process", "Exit the process", "Exit"],
      bad_match: ["Exit this program", "End this process", "Exit process", "End process", "Exit program", "End program"],
      fn: (function(_this) {
        return function(v) {
          return process.exit();
        };
      })(this)
    }), new Pattern({
      match: ["Kill process <pid>", "End process <pid>"],
      maybe_match: ["Kill <pid>", "End <pid>"],
      fn: (function(_this) {
        return function(v) {
          return process.kill(v("pid"));
        };
      })(this)
    }), new Pattern({
      match: ["command-line arguments"],
      bad_match: ["command line arguments", "arguments from the command-line", "argv"],
      maybe_match: ["arguments", "args"],
      fn: (function(_this) {
        return function(v) {
          return process.argv;
        };
      })(this)
    }), new Pattern({
      match: ["current memory usage", "this process's memory usage", "memory usage of this process", "memory usage"],
      fn: (function(_this) {
        return function(v) {
          return process.memoryUsage();
        };
      })(this)
    }), new Pattern({
      match: ["Set the process's title to <text>", "Name the process <text>"],
      bad_match: ["Call the process <text>"],
      fn: (function(_this) {
        return function(v) {
          return process.title = v("text");
        };
      })(this)
    }), new Pattern({
      match: ["the process's title", "the name of the process"],
      bad_match: ["the process title"],
      fn: (function(_this) {
        return function(v) {
          return process.title;
        };
      })(this)
    }), new Pattern({
      match: ["the working directory", "the current directory", "working directory", "current directory"],
      bad_match: ["the working dir", "the current dir", "working dir", "current dir", "pwd", "cwd"],
      fn: (function(_this) {
        return function(v) {
          return process.cwd();
        };
      })(this)
    }), new Pattern({
      match: ["change directory to <path>", "change working directory to <path>", "change current directory to <path>", "set working directory to <path>", "set current directory to <path>", "enter directory <path>", "go to directory <path>", "enter folder <path>", "go to folder <path>"],
      bad_match: ["enter dir <path>", "go to dir <path>", "change working dir to <path>", "change current dir to <path>", "cd into <path>", "cd to <path>", "cd <path>", "chdir into <path>", "chdir to <path>", "chdir <path>", "set directory to <path>", "change dir to <path>", "set cwd to <path>"],
      fn: (function(_this) {
        return function(v) {
          return process.chdir(v("path"));
        };
      })(this)
    }), new Pattern({
      match: ["go up", "go out of this folder", "exit folder", "exit this folder"],
      bad_match: ["cd .."],
      fn: (function(_this) {
        return function(v) {
          return process.chdir("..");
        };
      })(this)
    })
  ]
});


},{"../Library":5,"../Pattern":7}],18:[function(require,module,exports){
var Context, Library, Operator, Pattern, Token, tokenize;

Context = require('./Context');

Library = require('./Library');

Pattern = require('./Pattern');

Operator = require('./Operator');

Token = require('./Token');

tokenize = require('./tokenize');

module.exports = {
  Context: Context,
  Library: Library,
  Pattern: Pattern,
  Operator: Operator,
  Token: Token,
  tokenize: tokenize
};


},{"./Context":4,"./Library":5,"./Operator":6,"./Pattern":7,"./Token":8,"./tokenize":19}],19:[function(require,module,exports){
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


},{"./Token":8}]},{},[18])(18)
});