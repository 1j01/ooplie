(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.Ooplie = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Context, lex;

lex = require("./lex");

module.exports = Context = (function() {
  function Context(arg) {
    var ref;
    ref = arg != null ? arg : {}, this.console = ref.console, this.supercontext = ref.supercontext;
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

  Context.prototype.interpret = function(text, callback) {
    var token;
    if (text.match(/^((Well|So|Um|Uh),? )?(Hi|Hello|Hey|Greetings|Hola)/i)) {
      return callback(null, (text.match(/^[A-Z]/) ? "Hello" : "hello") + (text.match(/\.|!/) ? "." : ""));
    } else if (text.match(/^((Well|So|Um|Uh),? )?(What'?s up|Sup)/i)) {
      return callback(null, (text.match(/^[A-Z]/) ? "Not much" : "not much") + (text.match(/\?|!/) ? "." : ""));
    } else if (text.match(/^>?[:;8X][()O3PCD]$/i)) {
      return callback(null, text);
    } else if (text.match(/^\?|help/i)) {
      return callback(null, "Sorry, I can't help.");
    } else if (text.match(/^(clr|clear)( console| output)?/i)) {
      if (this.console != null) {
        this.console.clear();
        return callback(null, "Console cleared.");
      } else {
        return callback(new Error("No console to clear."));
      }
    } else {
      console.log(text);
      console.log(lex(text));
      return console.log.apply(console, (function() {
        var i, len, ref, results;
        ref = lex(text);
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          token = ref[i];
          results.push(token.value);
        }
        return results;
      })());
    }
  };

  return Context;

})();


},{"./lex":2}],2:[function(require,module,exports){
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
            throw new Error("Mixed indentation between lines " + line_index + " and " + (line_index + 1) + " on column " + (column_index + 1));
          }
        }
      }
      results.push(previous_indentation = indentation);
    }
    return results;
  };

  Lexer.prototype.tokenize = function(source) {
    var char, col, current_token_string, current_type, finish_token, handle_indentation, i, indent, is_last_newline, j, len, next_char, next_type, quote_char, ref, row, start_string, string_content_indentation, string_content_started, string_first_newline_cannot_be_ignored, string_first_newline_found, string_last_newline_cannot_be_ignored, tabs_before, tokens, whitespace_after;
    this.check_indentation(source);
    tokens = [];
    row = 1;
    col = 1;
    current_type = null;
    next_type = null;
    current_token_string = "";
    quote_char = null;
    string_first_newline_cannot_be_ignored = false;
    string_last_newline_cannot_be_ignored = false;
    string_first_newline_found = false;
    string_content_started = false;
    string_content_indentation = null;
    indent = [0];
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
      if (indentation.length > indent[0]) {
        indent.unshift(indentation.length);
        tokens.push(new Token("indent", row, col, indentation));
        return;
      }
      results = [];
      while (indentation.length < indent[0]) {
        tokens.push(new Token("dedent", row, col, indentation));
        results.push(indent.shift());
      }
      return results;
    };
    start_string = function(char) {
      next_type = "string";
      quote_char = char;
      string_first_newline_cannot_be_ignored = false;
      string_last_newline_cannot_be_ignored = false;
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
    for (i = j = 0, len = source.length; j < len; i = ++j) {
      char = source[i];
      next_char = (ref = source[i + 1]) != null ? ref : "";
      next_type = current_type;
      if (current_type === "string") {
        if (char === quote_char) {
          next_type = null;
          console.log("end string", current_token_string);
          finish_token();
        } else if (char === "\n") {
          whitespace_after = source.slice(i).match(/^\s*/m);
          is_last_newline = source[i + whitespace_after.length] === quote_char;
          if (string_first_newline_found || string_first_newline_cannot_be_ignored) {
            if (!(is_last_newline && !string_last_newline_cannot_be_ignored)) {
              current_token_string += char;
            }
          }
          string_first_newline_found = true;
        } else if (char === "\t") {
          tabs_before = source.slice(0, i - 1).match(/\t*$/m);
          console.log(row, col, source, indent, indent.length, tabs_before.length);
          if (tabs_before.length > indent.length) {
            current_token_string += char;
          }
        } else {
          if (!string_first_newline_found) {
            string_first_newline_cannot_be_ignored = true;
          }
          current_token_string += char;
        }
      } else {
        if (char.match(/\d/)) {
          next_type = "number";
        } else if (char === ".") {
          if (next_char.match(/\d/)) {
            next_type = "number";
          } else {
            next_type = "punctuation";
          }
        } else if (char.match(/[,!?@#$%^&*\(\)\[\]\{\}<>\|\\\-+=~:;]/)) {
          next_type = "punctuation";
        } else if (char.match(/[a-z]/i)) {
          next_type = "word";
        } else if (char.match(/'/)) {
          if (current_type === "word" && next_char.match(/[a-z]/i)) {
            next_type = "word";
          } else {
            start_string(char);
          }
        } else if (char.match(/"/)) {
          start_string(char);
        } else if (char === "\n") {
          handle_indentation(i, row, col);
        } else if (char.match(/\s/)) {
          next_type = null;
        } else {
          next_type = "unknown";
        }
        if (next_type !== current_type) {
          finish_token();
        }
        current_type = next_type;
        if (next_type !== "string") {
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

  return Token;

})();

module.exports = function(source) {
  var lexer;
  lexer = new Lexer;
  return lexer.lex(source);
};


},{}],3:[function(require,module,exports){
module.exports.Context = require('./Context');

module.exports.lex = require('./lex');


},{"./Context":1,"./lex":2}]},{},[3])(3)
});