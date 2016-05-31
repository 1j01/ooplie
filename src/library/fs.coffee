
fs = require "fs"
path = require "path"

Pattern = require "../Pattern"
Library = require "../Library"

# hack to avoid browserify builtin "fs" module
if window?.require?
	fs = window.require "fs"

module.exports = new Library "File System", patterns: [
	
	# TODO: async! use streams and/or promises
	
	# TODO: probably should take an object-oriented approach, i.e.
	# 	output the file's contents and delete it # (it = the file)
	# once we have some OOP facilities
	
	# TODO: if it doesn't exist, unless it exists, unless it already exists
	# unless there's already a file there, [in which case]...
	
	# TODO: "if we're writing to a file"? "whether we're reading from a file"?
	# "if we're [already] [currently] writing to 'foo.txt'"?
	
	# TODO: globbing (how?)
	
	new Pattern
		match: [
			"Make directory <dir>"
			"Create directory <dir>"
			"Make folder <dir>"
			"Create folder <dir>"
		]
		bad_match: [
			"Make dir <dir>"
			"Create dir <dir>"
			"mkdir <dir>"
		]
		fn: (v)=>
			fs.mkdirSync(v("dir"))
	
	new Pattern
		match: [
			"Make directories <dir>"
			"Create directories <dir>"
			"Make folders <dir>"
			"Create folders <dir>"
		]
		bad_match: [
			"Make directories recursively <dir>"
			"Create directories recursively <dir>"
			"Make dirs recursively <dir>"
			"Create dirs recursively <dir>"
			"Make dirs <dir>"
			"Create dirs <dir>"
			"Make path <dir>"
			"Create path <dir>"
			"mkdirp <dir>"
			"mkdirs <dir>"
		]
		fn: (v)=>
			throw new Error "Not implemented (needs an npm module)"
	
	new Pattern
		match: [
			"Make directories for <file path>"
			"Create directories <file path>"
			"Make all the directories for <file path>"
			"Create all the directories for <file path>"
			"Make folders for <file path>"
			"Create folders for <file path>"
			"Make all the folders for <file path>"
			"Create all the folders for <file path>"
		]
		fn: (v)=>
			dir = path.dirname(v("file path"))
			throw new Error "Not implemented (needs an npm module)"
	
	new Pattern
		match: [
			"Remove directory <dir>"
			"Delete directory <dir>"
			"Remove folder <dir>"
			"Delete folder <dir>"
		]
		bad_match: [
			"Unlink directory <dir>"
			"Unlink folder <dir>"
			"Unlink dir <dir>"
			"Unlink <dir>"
			"rmdir <dir>"
		]
		fn: (v)=>
			fs.rmdirSync(v("dir"))
	
	new Pattern
		match: [
			"Write <data> to file <file>"
			"Write <data> to <file>"
			"Write file <file> with content <data>"
			"Write <file> with content <data>"
			"Write to <file>: <data>"
			"Write to file <file>: <data>"
			"Write <file>: <data>"
		]
		fn: (v)=>
			fs.writeFileSync v("file"), v("data")
	
	new Pattern
		match: [
			"Append <data> to file <file>"
			"Append <data> to <file>"
			"Write <data> to the end of <file>"
		]
		bad_match: [
			"Append <data> to the end of <file>"
			"Prepend <data> to the end of <file>"
		]
		fn: (v)=>
			fs.appendFileSync v("file"), v("data")
	
	new Pattern
		match: [
			"Prepend <data> to file <file>"
			"Prepend <data> to <file>"
			"Write <data> to the beginning of <file>"
		]
		bad_match: [
			"Prepend <data> to the beginning of <file>"
			"Append <data> to the beginning of <file>"
		]
		fn: (v)=>
			file_path = v("file")
			prepend_data = v("data")
			try
				existing_data = fs.readFileSync(file_path, "utf8")
			catch e
				throw e unless e.code is "ENOENT"
				existing_data = ""
			fs.writeFileSync file_path, prepend_data + existing_data
	
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
		bad_match: [
			"Read from <file> as buffer"
			"Read file <file> as buffer"
			"Read <file> as buffer"
		]
		fn: (v)=>
			fs.readFileSync v("file")
			# TODO: export variable "the buffer" and maybe also "the file's contents"
			# "buffer contents"?
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
			# process.stdout # stream
			1 # file descriptor
	
	new Pattern
		match: [
			"stdin"
			"standard in"
		]
		fn: (v)=>
			# process.stdin # stream
			0 # file descriptor
	
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
			# process.stderr # stream
			2 # file descriptor
	
	new Pattern
		match: [
			"list directory contents"
			"list folder contents"
			"list current directory contents"
			"list current folder contents"
			"list contents of the current directory"
			"list contents of the current folder"
			"list the contents of the current directory"
			"list the contents of the current folder"
			"list files and subdirectories"
			"list files and directories"
			# "enum dir contents"
			# "'numerate d'rectory 'tents"
			"ls"
		]
		bad_match: [
			"list dir contents"
			"list current dir contents"
			"list contents of the current dir"
			"list the contents of the current dir"
		]
		fn: (v)=>
			directory = "."
			fs.readdirSync(directory)
				.map (fname)->
					path.join(directory, fname)
	
	new Pattern
		match: [
			"list files"
			"list files in the current directory"
			"list the files in the current directory"
		]
		fn: (v)=>
			directory = "."
			fs.readdirSync(directory)
				.map (fname)->
					path.join(directory, fname)
				.filter (fname)->
					fs.statSync(fname).isFile()
	
	new Pattern
		match: [
			"list subdirectories"
			"list subfolders"
			"list directories"
			"list folders"
			"list folders in the current directory"
			"list the folders in the current directory"
			"list folders in the current folder"
			"list the folders in the current folder"
		]
		fn: (v)=>
			directory = "."
			fs.readdirSync(directory)
				.map (fname)->
					path.join(directory, fname)
				.filter (fname)->
					fs.statSync(fname).isDirectory()
	
	# TODO: "go up one level", "go up 5 folders"
	# "To go up N levels, go up N times"
	
]
