
{expect} = require "chai"
{Context} = require "../src/ooplie.coffee"

context = new Context

evaluate = (expression)->
	result = context.eval(expression)
	to = expect(result).to.eql
	to.approximately = (value, margin_of_error)->
		unless value - margin_of_error <= result <= value + margin_of_error
			throw new Error "expected #{result} to be within #{margin_of_error} of #{value}"
	{to}

suite "time", ->
	
	test "time span values", ->
		evaluate("4hr 30m = 4.5hr").to(true)
		evaluate("4 hours and 30 minutes = 4.5hr").to(true)
		evaluate("4.5hr = 4:30").to(true) # throw ambiguity error
		evaluate("4.5min = 4:30").to(true) # throw ambiguity error
		evaluate("four and a half hours = 4.5h").to(true)
	
	test "date-time values"
		# There is a large variety of formats for dates in use, which differ in
		# the order of date components (e.g. 31/05/1999, 05/31/1999, 1999/05/31),
		# component separators (e.g. 31.05.1999 vs. 31/05/1999),
		# whether leading zeros are included (e.g. 31/5/1999 vs. 31/05/1999),
		# whether all four digits of the year are written (e.g., 31.05.1999 vs. 31.05.99),
		# and whether the month is represented in Arabic or Roman numerals or by name (e.g. 31.05.1999, 31.V.1999 vs. 31 May 1999).
		# https://en.wikipedia.org/wiki/Calendar_date
		# maybe separate suites for time spans vs date/time/date-time value parsing
		# definitely support https://en.wikipedia.org/wiki/ISO_8601
	
	# context.eval("A = now")
	A = new Date()
	
	# test "time spans", ->
	test "now", ->
		context.eval("A = now")
		evaluate("now").to(new Date())
	test "time ago", (callback)->
		setTimeout ->
			try
				evaluate("5s ago = now - 5s").to(true)
				evaluate("500ms ago").to.approximately(A, 10)
			catch err
			
			callback err
		, 500
	test "time since a", (callback)->
		setTimeout ->
			try
				evaluate("the time since A").to.approximately(Date.now() - A, 10)
				evaluate("now - the time since A = A").to(true)
				evaluate("now - time since A = A").to(true)
				evaluate("Has it been 5s since A?").to(no)
				evaluate("If it's been 5s then 1 else 0").to(0)
				evaluate("If it's been at least 5s since A, 1 else 0").to(0)
				evaluate("If it's been more than 5s, 1 else 0").to(0)
				evaluate("If it's been less than 5s, 1 else 0").to(1)
				evaluate("If it's been at most 5s, 1 else 0").to(1)
			catch err
			
			callback err
		, 500
	test "time before a"
	test "time after a"
	test "time between a and b"
	test "after <timespan>, do x", ->
		evaluate("do x after 1s")
		evaluate("after 1s do x") # throw grammar error
		evaluate("after 1s, do x")
	test "every <timespan>, do x", ->
		evaluate("do x every 1s")
		evaluate("every 1s do x") # throw grammar error
		evaluate("every 1s, do x")
	test "every <timespan> for <timespan>, do x"
