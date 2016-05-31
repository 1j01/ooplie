
{expect} = require?("chai") ? chai
{Context, Range} = require?("../src/ooplie.coffee") ? Ooplie
fs = require "fs"

context = new Context

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	{to}

suite "file system", ->
	test "creating directories", ->
		try
			fs.mkdirSync("temp")
		catch e
			throw e unless e.code is "EEXIST"
		try
			fs.rmdirSync("temp/tempdir")
		catch e
			throw e unless e.code is "ENOENT"
		context.eval("make directory 'temp/tempdir'")
		unless fs.statSync("temp/tempdir").isDirectory()
			throw new Error "temp/tempdir is not a directory"
	test "removing directories", ->
		try
			fs.mkdirSync("temp/tempdir")
		catch e
			throw e unless e.code is "EEXIST"
		context.eval("remove directory 'temp/tempdir'")
		try
			if fs.statSync("temp/tempdir")
				throw new Error "temp/tempdir still exists"
		catch e
			throw e unless e.code is "ENOENT"
	test.skip "creating directories recursively", ->
		context.eval("make directory 'temp/tempdir1/tempdir11'")
		context.eval("make directories for 'temp/tempdir2/tempdir22'")
		context.eval("make folder 'temp/tempdir3/tempdir33'")
		context.eval("make folders for 'temp/tempdir4/tempdir44'")
	test.skip "removing directories recursively", ->
		context.eval("remove directory 'temp/tempdir1'")
		context.eval("remove directory 'temp/tempdir2'")
		context.eval("remove directories 'temp/tempdir3' and 'temp/tempdir4'")
		# or context.eval("remove directories 'temp/tempdir{1,2,3,4}'")
	test "writing files", ->
		context.eval("write 'bla bla bla' to file 'temp/writing.txt'")
		expect(fs.readFileSync('temp/writing.txt', 'utf8')).to.equal("bla bla bla")
	test "reading files", ->
		fs.writeFileSync('temp/reading.txt', "bla bla bla")
		evaluate("read file 'temp/reading.txt'").to("bla bla bla")
	test "appending to files", ->
		fs.writeFileSync('temp/appending.txt', "hello")
		context.eval("append ' world' to file 'temp/appending.txt'")
		expect(fs.readFileSync('temp/appending.txt', 'utf8')).to.equal("hello world")
	test "prepending to files", ->
		fs.writeFileSync('temp/prepending.txt', "world")
		context.eval("prepend 'hello ' to file 'temp/prepending.txt'")
		expect(fs.readFileSync('temp/prepending.txt', 'utf8')).to.equal("hello world")
	test "testing file permissions"
	test "writing to stdout/stderr"
