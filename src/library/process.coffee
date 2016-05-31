
Pattern = require "../Pattern"
Library = require "../Library"

# should we have a Process library and a Child Processes library following node?
# or should we have a Process libary and a Processes library and have kill <pid> in the latter?
# we could mainly just go with node but I don't know
# the chdir stuff doesn't seem right here

# hack to avoid browserify builtin "process" object
# FIXME: it still includes the whole shim
if window?.global
	process = window.global.process

module.exports = new Library "Process", patterns: [
	
	# TODO: if it doesn't exist, unless it exists, unless it already exists
	# unless there's already a file there, in which case...
	
	# TODO: "if we're writing to a file"? "whether we're reading from a file"?
	
	# TODO: async! use streams and/or promises
	
	# TODO: probably should take an object-oriented approach, i.e.
	# 	output the file's contents and delete the file
	# once we have some OOP facilities
	
	# TODO: globbing (how?)
	
	new Pattern
		match: [
			"Exit the program"
			"Exit this process"
			"Exit the process"
			"Exit"
		]
		bad_match: [
			"Exit this program"
			"End this process"
			"Exit process"
			"End process"
			"Exit program"
			"End program"
		]
		fn: (v)=>
			process.exit()
	
	new Pattern
		match: [
			"Exit with code <code>"
			"Exit the program with code <code>"
			"Exit this process with code <code>"
			"Exit the process with code <code>"
		]
		bad_match: [
			"Exit this program with code <code>"
			"End this process with code <code>"
			"Exit process with code <code>"
			"End process with code <code>"
			"Exit program with code <code>"
			"End program with code <code>"
		]
		fn: (v)=>
			process.exit(v("code"))
	
	new Pattern
		match: [
			"Kill process <pid>"
			"End process <pid>"
		]
		maybe_match: [
			# depends whether it's an integer
			# TODO: facilitate distinguishing this
			# possibly with a... type system!?
			"Kill <pid>"
			"End <pid>"
		]
		fn: (v)=>
			process.kill(v("pid"))
	
	new Pattern
		match: [
			"command-line arguments"
		]
		bad_match: [
			"command line arguments"
			"arguments from the command-line"
			"argv"
		]
		maybe_match: [
			"arguments"
			"args"
		]
		fn: (v)=>
			process.argv
	
	new Pattern
		match: [
			"current memory usage"
			"this process's memory usage"
			"process memory usage"
			"memory usage of this process"
			"memory usage"
			# "How much memory is this process using?"
		]
		bad_match: [
			"process memory"
		]
		fn: (v)=>
			# TODO: return a number with a unit
			process.memoryUsage()
	
	new Pattern
		match: [
			"Set the process's title to <text>"
			"Name the process <text>"
		]
		bad_match: [
			"Call the process <text>"
		]
		fn: (v)=>
			process.title = v("text")
	
	new Pattern
		match: [
			"the process's title"
			"the name of the process"
		]
		bad_match: [
			"the process title"
		]
		fn: (v)=>
			process.title
	
	new Pattern
		match: [
			"the working directory"
			"the current directory"
			"working directory"
			"current directory"
		]
		bad_match: [
			"the working dir"
			"the current dir"
			"working dir"
			"current dir"
			"pwd"
			"cwd"
		]
		fn: (v)=>
			process.cwd()
	
	new Pattern
		match: [
			"change directory to <path>"
			"change working directory to <path>"
			"change current directory to <path>"
			"set working directory to <path>"
			"set current directory to <path>"
			"enter directory <path>"
			"go to directory <path>"
			"enter folder <path>"
			"go to folder <path>"
		]
		bad_match: [
			"enter dir <path>"
			"go to dir <path>"
			"change working dir to <path>"
			"change current dir to <path>"
			"cd into <path>"
			"cd to <path>"
			"cd <path>"
			"chdir into <path>"
			"chdir to <path>"
			"chdir <path>"
			"set directory to <path>"
			"change dir to <path>"
			"set cwd to <path>"
		]
		fn: (v)=>
			process.chdir(v("path"))
	
	new Pattern
		match: [
			"go up"
			"go out of this folder"
			"exit folder"
			"exit this folder"
		]
		bad_match: [
			"cd .."
		]
		fn: (v)=>
			process.chdir("..")
	
]
