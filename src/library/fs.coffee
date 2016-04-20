
fs = require "fs"

Pattern = require "../Pattern"
Library = require "../Library"

module.exports = new Library "File System", patterns: [
	
	# TODO: if it doesn't exist, unless it exists, unless it already exists
	# unless there's already a file there, in which case...
	
	# TODO: "if we're writing to a file"?
	
	# TODO: async! use streams and/or promises
	
	# TODO: probably should take an object-oriented approach, i.e.
	# 	output the file's contents and delete the file
	# once we have some OOP facilities
	
	new Pattern
		match: [
			"Write <data> to file <file>"
			"Write <data> to <file>"
			"Write <file> with content <data>"
		]
		fn: (v)=>
			fs.writeFileSync v("file"), v("data")
	
	new Pattern
		match: [
			"Append <data> to <file>"
			"Write <data> to the end of <file>"
		]
		bad_match: [
			"Append <data> to the end of <file>"
		]
		fn: (v)=>
			fs.appendFileSync v("file"), v("data")
	
	new Pattern
		match: [
			"Read from <file>"
			"Read file <file>"
			"Read <data> from <file>"
			"Read <file>"
		]
		fn: (v)=>
			fs.readFileSync v("file"), "utf8"
			# TODO: export variable data
			# if you say "Read JSON from data.json",
			# 	it should define a variable called "JSON"
			# otherwise
			# 	it should define a variable called "data" and/or "the file's contents"
	
	new Pattern
		match: [
			"Read from <file> as a buffer"
			"Read file <file> as a buffer"
			# "Read <data> from <file> as a buffer"
			# TODO: match the above first but prefer this variation:
			"Read <file> as a buffer"
		]
		fn: (v)=>
			fs.readFileSync v("file")
			# TODO: export variable "the buffer" and maybe "the file's contents"
			# "buffer contents"
			# "...as a buffer named Jerry"
			
	
	new Pattern
		match: [
			"we have permission to read from <file>"
			"we have permission to read <file>"
			"I have permission to read from <file>"
			"I have permission to read <file>"
			"we can read from <file>"
			"we can read <file>"
			"I can read from <file>"
			"I can read <file>"
			# "Do (we|I) have permission to read [from] <file>?"
		]
		fn: (v)=>
			# fs.access v("file"), fs.R_OK, (err)->
			try
				fs.accessSync v("file"), fs.R_OK
			catch e
				throw e unless e.code is "EPERM"
				return no
			return yes
	
	new Pattern
		match: [
			"we have permission to write to <file>"
			"we have permission to write <file>"
			"I have permission to write to <file>"
			"I have permission to write <file>"
			"we can write to <file>"
			"we can write <file>"
			"I can write to <file>"
			"I can write <file>"
			# "Do (we|I) have permission to write [to] <file>?"
		]
		fn: (v)=>
			# fs.access v("file"), fs.W_OK, (err)->
			try
				fs.accessSync v("file"), fs.W_OK
			catch e
				throw e unless e.code is "EPERM"
				return no
			return yes
	
	new Pattern
		match: [
			"stdout"
			"standard out"
		]
		fn: (v)=>
			# process.stdout # fd 1
			1
	
	new Pattern
		match: [
			"stdin"
			"standard in"
		]
		fn: (v)=>
			# process.stdin # fd 0
			0
	
	new Pattern
		match: [
			"stderr"
			"standard error"
		]
		bad_match: [
			"standarderror"
			"standard err"
			"std error"
			"stderror"
			"std err"
		]
		fn: (v)=>
			# process.stderr # fd 2
			2
	
]
