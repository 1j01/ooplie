#!/usr/bin/env node

var fs = require("fs");
var Ooplie = require("../ooplie.js");
var argv = require("minimist")(process.argv.slice(2))

if (argv.version || argv.v) {
	console.log(`v${require("../package.json").version}`);
}else if (argv.usage || argv.help || argv.h || argv._.length === 0) {
	console.log(`
Execute English as code.

Usage: ooplie [options...] [script]

Options:
  -h, --help       Print usage information and exit.
  -v, --version    Print version number and exit.
`);
}else{
	if(argv._.length > 1){
		console.error("Only one script can be executed. Paths with spaces must be enclosed in quotes.");
		process.exit(1);
	}
	var context = new Ooplie.Context({console});
	// TODO: friendlier ENOENT errors
	var code = fs.readFileSync(argv._[0], "utf8");
	context.eval(code);
}
