
Pattern = require "../Pattern"
Library = require "../Library"

# should we have a Process library and a Child Processes library following node?
# or should we have a Process libary and a Processes library and have kill <pid> in the latter?
# we should probably just go with node but we'll see

module.exports = new Library "Process(es)", patterns: [
	
	# TODO: if it doesn't exist, unless it exists, unless it already exists
	# unless there's already a file there, in which case...
	
	# TODO: "if we're writing to a file"? "whether we're reading to a file"?
	
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
			"memory usage of this process"
			"memory usage"
			# "How much memory is this process using?"
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
	
]
