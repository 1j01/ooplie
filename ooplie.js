(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.Ooplie = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
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
},{"_process":2}],2:[function(require,module,exports){
// shim for using process in browser
var process = module.exports = {};

// cached from whatever global is present so that test runners that stub it
// don't break things.  But we need to wrap it in a try catch in case it is
// wrapped in strict mode code which doesn't define any globals.  It's inside a
// function because try/catches deoptimize in certain engines.

var cachedSetTimeout;
var cachedClearTimeout;

function defaultSetTimout() {
    throw new Error('setTimeout has not been defined');
}
function defaultClearTimeout () {
    throw new Error('clearTimeout has not been defined');
}
(function () {
    try {
        if (typeof setTimeout === 'function') {
            cachedSetTimeout = setTimeout;
        } else {
            cachedSetTimeout = defaultSetTimout;
        }
    } catch (e) {
        cachedSetTimeout = defaultSetTimout;
    }
    try {
        if (typeof clearTimeout === 'function') {
            cachedClearTimeout = clearTimeout;
        } else {
            cachedClearTimeout = defaultClearTimeout;
        }
    } catch (e) {
        cachedClearTimeout = defaultClearTimeout;
    }
} ())
function runTimeout(fun) {
    if (cachedSetTimeout === setTimeout) {
        //normal enviroments in sane situations
        return setTimeout(fun, 0);
    }
    // if setTimeout wasn't available but was latter defined
    if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
        cachedSetTimeout = setTimeout;
        return setTimeout(fun, 0);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedSetTimeout(fun, 0);
    } catch(e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
            return cachedSetTimeout.call(null, fun, 0);
        } catch(e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
            return cachedSetTimeout.call(this, fun, 0);
        }
    }


}
function runClearTimeout(marker) {
    if (cachedClearTimeout === clearTimeout) {
        //normal enviroments in sane situations
        return clearTimeout(marker);
    }
    // if clearTimeout wasn't available but was latter defined
    if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
        cachedClearTimeout = clearTimeout;
        return clearTimeout(marker);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedClearTimeout(marker);
    } catch (e){
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
            return cachedClearTimeout.call(null, marker);
        } catch (e){
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
            // Some versions of I.E. have different rules for clearTimeout vs setTimeout
            return cachedClearTimeout.call(this, marker);
        }
    }



}
var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    if (!draining || !currentQueue) {
        return;
    }
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
    var timeout = runTimeout(cleanUpNextTick);
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
    runClearTimeout(timeout);
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
        runTimeout(drainQueue);
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
process.prependListener = noop;
process.prependOnceListener = noop;

