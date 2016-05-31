
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
	test.skip "removing directories recursively", ->
		context.eval("remove directory 'temp/tempdir1'")
		context.eval("remove directory 'temp/tempdir2'")
		# or context.eval("remove directories 'temp/tempdir1' and 'temp/tempdir2'")
		# or context.eval("remove directories 'temp/tempdir{1,2}'")
	test "writing files", ->
		context.eval("write 'bla bla bla' to file 'temp/write.txt'")
		# context.eval("make directories for")
		expect(fs.readFileSync('temp/write.txt', 'utf8')).to.equal("bla bla bla")
	test "reading files", ->
		fs.writeFileSync('temp/read.txt', "bla bla bla")
		evaluate("read file 'temp/read.txt'").to("bla bla bla")
	test "appending to files"
	test "prepending to files"
	test "testing file permissions"
	test "writing to stdout/stderr"
