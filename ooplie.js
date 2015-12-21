/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/*!***************************!*\
  !*** ./src/ooplie.coffee ***!
  \***************************/
/***/ function(module, exports, __webpack_require__) {

	module.exports.Context = __webpack_require__(/*! ./Context.coffee */ 1);


/***/ },
/* 1 */
/*!****************************!*\
  !*** ./src/Context.coffee ***!
  \****************************/
/***/ function(module, exports) {

	var Context;
	
	module.exports = Context = (function() {
	  function Context(arg) {
	    this.console = arg.console;
	  }
	
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
	    } else if (text.match(/^\?|clear/i)) {
	      if (this.console != null) {
	        this.console.clear();
	        return callback(null, "Console cleared.dfsdfsdfgdfg");
	      } else {
	        return callback(new Error("No console to clear."));
	      }
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
	    } else {
	      return callback(new Error("I don't understand."));
	    }
	  };
	
	  return Context;

	})();


/***/ }
/******/ ]);
//# sourceMappingURL=ooplie.js.map