process.listeners = function (name) { return [] }

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function() { return 0; };

},{}],3:[function(require,module,exports){

},{}],4:[function(require,module,exports){
var Context, Pattern, Token, find_closing_token, stringify_tokens, tokenize;

tokenize = require("./tokenize");

Pattern = require("./Pattern");

({stringify_tokens} = Token = require("./Token"));

find_closing_token = require("./find-closing-token");

module.exports = Context = class Context {
  constructor({
      console: console1,
      supercontext
    } = {}) {
    this.console = console1;
    this.supercontext = supercontext;
    // TODO: further decouple from console somehow?
    // console IO is exceedingly common, but it might be good to establish
    // a more reusable pattern for passing interfaces and things to a context

    // in the case of natural language, semantics are quite tied to context
    // so the parser will need access to the context
    this.libraries = [require("./library/operators"), require("./library/constants"), require("./library/conditionals"), require("./library/console"), require("./library/eval-js"), require("./library/eval-ooplie")];
    if (!((typeof window !== "undefined" && window !== null) && (window.require == null))) {
      this.libraries = this.libraries.concat([require("./library/fs"), require("./library/process")]);
    }
    this.classes = [];
    this.instances = [];
  }

  subcontext({console} = {}) {
    if (console == null) {
      console = this.console;
    }
    return new Context({
      console,
      supercontext: this
    });
  }

  coalesce_libraries() {
    var j, k, len, lib, ref, results, v;
    this.patterns = [];
    this.operators = [];
    this.constants = new Map;
    this.variables = new Map;
    ref = this.libraries;
    // TODO: block-level scopes
    // should @supercontext be @superscope?
    // should contexts be scopes? should scopes be contexts?
    // also make sure we don't encourage global-like behavior
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
  }

  // TODO: collect from supercontexts as well
  eval(text) {
    var token, tokens;
    // TODO: coalesce libs only when @libraries array is modified
    // using https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy
    // and not https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/observe
    // although, note that that means a modified individual library wouldn't be updated
    // (until any change to @libraries, not necessarily a removal and addition of the given library)
    this.coalesce_libraries();
    tokens = tokenize(text);
    
    // TODO: why are comments handled like this?
    // this should at LEAST be in eval_tokens, not outside of it
    return this.eval_tokens((function() {
      var j, len, results;
      results = [];
      for (j = 0, len = tokens.length; j < len; j++) {
        token = tokens[j];
        if (token.type !== "comment") {
          results.push(token);
        }
      }
      return results;
    })());
  }

  
  // eval is syncronous, but could return Promises for asyncronous operations
  // a block of async statements should probably return a single Promise that wraps all the Promises of its statements
  eval_tokens(tokens) {
    var ast_node;
    // console.log("eval_tokens", stringify_tokens(tokens))
    ast_node = this.parse_tokens(tokens);
    return this.eval_ast(ast_node);
  }

  stringify_ast(ast_node) {
    return JSON.stringify(ast_node, function(key, ast_node) {
      if (ast_node instanceof Pattern) {
        return ast_node.prefered;
      } else {
        return ast_node;
      }
    });
  }

  eval_ast(ast_node) {
    var get_var_value, inner_ast_node, j, l, len, len1, ref, result, string, token;
    // console.log("eval_ast", @stringify_ast(ast_node))
    if (!ast_node) {
      return;
    }
    if (Array.isArray(ast_node)) {
      for (j = 0, len = ast_node.length; j < len; j++) {
        inner_ast_node = ast_node[j];
        result = this.eval_ast(inner_ast_node);
      }
      return result;
    }
    
    // TODO: better AST in general
    // include Tokens for character ranges
    switch (ast_node.type) {
      case "literal":
        return ast_node.value;
      case "constant": // maybe these should both just be identifiers or whatever
        return this.constants.get(ast_node.name);
      case "variable": // maybe these should both just be identifiers or whatever
        return this.variables.get(ast_node.name);
      case "pattern": // TODO: naming?
        get_var_value = (var_name) => {
          return this.eval_ast(ast_node.vars[var_name]);
        };
        return ast_node.pattern.fn(get_var_value, this);
      case "operator":
        if (ast_node.left_hand_ast_node && ast_node.right_hand_ast_node) {
          return ast_node.operator.fn(this.eval_ast(ast_node.left_hand_ast_node), this.eval_ast(ast_node.right_hand_ast_node));
        } else {
          return ast_node.operator.fn(this.eval_ast(ast_node.operand));
        }
        break;
      case "concat_literals": // TODO: should probably be an operation!
        string = "";
        ref = ast_node.params;
        for (l = 0, len1 = ref.length; l < len1; l++) {
          token = ref[l];
          string += token.value;
        }
        return string;
    }
  }

  parse_tokens(tokens) {
    var find_longest_match, index, parse_expression, parse_primary;
    // TODO: rename some things like _ast_node -> _ast or _node or _ast_node or whatever
    // console.log("parse_tokens", stringify_tokens(tokens))
    index = 0;
    find_longest_match = (tokens, match_fn_type = "match") => {
      var j, len, longest_match, match, pattern, ref;
      longest_match = void 0;
      ref = this.patterns;
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
    parse_primary = () => {
      var bad_match, bracketed_ast_node, bracketed_tokens, closing_token_index, following_ast_node, i, j, key, l, len, len1, len2, len3, m, match, matcher, n, next_literal_tokens, next_token, next_word_token_string, next_word_tokens, operator, parse_tokens, prev_token, ref, ref1, ref2, ref3, ref4, token, token_string, value, vars;
      // console.log("parse_primary (using tokens from parse_tokens:)", stringify_tokens(tokens))
      parse_tokens = [];
      ref = tokens.slice(index);
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        token = ref[i];
        if (token.type === "newline") {
          prev_token = tokens[i - 1];
          next_token = tokens[i + 1];
          if ((prev_token != null) && ((ref1 = prev_token.type) !== "newline" && ref1 !== "dedent")) {
            if ((ref2 = next_token != null ? next_token.type : void 0) !== "indent" && ref2 !== "dedent") {
              break;
            }
          }
        } else {
          parse_tokens.push(token);
        }
      }
      if (parse_tokens.length === 0) {
        return;
      }
      
      // NOTE: in the future there will be other kinds of literals
      next_literal_tokens = [];
      for (i = l = 0, len1 = parse_tokens.length; l < len1; i = ++l) {
        token = parse_tokens[i];
        if ((ref3 = token.type) === "string" || ref3 === "number") {
          next_literal_tokens.push(token);
        } else {
          break;
        }
      }
      next_word_tokens = [];
      for (i = m = 0, len2 = parse_tokens.length; m < len2; i = ++m) {
        token = parse_tokens[i];
        if (token.type === "word") {
          next_word_tokens.push(token);
        } else {
          break;
        }
      }
      token_string = stringify_tokens(parse_tokens);
      next_word_token_string = stringify_tokens(next_word_tokens);
      match = find_longest_match(parse_tokens);
      if (match != null) {
        vars = {};
        for (key in match) {
          value = match[key];
          if (key !== "pattern" && key !== "matcher") {
            vars[key] = this.parse_tokens(value);
          }
        }
        return {
          type: "pattern",
          pattern: match.pattern,
          vars
        };
      } else {
        bad_match = find_longest_match(parse_tokens, "bad_match");
        if (bad_match != null) {
          throw new Error(`For \`${token_string}\`, use \`${bad_match.pattern.prefered}\` instead`);
        }
      }
      if (next_literal_tokens.length) {
        // TODO: give just a literal for a single string
        if (next_literal_tokens.some(function(token) {
          return token.type === "string";
        })) {
          return {
            type: "concat_literals",
            params: next_literal_tokens
          };
        } else if (next_literal_tokens.length > 1) {
          // TODO: row/column numbers in errors
          throw new Error(`Consecutive numbers, ${next_literal_tokens[0].value} and ${next_literal_tokens[1].value}`);
        } else {
          return {
            type: "literal",
            value: next_literal_tokens[0].value,
            token: next_literal_tokens[0]
          };
        }
      } else {
        if (next_word_tokens.length) {
          if (this.constants.has(next_word_token_string)) {
            return {
              type: "constant",
              name: next_word_token_string
            };
          }
          if (this.variables.has(next_word_token_string)) {
            return {
              type: "variable",
              name: next_word_token_string
            };
          }
        } else {
          if (this.constants.has(token_string)) {
            return {
              type: "constant",
              name: token_string
            };
          }
          if (this.variables.has(token_string)) {
            return {
              type: "variable",
              name: token_string
            };
          }
        }
        token = tokens[index];
        if (token.type === "punctuation" && token.value === "(" || token.type === "indent") {
          closing_token_index = find_closing_token(tokens, index);
          bracketed_tokens = tokens.slice(index + 1, closing_token_index);
          bracketed_ast_node = this.parse_tokens(bracketed_tokens);
          index = closing_token_index;
          return parse_expression(bracketed_ast_node, 0);
        }
        ref4 = this.operators;
        for (n = 0, len3 = ref4.length; n < len3; n++) {
          operator = ref4[n];
          if (!operator.unary) {
            continue;
          }
          matcher = operator.match(tokens, index);
          if (matcher) {
            index += matcher.length;
            if (index === tokens.length) {
              throw new Error(`missing right operand for \`${operator.prefered}\``);
            }
            following_ast_node = parse_primary();
            return {
              type: "operator",
              operator,
              operand: following_ast_node
            };
          }
        }
        throw new Error(`I don't understand \`${token_string}\``);
      }
    };
    parse_expression = (left_hand_ast_node, min_precedence) => {
      var anything_substantial_after_newline, i, j, lookahead_operator, match_operator, operator, ref, ref1, ref2, ref3, right_hand_ast_node;
      // console.log "parse_expression", @stringify_ast(left_hand_ast_node), min_precedence #, tokens, index
      match_operator = () => {
        var j, len, matcher, operator, ref;
        ref = this.operators;
        for (j = 0, len = ref.length; j < len; j++) {
          operator = ref[j];
          matcher = operator.match(tokens, index);
          if (matcher != null) {
            index += matcher.length;
            return operator;
          }
        }
      };
      index += 1;
      lookahead_operator = match_operator();
      while ((lookahead_operator != null ? lookahead_operator.binary : void 0) && lookahead_operator.precedence >= min_precedence) {
        operator = lookahead_operator;
        if (lookahead_operator.binary && (tokens[index] == null)) {
          throw new Error(`missing right operand for \`${lookahead_operator.prefered}\``);
        }
        right_hand_ast_node = parse_primary();
        index += 1;
        lookahead_operator = match_operator();
        while (((lookahead_operator != null ? lookahead_operator.binary : void 0) && lookahead_operator.precedence > operator.precedence) || ((lookahead_operator != null ? lookahead_operator.right_associative : void 0) && lookahead_operator.precedence === operator.precedence)) {
          if (lookahead_operator.binary && (tokens[index] == null)) {
            throw new Error(`missing right operand for \`${lookahead_operator.prefered}\``);
          }
          index -= 2;
          right_hand_ast_node = parse_expression(right_hand_ast_node, lookahead_operator.precedence);
          index += 2;
          lookahead_operator = match_operator();
        }
        left_hand_ast_node = {
          type: "operator",
          operator,
          left_hand_ast_node,
          right_hand_ast_node
        };
      }
      if (lookahead_operator != null ? lookahead_operator.unary : void 0) {
        throw new Error("unary operator at end of expression? (missing right operand?)"); // TODO/FIXME: terrible error message
      }
      // if tokens[index + 1] and not lookahead_operator?
      // 	throw new Error "end of thing but there's more" # TODO/FIXME: worst error message
      // if tokens[index + 1]
      // 	throw new Error "end of thing but there's more" # TODO/FIXME: worst error message
      if (((ref = tokens[index + 1]) != null ? ref.type : void 0) === "newline") {
        anything_substantial_after_newline = false;
        for (i = j = ref1 = index + 1, ref2 = tokens.length - 1; (ref1 <= ref2 ? j <= ref2 : j >= ref2); i = ref1 <= ref2 ? ++j : --j) {
          if ((ref3 = tokens[i].type) !== "newline" && ref3 !== "comment" && ref3 !== "indent" && ref3 !== "dedent") {
            anything_substantial_after_newline = true;
          }
        }
        if (anything_substantial_after_newline) {
          index += 1;
          return [left_hand_ast_node, parse_expression(parse_primary(), 0)];
        }
      }
      return left_hand_ast_node;
    };
    return parse_expression(parse_primary(), 0);
  }

};


},{"./Pattern":7,"./Token":8,"./find-closing-token":9,"./library/conditionals":10,"./library/console":11,"./library/constants":12,"./library/eval-js":13,"./library/eval-ooplie":14,"./library/fs":15,"./library/operators":16,"./library/process":17,"./tokenize":19}],5:[function(require,module,exports){
var Library;

module.exports = Library = class Library {
  constructor(name, {patterns, operators, constants}) {
    this.name = name;
    this.patterns = patterns;
    this.operators = operators;
    this.constants = constants;
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

};


},{}],6:[function(require,module,exports){
var Operator, Pattern;

Pattern = require("./Pattern");

module.exports = Operator = class Operator extends Pattern {
  constructor({match, bad_match, fn, precedence, right_associative, binary, unary}) {
    super({match, bad_match, fn});
    if (precedence == null) {
      throw new Error("Operator constructor requires {precedence}");
    }
    this.precedence = precedence;
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

  match(tokens, index) {
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
  }

  bad_match() {
    throw new Error("Not implemented!");
  }

};


},{"./Pattern":7}],7:[function(require,module,exports){
var Pattern, find_closing_token, stringify_matcher, stringify_tokens, tokenize,
  indexOf = [].indexOf;

tokenize = require("./tokenize");

({stringify_tokens} = require("./Token"));

find_closing_token = require("./find-closing-token");

stringify_matcher = function(matcher) {
  return matcher.join(" ");
};

module.exports = Pattern = class Pattern {
  constructor({match, bad_match, fn}) {
    var parse_matchers;
    this.fn = fn;
    // TODO: also allow [optional phrase segments]
    // and maybe (either|or|groups)
    // TODO: try longer matchers first
    // TODO: backtracking, for e.g.
    // 	what to do = "todo items"
    // 	write what to do to "./todo.txt"

    // should it be possible to have an "action" and a "fn"?
    // like fn if it's in an expression but action if it's a statement?
    // is that even a distinction that can be made?
    // probably not
    // besides, things like eval and even conditionals can be either or both
    // how will `=` work?
    // 	a = b
    // 	if a = b, ...

    // @fn = action ? fn
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
                throw new Error(`Unexpected \`<\` within variable name in pattern \`${def}\``);
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
                  throw new Error(`Variable name \`${current_variable_name}\` used twice in pattern \`${def}\``);
                }
                if (current_variable_name === "pattern") {
                  throw new Error(`Reserved pattern variable \`pattern\` used in pattern \`${def}\``);
                }
                variable_names_used.push(current_variable_name);
                segments.push({
                  type: "variable",
                  name: current_variable_name,
                  toString: function() {
                    return `<${this.name}>`;
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
        // TODO: DRY
        results.push(segments);
      }
      return results;
    };
    this.matchers = parse_matchers(match);
    this.bad_matchers = parse_matchers(bad_match != null ? bad_match : []);
    this.prefered = match[0];
    this.prefered_matcher = this.matchers[0];
  }

  match_with(tokens, matcher) {
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
      // console.log "failed to match", stringify_tokens(tokens), "against", stringify_matcher(matcher), "(ended)"
      if (segment.type === "variable") {
        if (token.type === "newline" && ((ref = (ref1 = tokens[token_index + 1]) != null ? ref1.type : void 0) === "indent" || ref === "dedent")) {
          token_index += 1;
          continue;
        }
        if (variables[segment.name] != null) {
          next_segment = matcher[matcher_index + 1];
          if ((next_segment != null) && token_matches(token, next_segment)) {
            matcher_index += 1; // end of the variable
            continue; // do not pass go, do not increment token_index
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
      // console.log "failed to match", stringify_tokens(tokens), "against", stringify_matcher(matcher), "at", matcher_index, segment, "vs", token
      token_index += 1;
    }
    if (variables[segment.name] != null) {
      matcher_index += 1;
    }
    if (matcher_index === matcher.length) {
      // TODO: this is bad; pattern and matcher shouldn't be stuck into something called variables
      // if could be {variables, pattern, matcher} (it's a "match")
      variables.pattern = this;
      variables.matcher = matcher;
      // console.warn "matched", "`#{stringify_tokens(tokens)}`", "against", "`#{stringify_matcher(matcher)}`", @
      // console.log "got variables", variables
      // console.log "ended at index", matcher_index, "on", matcher
      return variables;
    } else {

    }
  }

  // console.log "almost matched", "`#{stringify_tokens(tokens)}`", "against", "`#{stringify_matcher(matcher)}`", @
  // console.log "got variables", variables
  // console.log "but ended at index", matcher_index, "on", matcher
  match(tokens) {
    var i, len, match, matcher, ref;
    ref = this.matchers;
    for (i = 0, len = ref.length; i < len; i++) {
      matcher = ref[i];
      match = this.match_with(tokens, matcher);
      if (match != null) {
        return match;
      }
    }
  }

  bad_match(tokens) {
    var i, len, match, matcher, ref;
    ref = this.bad_matchers;
    for (i = 0, len = ref.length; i < len; i++) {
      matcher = ref[i];
      match = this.match_with(tokens, matcher);
      if (match != null) {
        return match;
      }
    }
  }

  match_near() {}

};

// for matcher in @matchers
// 	match = @match_with(tokens, matcher, near: true)
// return best match if any

// TODO: find near-matches (i.e. differing case, typos, differing gramatical structure if possible)
// differing case is obviously usually not a problem whereas typos would be more likely to be incorrectly detected
// so differing case should probably run it and maybe suggest the proper capitalization (if it can without being wrong in context)
// whereas typos and grammar differences (with similarity algorithms applied to letters and words respectively)
// should be more of a "Did you mean?" type of deal, and should only show up if nothing else matches
// in fact the text similarity algorithm(s) shouldn't run unless no patterns match normally


},{"./Token":8,"./find-closing-token":9,"./tokenize":19}],8:[function(require,module,exports){
var Token;

module.exports = Token = class Token {
  constructor(type, col, row, value) {
    this.type = type;
    this.col = col;
    this.row = row;
    this.value = value;
  }

  // TODO: @pos = {first_line, first_column, last_line, last_column}
  // instead of @col and @row

  // toString: ->
  // 	Token.stringify_tokens([@])
  static stringify_tokens(tokens) {
    var i, len, ref, str, token;
    // @TODO: output token (with whitespace) as they were in the source
    str = "";
    for (i = 0, len = tokens.length; i < len; i++) {
      token = tokens[i];
      if (token.type === "punctuation") {
        if ((ref = token.value) === "," || ref === "." || ref === ";" || ref === ":") {
          str += token.value;
        } else {
          str += ` ${token.value}`;
        }
      } else if (token.type === "string") {
        str += ` ${JSON.stringify(token.value)}`;
      } else if (token.type === "comment") {
        str += `#${token.value}`;
      } else if (token.type === "newline") {
        str += "\n";
      } else {
        str += ` ${token.value}`;
      }
    }
    return str.trim();
  }

};


},{}],9:[function(require,module,exports){
var stringify_tokens;

({stringify_tokens} = require("./Token"));

module.exports = function(tokens, start_index) {
  var bracket_name, closing_bracket, ended, level, lookahead_index, lookahead_token, opening_bracket, opening_token;
  opening_token = tokens[start_index];
  lookahead_index = start_index;
  level = 1;
  while (true) {
    // TODO: <> maybe handle XML/HTML
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
        bracket_name = (function() {
          switch (opening_token.value) {
            case "(":
              return "parenthesis";
            case "[":
              return "square bracket";
            case "{":
              return "curly bracket";
          }
        })();
        throw new Error(`Missing closing ${bracket_name} in \`${stringify_tokens(tokens)}\``);
      } else {
        throw new Error(`Missing closing... dedent? in \`${stringify_tokens(tokens)}\`? ${JSON.stringify(tokens)}`);
      }
    }
  }
};


},{"./Token":8}],10:[function(require,module,exports){
var Library, Pattern;

Pattern = require("../Pattern");

Library = require("../Library");

module.exports = new Library("Conditionals", {
  patterns: [
    new Pattern({
      match: ["If <condition>, <body>",
    "If <condition> then <body>",
    "<body> if <condition>"],
      fn: (v) => {
        if (v("condition")) {
          return v("body");
        }
      }
    }),
    new Pattern({
      match: [
        "If <condition>, <body>, else <alt body>",
        "If <condition>, <body> else <alt body>",
        "If <condition> then <body>, else <alt body>",
        "If <condition> then <body> else <alt body>",
        "<body> if <condition> else <alt body>" // pythonic ternary
      ],
      bad_match: [
        "if <condition>, then <body>, else <alt body>",
        "if <condition>, then <body>, else, <alt body>",
        "if <condition>, <body>, else, <alt body>",
        // and other things; also this might be sort of arbitrary
        // comma misplacement should really be handled dynamically by the near-match system
        "<condition> ? <body> : <alt body>",
        "unless <condition>, <alt body> else <body>",
        "unless <condition>, <alt body>, else <body>",
        "unless <condition> then <alt body>, else <body>",
        "unless <condition> then <alt body>, else, <body>",
        "unless <condition>, then <alt body>, else <body>",
        "unless <condition>, then <alt body>, else, <body>"
      ],
      fn: (v) => {
        if (v("condition")) {
          return v("body");
        } else {
          return v("alt body");
        }
      }
    }),
    new Pattern({
      match: ["Unless <condition>, <body>",
    "<body> unless <condition>"],
      bad_match: ["Unless <condition> then <body>"], // not good English
      fn: (v) => {
        if (!v("condition")) {
          return v("body");
        }
      }
    }),
    new Pattern({
      match: ["<body> unless <condition> in which case <alt body>",
    "<body>, unless <condition> in which case <alt body>",
    "<body> unless <condition>, in which case <alt body>",
    "<body>, unless <condition>, in which case <alt body>",
    "<body> unless <condition> in which case just <alt body>",
    "<body>, unless <condition> in which case just <alt body>",
    "<body> unless <condition>, in which case just <alt body>",
    "<body>, unless <condition>, in which case just <alt body>"],
      bad_match: [
        "Unless <condition>, <body>, else <alt body>",
        "Unless <condition> then <body>, else <alt body>",
        "Unless <condition> then <body> else <alt body>",
        "<body> unless <condition> else <alt body>", // psuedo-pythonic ternary
        "<body> or if <condition> else <alt body>",
        "<body>, or if <condition>, <alt body>",
        "<body>, or if <condition> <alt body>",
        "<body> or if <condition>, <alt body>"
      ],
      fn: (v) => {
        if (!v("condition")) {
          return v("body");
        } else {
          return v("alt body");
        }
      }
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
      match: ["Output <text>",
    "Output <text> to the console",
    "Log <text>",
    "Log <text> to the console",
    "Print <text>",
    "Print <text> to the console",
    "Say <text>"],
      bad_match: [
        "puts <text>",
        "println <text>",
        "print line <text>", // you can only output one or more lines
        "printf <text>",
        "console.log <text>",
        "writeln <text>",
        "output <text> to the terminal",
        "log <text> to the terminal",
        "print <text> to the terminal"
      ],
      fn: (v,
    context) => {
        context.console.log(v("text"));
      }
    }),
    new Pattern({
      match: ["Clear the console",
    "Clear console"],
      bad_match: ["Clear the terminal",
    "Clear terminal",
    "clear",
    "cls",
    "clr"],
      fn: (v,
    context) => {
        context.console.clear();
      }
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
    "infinity": 2e308,
    "∞": 2e308,
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
      match: ["Run JS <text>",
    "Run JavaScript <text>",
    "Run <text> as JS",
    "Run <text> as JavaScript",
    "Execute JS <text>",
    "Execute JavaScript <text>",
    "Execute <text> as JS",
    "Execute <text> as JavaScript",
    "Eval JS <text>",
    "Eval JavaScript <text>",
    "Eval <text> as JS",
    "Eval <text> as JavaScript"],
      bad_match: [
        // TODO: these two should be maybe_matches
        // and eval-ooplie should have them defined as well
        // and it should ask you to disambiguate between them
        "Eval <text>", // as what? (should the error message say something like "as what?"?)
        "Run <text>", // ditto
        "Execute <text>", // ditto
        "JavaScript <text>", // not sure JavaScript is a verb
        "JS <text>" // ditto
      ],
      fn: (v,
    context) => {
        var console;
        ({console} = context); // bring context's console into scope as "console"
        return eval(v("text"));
      }
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
      match: ["Interpret <text> as English",
    "Run <text> as English",
    "Execute <text> as English",
    "Eval <text> as English",
    "Interpret <text> as Ooplie code",
    "Run <text> as Ooplie code",
    "Execute <text> as Ooplie code",
    "Eval <text> as Ooplie code",
    "Run code <text> with Ooplie",
    "Eval code <text> with Ooplie",
    "Execute code <text> with Ooplie",
    "Interpret code <text> with Ooplie",
    "Run Ooplie code <text>",
    "Eval Ooplie code <text>",
    "Execute Ooplie code <text>",
    "Interpret Ooplie code <text>",
    "Run English <text>",
    "Eval English <text>",
    "Execute English <text>",
    "Interpret <text> with Ooplie",
    "Run <text> with Ooplie",
    "Eval <text> with Ooplie",
    "Execute <text> with Ooplie"],
      bad_match: ["Run Ooplie <text>",
    "Eval Ooplie <text>",
    "Execute Ooplie <text>",
    "Interpret Ooplie <text>",
    "Run <text> as Ooplie",
    "Run code <text> as Ooplie",
    "Execute <text> as Ooplie",
    "Execute <text> as Ooplie",
    "Eval <text> as Ooplie",
    "Eval code <text> as Ooplie",
    "Run code <text> as English",
    "Run English code <text>",
    "Eval English code <text>",
    "Execute English code <text>",
    "Interpret English code <text>",
    "Run English code <text>",
    "Eval <text> as English code",
    "Execute English code <text>",
    "Interpret <text> as English code",
    "Make Ooplie Interpret <text>",
    "Have Ooplie Interpret <text>",
    "Let Ooplie Interpret <text>"],
      fn: (v,
    context) => {
        return context.eval(v("text"));
      }
    })
  ]
});


},{"../Library":5,"../Pattern":7}],15:[function(require,module,exports){
var Library, Pattern, fs, path;

fs = require("fs");

path = require("path");

Pattern = require("../Pattern");

Library = require("../Library");

// hack to avoid browserify builtin "fs" module
if ((typeof window !== "undefined" && window !== null ? window.require : void 0) != null) {
  fs = window.require("fs");
}

module.exports = new Library("File System", {
  patterns: [
    
    // TODO: async! use streams and/or promises

    // TODO: probably should take an object-oriented approach, i.e.
    // 	output the file's contents and delete it # (it = the file)
    // once we have some OOP facilities

    // TODO: if it doesn't exist, unless it exists, unless it already exists
    // unless there's already a file there, [in which case]...

    // TODO (maybe): "{if/whether} we're [already] [currently] {writing to/reading from} {a file/'foo.txt'}"?

    // TODO: globbing (how?)
    new Pattern({
      match: ["Make directory <dir>",
    "Create directory <dir>",
    "Make folder <dir>",
    "Create folder <dir>"],
      bad_match: ["Make dir <dir>",
    "Create dir <dir>",
    "mkdir <dir>"],
      fn: (v) => {
        return fs.mkdirSync(v("dir"));
      }
    }),
    new Pattern({
      match: ["Make directories <dir>",
    "Create directories <dir>",
    "Make folders <dir>",
    "Create folders <dir>"],
      bad_match: ["Make directories recursively <dir>",
    "Create directories recursively <dir>",
    "Make dirs recursively <dir>",
    "Create dirs recursively <dir>",
    "Make dirs <dir>",
    "Create dirs <dir>",
    "Make path <dir>",
    "Create path <dir>",
    "mkdirp <dir>",
    "mkdirs <dir>"],
      fn: (v) => {
        throw new Error("Not implemented (needs an npm module)");
      }
    }),
    new Pattern({
      match: ["Make directories for <file path>",
    "Create directories <file path>",
    "Make all the directories for <file path>",
    "Create all the directories for <file path>",
    "Make folders for <file path>",
    "Create folders for <file path>",
    "Make all the folders for <file path>",
    "Create all the folders for <file path>"],
      fn: (v) => {
        var dir;
        dir = path.dirname(v("file path"));
        throw new Error("Not implemented (needs an npm module)");
      }
    }),
    new Pattern({
      match: ["Remove directory <dir>",
    "Delete directory <dir>",
    "Remove folder <dir>",
    "Delete folder <dir>"],
      bad_match: ["Unlink directory <dir>",
    "Unlink folder <dir>",
    "Unlink dir <dir>",
    "Unlink <dir>",
    "rmdir <dir>"],
      fn: (v) => {
        return fs.rmdirSync(v("dir"));
      }
    }),
    new Pattern({
      match: ["Write <data> to file <file>",
    "Write <data> to <file>",
    "Write file <file> with content <data>",
    "Write <file> with content <data>",
    "Write to <file>: <data>",
    "Write to file <file>: <data>",
    "Write <file>: <data>"],
      fn: (v) => {
        return fs.writeFileSync(v("file"),
    v("data"));
      }
    }),
    new Pattern({
      match: ["Append <data> to file <file>",
    "Append <data> to <file>",
    "Write <data> to the end of <file>"],
      bad_match: ["Append <data> to the end of <file>",
    "Prepend <data> to the end of <file>"],
      fn: (v) => {
        return fs.appendFileSync(v("file"),
    v("data"));
      }
    }),
    new Pattern({
      match: ["Prepend <data> to file <file>",
    "Prepend <data> to <file>",
    "Write <data> to the beginning of <file>"],
      bad_match: ["Prepend <data> to the beginning of <file>",
    "Append <data> to the beginning of <file>"],
      fn: (v) => {
        var e,
    existing_data,
    file_path,
    prepend_data;
        file_path = v("file");
        prepend_data = v("data");
        try {
          existing_data = fs.readFileSync(file_path,
    "utf8");
        } catch (error) {
          e = error;
          if (e.code !== "ENOENT") {
            throw e;
          }
          existing_data = "";
        }
        return fs.writeFileSync(file_path,
    prepend_data + existing_data);
      }
    }),
    new Pattern({
      match: ["Read from <file>",
    "Read file <file>",
    "Read <data> from <file>",
    "Read <file>"],
      fn: (v) => {
        return fs.readFileSync(v("file"),
    "utf8");
      }
    }),
    // TODO: export variable data
    // if you say "Read JSON from data.json",
    // 	it should define a variable called "JSON"
    // otherwise
    // 	it should define a variable called "data" and/or "the file's contents"
    new Pattern({
      match: [
        "Read from <file> as a buffer",
        "Read file <file> as a buffer",
        // "Read <data> from <file> as a buffer"
        // TODO: match the above first but prefer this variation:
        "Read <file> as a buffer"
      ],
      bad_match: ["Read from <file> as buffer",
    "Read file <file> as buffer",
    "Read <file> as buffer"],
      fn: (v) => {
        return fs.readFileSync(v("file"));
      }
    }),
    // TODO: export variable "the buffer" and maybe also "the file's contents"
    // "buffer contents"?
    // "...as buffer A", "as buffer 1", "as the initial memory buffer"...
    new Pattern({
      match: ["Delete file <file>",
    "Delete <file>",
    "Remove file <file>",
    "Remove <file>"],
      fn: (v) => {
        return fs.unlinkSync(v("file"));
      }
    }),
    new Pattern({
      match: ["we have permission to read from <file>",
    "we have permission to read <file>",
    "I have permission to read from <file>",
    "I have permission to read <file>",
    "we can read from <file>",
    "we can read <file>",
    "I can read from <file>",
    "I can read <file>"],
      // "Do (we|I) have permission to read [from] <file>?"
      fn: (v) => {
        var e;
        try {
          // fs.access v("file"), fs.R_OK, (err)->
          fs.accessSync(v("file"),
    fs.R_OK);
        } catch (error) {
          e = error;
          if (e.code !== "EPERM") {
            throw e;
          }
          return false;
        }
        return true;
      }
    }),
    new Pattern({
      match: ["we have permission to write to <file>",
    "we have permission to write <file>",
    "I have permission to write to <file>",
    "I have permission to write <file>",
    "we can write to <file>",
    "we can write <file>",
    "I can write to <file>",
    "I can write <file>"],
      // "Do (we|I) have permission to write [to] <file>?"
      fn: (v) => {
        var e;
        try {
          // fs.access v("file"), fs.W_OK, (err)->
          fs.accessSync(v("file"),
    fs.W_OK);
        } catch (error) {
          e = error;
          if (e.code !== "EPERM") {
            throw e;
          }
          return false;
        }
        return true;
      }
    }),
    new Pattern({
      match: ["stdout",
    "standard out"],
      fn: (v) => {
        // process.stdout # stream
        return 1; // file descriptor
      }
    }),
    new Pattern({
      match: ["stdin",
    "standard in"],
      fn: (v) => {
        // process.stdin # stream
        return 0; // file descriptor
      }
    }),
    new Pattern({
      match: ["stderr",
    "standard error"],
      bad_match: ["standarderror",
    "standard err",
    "std error",
    "stderror",
    "std err"],
      fn: (v) => {
        // process.stderr # stream
        return 2; // file descriptor
      }
    }),
    new Pattern({
      match: [
        "list directory contents",
        "list folder contents",
        "list current directory contents",
        "list current folder contents",
        "list contents of the current directory",
        "list contents of the current folder",
        "list the contents of the current directory",
        "list the contents of the current folder",
        "list files and subdirectories",
        "list files and directories",
        // "enum dir contents"
        // "'numerate d'rectory 'tents"
        "ls"
      ],
      bad_match: ["list dir contents",
    "list current dir contents",
    "list contents of the current dir",
    "list the contents of the current dir"],
      fn: (v) => {
        var directory;
        directory = ".";
        return fs.readdirSync(directory).map(function(fname) {
          return path.join(directory,
    fname);
        });
      }
    }),
    new Pattern({
      match: ["list files",
    "list files in the current directory",
    "list the files in the current directory"],
      fn: (v) => {
        var directory;
        directory = ".";
        return fs.readdirSync(directory).map(function(fname) {
          return path.join(directory,
    fname);
        }).filter(function(fname) {
          return fs.statSync(fname).isFile();
        });
      }
    }),
    new Pattern({
      match: ["list subdirectories",
    "list subfolders",
    "list directories",
    "list folders",
    "list folders in the current directory",
    "list the folders in the current directory",
    "list folders in the current folder",
    "list the folders in the current folder"],
      fn: (v) => {
        var directory;
        directory = ".";
        return fs.readdirSync(directory).map(function(fname) {
          return path.join(directory,
    fname);
        }).filter(function(fname) {
          return fs.statSync(fname).isDirectory();
        });
      }
    })
  ]
});


// TODO: "go up one level", "go up 5 folders"
// "To go up N levels, go up N times"


},{"../Library":5,"../Pattern":7,"fs":3,"path":1}],16:[function(require,module,exports){
var Library, Operator;

Operator = require("../Operator");

Library = require("../Library");

// Should there be separate libraries for Comparison, Arithmetic?
// Should Set Operators go in Sets?
// Maybe we should just have categories.
module.exports = new Library("Operators", {
  operators: [
    new Operator({
      match: ["^",
    "to the power of"],
      bad_match: ["**"],
      precedence: 3,
      right_associative: true,
      fn: function(lhs,
    rhs) {
        return Math.pow(lhs,
    rhs);
      }
    }),
    new Operator({
      match: ["×",
    "*",
    "times",
    "multiplied by"],
      bad_match: [
        "✖", // heavy multiplication X
        "⨉", // n-ary times operator
        "⨯", // vector or cross-product
        "∗", // asterisk operator
        "⋅", // dot operator
        "∙", // bullet operator
        "•", // bullet (are you kidding me?)
        "✗", // ballot
        "✘" // heavy ballot
      ],
      precedence: 2,
      fn: function(lhs,
    rhs) {
        return lhs * rhs;
      }
    }),
    new Operator({
      match: [
        "÷", // obelus
        "/", // slash
        "∕", // division slash
        "divided by"
      ],
      bad_match: [
        "／", // fullwidth solidus
        "⁄" // fraction slash
      ],
      precedence: 2,
      fn: function(lhs,
    rhs) {
        return lhs / rhs;
      }
    }),
    new Operator({
      match: ["+",
    "plus"],
      bad_match: [
        "＋", // fullwidth plus
        "﬩" // Hebrew alternative plus sign (only English is supported, plus + is the internationally standard plus symbol) 
      ],
      precedence: 1,
      fn: function(lhs,
    rhs) {
        return lhs + rhs;
      }
    }),
    new Operator({
      match: [
        "−", // minus
        "-", // hyphen-minus
        "minus"
      ],
      precedence: 1,
      fn: function(lhs,
    rhs) {
        return lhs - rhs;
      }
    }),
    new Operator({
      match: [
        "−", // minus
        "-", // hyphen-minus
        "negative",
        "the opposite of"
      ],
      bad_match: ["minus"],
      precedence: 1,
      right_associative: true,
      unary: true,
      fn: function(rhs) {
        return -rhs;
      }
    }),
    new Operator({
      match: ["+",
    "positive"],
      bad_match: ["plus"],
      precedence: 1,
      right_associative: true,
      unary: true,
      fn: function(rhs) {
        return +rhs;
      }
    }),
    new Operator({
      match: ["≥",
    ">=",
    "is greater than or equal to"],
      bad_match: ["is more than or equal to"],
      precedence: 0,
      fn: function(lhs,
    rhs) {
        return lhs >= rhs;
      }
    }),
    new Operator({
      match: ["≤",
    "<=",
    "is less than or equal to"],
      precedence: 0,
      fn: function(lhs,
    rhs) {
        return lhs <= rhs;
      }
    }),
    new Operator({
      match: [">",
    "is greater than"],
      bad_match: ["is more than"],
      precedence: 0,
      fn: function(lhs,
    rhs) {
        return lhs > rhs;
      }
    }),
    new Operator({
      match: ["<",
    "is less than"],
      precedence: 0,
      fn: function(lhs,
    rhs) {
        return lhs < rhs;
      }
    }),
    new Operator({
      match: ["≠",
    "!=",
    "does not equal",
    "is not equal to",
    "isn't",
    "is not"],
      bad_match: [
        "isnt", // this isn't CoffeeScript, you can actually punctuate contractions
        "isnt equal to", // ditto
        "isn't equal to" // this sounds slightly silly to me
      ],
      precedence: 0,
      fn: function(lhs,
    rhs) {
        return lhs !== rhs;
      }
    }),
    new Operator({
      match: ["=",
    "equals",
    "is equal to",
    "is"],
      bad_match: ["==",
    "==="],
      precedence: 0,
      fn: function(lhs,
    rhs) {
        // if a.every((token)-> token.type is "word")
        // 	name = a.join(" ")
        // 	value = @eval_tokens(b)
        // 	if @constants.has(name)
        // 		unless @constants.get(name) is value
        // 			throw new Error "#{name} is already defined as #{@constants.get(name)} (which does not equal #{value})"
        // 	else if @constants.has(name)
        // 		unless @constants.get(name) is value
        // 			throw new Error "#{name} is already defined as #{@variables.get(name)} (which does not equal #{value})"
        // 	else
        // 		@variables.set(name, value)
        // else
        return lhs === rhs;
      }
    })
  ]
});


},{"../Library":5,"../Operator":6}],17:[function(require,module,exports){
var Library, Pattern, process;

Pattern = require("../Pattern");

Library = require("../Library");

// should we have a Process library and a Child Processes library following node?
// or should we have a Process libary and a Processes library and have kill <pid> in the latter?
// we could mainly just go with node but I don't know
// the chdir stuff doesn't seem right here

// hack to avoid browserify builtin "process" object
// FIXME: it still includes the whole shim
if (typeof window !== "undefined" && window !== null ? window.global : void 0) {
  process = window.global.process;
}

module.exports = new Library("Process", {
  patterns: [
    
    // TODO: if it doesn't exist, unless it exists, unless it already exists
    // unless there's already a file there, in which case...

    // TODO: "if we're writing to a file"? "whether we're reading from a file"?

    // TODO: async! use streams and/or promises

    // TODO: probably should take an object-oriented approach, i.e.
    // 	output the file's contents and delete the file
    // once we have some OOP facilities

    // TODO: globbing (how?)
    new Pattern({
      match: ["Exit the program",
    "Exit this process",
    "Exit the process",
    "Exit"],
      bad_match: ["Exit this program",
    "End this process",
    "Exit process",
    "End process",
    "Exit program",
    "End program"],
      fn: (v) => {
        return process.exit();
      }
    }),
    new Pattern({
      match: ["Exit with code <code>",
    "Exit the program with code <code>",
    "Exit this process with code <code>",
    "Exit the process with code <code>"],
      bad_match: ["Exit this program with code <code>",
    "End this process with code <code>",
    "Exit process with code <code>",
    "End process with code <code>",
    "Exit program with code <code>",
    "End program with code <code>"],
      fn: (v) => {
        return process.exit(v("code"));
      }
    }),
    new Pattern({
      match: ["Kill process <pid>",
    "End process <pid>"],
      // depends whether it's an integer
      // TODO: facilitate distinguishing this
      // possibly with a... type system!?
      maybe_match: ["Kill <pid>",
    "End <pid>"],
      fn: (v) => {
        return process.kill(v("pid"));
      }
    }),
    new Pattern({
      match: ["command-line arguments"],
      bad_match: ["command line arguments",
    "arguments from the command-line",
    "argv"],
      maybe_match: ["arguments",
    "args"],
      fn: (v) => {
        return process.argv;
      }
    }),
    new Pattern({
      match: ["current memory usage",
    "this process's memory usage",
    "process memory usage",
    "memory usage of this process",
    "memory usage"],
      // "How much memory is this process using?"
      bad_match: ["process memory"],
      fn: (v) => {
        // TODO: return a number with a unit
        return process.memoryUsage();
      }
    }),
    new Pattern({
      match: ["Set the process's title to <text>",
    "Name the process <text>"],
      bad_match: ["Call the process <text>"],
      fn: (v) => {
        return process.title = v("text");
      }
    }),
    new Pattern({
      match: ["the process's title",
    "the name of the process"],
      bad_match: ["the process title"],
      fn: (v) => {
        return process.title;
      }
    }),
    new Pattern({
      match: ["the working directory",
    "the current directory",
    "working directory",
    "current directory"],
      bad_match: ["the working dir",
    "the current dir",
    "working dir",
    "current dir",
    "pwd",
    "cwd"],
      fn: (v) => {
        return process.cwd();
      }
    }),
    new Pattern({
      match: ["change directory to <path>",
    "change working directory to <path>",
    "change current directory to <path>",
    "set working directory to <path>",
    "set current directory to <path>",
    "enter directory <path>",
    "go to directory <path>",
    "enter folder <path>",
    "go to folder <path>"],
      bad_match: ["enter dir <path>",
    "go to dir <path>",
    "change working dir to <path>",
    "change current dir to <path>",
    "cd into <path>",
    "cd to <path>",
    "cd <path>",
    "chdir into <path>",
    "chdir to <path>",
    "chdir <path>",
    "set directory to <path>",
    "change dir to <path>",
    "set cwd to <path>"],
      fn: (v) => {
        return process.chdir(v("path"));
      }
    }),
    new Pattern({
      match: ["go up",
    "go out of this folder",
    "exit folder",
    "exit this folder"],
      bad_match: ["cd .."],
      fn: (v) => {
        return process.chdir("..");
      }
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

module.exports = {Context, Library, Pattern, Operator, Token, tokenize};


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
          throw new Error(`Mixed indentation between lines ${line_index} and ${line_index + 1} at column ${column_index + 1}`);
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
  
  // TODO?
  // if indentation.length < indent_level
  // 	tokens.push(new Token("dedent", row, col, indentation))
  // 	indent_level = indentation.length
  start_string = function(char) {
    next_type = "string";
    quote_char = char;
    string_content_on_first_line = false;
    string_first_newline_found = false;
    string_content_started = false;
    return string_content_indentation = null;
  };
  finish_token = function() {
    // TODO: move this conditional parseFloat outside of the tokenizer
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
            throw new Error(`Unknown backslash escape \\${char} (Do you need to escape the backslash with another backslash?)`);
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
        // TODO: support spaces
        match = source.slice(0, i + 1).match(/\n([\t\ ]*)$/);
        // console.log {source, row, col, match}
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
          // e.g. it's, isn't, doesn't, shouldn't etc.
          // (but not e.g. 'tis or fightin', sadly)
          next_type = "word";
        } else {
          start_string(char);
        }
      } else if (char === '"') {
        start_string(char);
      } else if (char.match(/\s/)) {
        next_type = null;
      } else {
        // else if char.match(/[,!?@#$%^&*\(\)\[\]\{\}<>\/\|\\\-+=~:;]/)
        // 	next_type = "punctuation"
        // else
        // 	next_type = "unknown"
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
    throw new Error(`Missing end quote (${quote_char}) for string at row ${row}, column ${col}`);
  }
  finish_token();
  handle_indentation(i, row, col);
  return tokens;
};


},{"./Token":8}]},{},[18])(18)
});