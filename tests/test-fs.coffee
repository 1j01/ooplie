
{expect} = require?("chai") ? chai
{Context, Range} = require?("../src/ooplie.coffee") ? Ooplie

context = new Context

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	{to}

suite "file system", ->
	test.skip "writing files", ->
		evaluate("write 'bla bla bla' to file 'fixtures/bla.txt'")
		expect(fs.readFileSync('fixtures/bla.txt')).to.equal("bla bla bla")
	test.skip "reading files", ->
		evaluate("read file 'fixtures/bla.txt'").to("bla bla bla")
	test "appending to files"
	test "prepending to files"
	test "testing file permissions"
	test "writing to stdout/stderr"
