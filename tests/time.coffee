
{expect} = require?("chai") ? chai
{Context} = require?("../src/ooplie.coffee") ? Ooplie

context = new Context

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	to.approximately = (value, margin_of_error)->
		unless value - margin_of_error <= result <= value + margin_of_error
			throw new Error "expected #{result} to be within #{margin_of_error} of #{value}"
	{to}

suite "time", ->
	
	suite "value parsing", ->
		
		test.skip "time span values", ->
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
	
	suite "time math", ->
		# context.eval("A = now")
		A = new Date()
		
		# test "time spans", ->
		test.skip "now", ->
			context.eval("A = now")
			evaluate("now").to(new Date())
			evaluate("current time").to(new Date())
			evaluate("the current time").to(new Date())
		test.skip "time ago", (callback)->
			setTimeout ->
				try
					evaluate("5s ago = now - 5s").to(true)
					evaluate("500ms ago").to.approximately(A, 10)
				catch err
				
				callback err
			, 500
		test.skip "time since a", (callback)->
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
	
	suite "timers", ->
		test.skip "after <timespan>, do x", ->
			evaluate("do x after 1s")
			evaluate("after 1s do x") # throw grammar error
			evaluate("after 1s, do x")
			throw new Error "TODO"
		test.skip "every <timespan>, do x", ->
			evaluate("do x every 1s")
			evaluate("every 1s do x") # throw grammar error
			evaluate("every 1s, do x")
			throw new Error "TODO"
		test "every <timespan> for <timespan>, do x"
		test "every frame, do x"
			# requestAnimationFrame
		test "every frame for <timespan>, do x"
		test "now and after <timespan>, do x"
		test "now and every <timespan>, do x"
		test "immediately and after <timespan>, do x"
		test "immediately and every <timespan>, do x"
		test "'initially' and after <timespan>, do x"
			# throw style error ("now" or "immediately" is better)
		test "'initially' and every <timespan>, do x"
			# throw style error ("now" or "immediately" is better)
			# not sure which is best
		test "every other <timespan> [for <timespan>], do x"
			# throw style error/warning? "every 2s" isn't particularly better imo
		test "every nth <timespan> [for <timespan>], do x"
			# e.g. every 5th second
			# throw style error/warning? "every 5s" is better
		test "every once in a while"
			# throw error for utter vagueness
		test "twice per <timespan>"
		test "n times per <timespan>"
		test "twice 'every' <timespan>"
			# throw style error, "per" is better because
			# "do something twice every 5min" is somewhat ambiguous as to
			# whether it should space it out over the period or do it twice at once
		test "n times 'every' <timespan>"
			# throw style error, see above
		test "every <timespan> 'until' <timespan>, do x"
			# throw style error, "for" is better in this case
		test "every <timespan> 'until' <timespan> 'has passed', do x"
			# throw style error, "for" is better in this case
		test "every <timespan>[,] until <condition>, do x"
		test "after <timespan>[,] unless <condition>, do x"
		test "every <timespan> after <timespan>, do x"
		test "after <timespan>, do x every <timespan>"
		test "every <timespan> for N times"
		test "every <timespan> N times"
			# throw style error?
		test "every <timespan> but only N times"
			# throw style error
		test "stop after <timespan>"
			# maybe!
		test "stop after N times"
			# maybe!
		test "wait <timespan>"
			# maybe!
		test "sleep <timespan>"
			# throw style error
		
		suite "multiple afters", ->
			test "after another <timespan>, do z"
			test "after <N> more <time unit>s, do y"
			test "then after <N> <time unit>s, do y"
			test "then after <N> more <time unit>s, do y"
		
		suite "might need some cron jobs", ->
			test "every day, do x"
			test "every day at noon, do x"
			test "every noon, do x"
			test "every midnight, do x"
			test "every day at 5:00 PM, do x"
			test "every day at 5:00, do x"
				# throw ambiguity error
			test "every 5:00 PM, do x"
				# throw style error
			test "every week, do x"
			test "every week on <day of the week>, do x"
			test "every <day of the week>, do x"
			test "next <day of the week>, do x"
			test "on <day of the week>, do x"
			test "every <list of days of the week>, do x"
			test "next <day of the week> or <day of the week>, do x"
		
	suite "questions", ->
		# not sure this is something that should be here, in any sense
		
		suite "current time", ->
			test "What day is today?"
			test "What day is it?"
			test "What day of the week is it?"
			test "What's the day of the week?"
			test "What time is it?"
			test "What's the time?"
			test "What month is it?"
			test "What's the current month?"
			test "What year is it?"
			test "What's the current year?"
			test "What time is it in Hawaii?"
		
		suite "conversion", ->
			test "How many minutes are in an hour?"
			test "How many hours are in a minute?"
			test "How many minutes are in 10 days?"
			test "How many milliseconds are in 10 days, but when one of the days has a leap second added?"
			test "What time is it when an elephant sits on your watch?"
			test "Is it time to stop writing ridiculous tests?"
