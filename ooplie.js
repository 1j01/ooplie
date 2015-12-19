(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.OOPLiE = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Context;

module.exports = Context = (function() {
  function Context() {}

  Context.prototype.interpret = function(text, callback) {
    var e, error, error1, result;
    if (text.match(/^((Well|So),? )?(Hi|Hello|Hey|Greetings|Hola)/i)) {
      return callback(null, (text.match(/^[A-Z]/) ? "Hello" : "hello") + (text.match(/\.|!/) ? "." : ""));
    } else if (text.match(/^((Well|So),? )?(What'?s up)/i)) {
      return callback(null, (text.match(/^[A-Z]/) ? "Not much" : "not much") + (text.match(/\?|!/) ? "." : ""));
    } else if (text.match(/^>?[:;8X][()O3PCD]$/i)) {
      return callback(null, text);
    } else if (text.match(/^\?|help/i)) {
      return callback(null, "Sorry, I can't help.");
    } else if (text.match(/^(Create|Make|Do|Just)/i)) {
      return callback(new Error("I don't know how to do that."));
    } else if (text.match(/\(*(new )?\(*(window|global)(\.|\[)/)) {
      error = null;
      try {
        result = eval(text);
      } catch (error1) {
        e = error1;
        error = e;
      }
      return callback(error, result);
    } else if (Math.random() < 0.5) {
      return callback(new Error("Nothing happened."));
    } else {
      return callback(null, text + "?");
    }
  };

  return Context;

})();


},{}],2:[function(require,module,exports){
module.exports.Context = require('./Context');


},{"./Context":1}]},{},[2])(2)
});