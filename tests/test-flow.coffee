
{expect} = require?("chai") ? chai
{Context} = require?("../src/ooplie.coffee") ? Ooplie

context = new Context

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	{to}

suite "control flow", ->
	
	test "multiple statements"
	
	suite "conditionals", ->
		
		test "if statement", ->
			evaluate("If true, 5").to(5)
			evaluate("If false, 5").to(undefined)
			# if-then:
			evaluate("If true then 5").to(5)
			evaluate("If false then 5").to(undefined)
			# post-if:
			evaluate("5 if true").to(5)
			evaluate("5 if false").to(undefined)
		
		test "if-else statement", ->
			evaluate("If true, 5, else 0").to(5)
			evaluate("If false, 5, else 0").to(0)
			# if-then-else:
			evaluate("If true then 5 else 0").to(5)
			evaluate("If false then 5 else 0").to(0)
			# pythonic ternary style:
			evaluate("5 if true else 0").to(5)
			evaluate("5 if false else 0").to(0)
			# C/JS/etc. ternary style:
			expect(->
				evaluate("false ? 1010 : 10101").to(10101)
			).to.throw("For `false ? 1010: 10101`, use `If <condition>, <body>, else <alt body>` instead")
			# TODO: should be "For `false ? 1010 : 10101`, use `If <condition>, <body>, else <alt body>` instead"
		
		test "if-else-if", ->
			evaluate("if 5 then 6 else if 2 then 3 else 7").to(6)
			evaluate("if 0 then 6 else if 2 then 3 else 7").to(3)
			evaluate("if 0 then 6 else if 0 then 3 else 7").to(7)
			# ternary style:
			evaluate("If true then 5 else if true then 11 else 0").to(5)
			evaluate("If false then 5 else if true then 11 else 0").to(11)
			evaluate("If false then 5 else if false then 11 else 0").to(0)
			# pythonic ternary style:
			evaluate("151 if true else 39 if true else 241").to(151)
			evaluate("151 if false else 39 if true else 241").to(39)
			evaluate("151 if false else 39 if false else 241").to(241)
		
		test "unless statement", ->
			evaluate("Unless true, 5").to(undefined)
			evaluate("Unless false, 5").to(5)
			# post-unless:
			evaluate("5 unless true").to(undefined)
			evaluate("5 unless false").to(5)
		
		test "unless-then, unless-else", ->
			# unless-then
			expect(->
				evaluate("Unless true then 5").to(undefined)
			).to.throw("For `Unless true then 5`, use `Unless <condition>, <body>` instead")
			# unless-then-else
			expect(->
				evaluate("unless 345 then 404 else 999").to(999)
			).to.throw("For `unless 345 then 404 else 999`, use `<body> unless <condition> in which case <alt body>` instead")
			# TODO: should probably recommend `If <condition>, <body>, else <alt body>` instead
			# unless-else
			# TODO: we can't match `X unless Y else Z` because it's a bad_match(er)
			# so even when the pattern is above `X unless Y`, `X unless Y` is matched first
			# might need to make something like a bad_clear_match(er)
			# expect(->
			# 	evaluate("55 unless 5 else 33").to(33)
			# ).to.throw("For `55 unless 5 else 33`, use `<body>, unless <condition> in which case <alt body>` instead")
		
		test "as blocks", ->
			evaluate("""
				If true,
					5
			""").to(5)
			evaluate("""
				If false,
					5
			""").to(undefined)
			evaluate("""
				If true,
					5
				Else
					1
			""").to(5)
			evaluate("""
				If false,
					5
				Else
					1
			""").to(1)
			evaluate("""
				Unless true,
					5
			""").to(undefined)
			evaluate("""
				Unless false,
					5
			""").to(5)
		
		test "nested blocks", ->
			evaluate("""
				If true,
					If true,
						500
					Else
						400
				Else
					100
			""").to(500)
			evaluate("""
				If false,
					If true,
						500
					Else
						400
				Else
					100
			""").to(100)
			evaluate("""
				If true,
					If false,
						500
					Else
						400
				Else
					100
			""").to(400)
		
		test "as expressions"
			# like in CoffeeScript (probably the best thing about CoffeeScript and CoffeeScript is pretty good)
		
		test.skip "if there are any", ->
			# it would probably be good to make a wrapper for test that creates a new context
			context.eval("There are five houses.")
			evaluate("there are any houses").to(true)
			evaluate("If there are any houses then 1 else 0").to(1)
			evaluate("Are there any houses?").to(true)
			context.eval("There are 0 people.")
			evaluate("there are any people").to(false)
			evaluate("If there are any people then 1 else 0").to(0)
			evaluate("Are there any people?").to(false)
		
		test.skip "if there are no", ->
			context.eval("There are 99 balloons.")
			evaluate("there are no balloons").to(false)
			evaluate("If there are no balloons then 1 else 0").to(0)
			evaluate("Are there no balloons?").to(false)
			context.eval("There are 0 towers.")
			evaluate("there are no towers").to(true)
			evaluate("If there are no towers then 1 else 0").to(1)
			evaluate("Are there no towers?").to(true)
	
	suite "loops", ->
		
		test "for a to b"
		test "for a to b by n"
		test "for each from a to b"
		test "for each from a to b by n"
		test "for each between a and b"
		test "for each between a and b by n"
		test "for each in range"
		test "for each in range by n"
		test "for each in range backwards" # throw style error/warning?
		test "for each in range in reverse"
		test "for each in range from the end to the start" # throw style error
		test "for each in range from the last to the first" # throw style error
		test.skip "for each in set", ->
			context.eval """
				set = {1, 2, 3, 4}
				# For each item in set
				# For each item in the set
				# For each value in the set
				For each number in the set,
					Output the number.
				
				new set = For each number in the set, the number times 5
				other new set = For each number in the set, number * 5
				another new set = number * 5 for each number in set
				
				new set = other new set = another new set = {5, 10, 15, 20}
			"""
			evaluate("new set").to.a(Set)
			evaluate("other new set").to.a(Set)
		test "for each in set by"
		test "for each in Array"
		test "for each in Array by"
		test "for each in Object?"
		test "for each in Iterable"
		test "for each in Iterable by?"
		test "for each property of Object"
		test "for each key and value of Object"
		test "for every other in"
		test "for every nth value in"
		test "for each and every" # synomynmous with for each
		test "for each in a and b"
			# iterate over the concatenation of two arrays, sets, ranges, etc.
			
		test "for each in a, b, and c"
		test "while"
		test "until"
		test "not 'continue' but some way to skip to the next iteration" # (?)
		test "break" # (?)
		test "break out of multiple loops?" # (?)
		test "GOTO 20" # kidding
		test "unbounded (infinite loop, loop forever until broken)"
		test "as expressions"
			# like in CoffeeScript
