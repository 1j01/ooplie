
{expect} = require?("chai") ? chai
{Context} = require?("../src/ooplie.coffee") ? Ooplie

# TODO: DRY mock console

log_to_actual_console = (stuff)-> console.log stuff...

mock_console =
	log: log_to_actual_console

context = new Context console: mock_console

expect_output = (output, fn)->
	gotten_outputs = []
	mock_console.log = (text)->
		gotten_outputs.push text
	fn()
	mock_console.log = log_to_actual_console
	if Array.isArray(output)
		unless JSON.stringify(gotten_outputs) is JSON.stringify(output)
			if gotten_outputs.length > 0
				throw new Error "Expected console outputs #{JSON.stringify(output)} from #{fn}, instead got outputs #{JSON.stringify(gotten_outputs)}"
			else
				throw new Error "Expected console outputs #{JSON.stringify(output)} from #{fn} but got no output"
	else
		unless output in gotten_outputs
			if gotten_outputs.length > 1
				throw new Error "Expected console output #{JSON.stringify(output)} from #{fn}, instead got outputs #{JSON.stringify(gotten_outputs)}"
			else if gotten_outputs.length is 1
				throw new Error "Expected console output #{JSON.stringify(output)} from #{fn}, instead got output #{JSON.stringify(gotten_outputs[0])}"
			else
				throw new Error "Expected console output #{JSON.stringify(output)} from #{fn} but got no output"

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	{to}

suite "control flow", ->
	
	test "multiple statements", ->
		expect_output ["hello", "world"], ->
			context.eval("""
				print "hello"
				print "world"
			""")
	
	test.skip "multiple statements and an expression", ->
		expect_output ["hello", "world"], ->
			evaluate("""
				print "hello"
				print "world"
				5
			""").to(5)
	
	test.skip "statement with an expression, followed by an expression", ->
		expect_output 4, ->
			evaluate("""
				print 2 + 2
				5
			""").to(5)
	
	test.skip "multiple expressions", ->
		evaluate("""
			1 + 1
			2 + 2
		""").to(4)
	
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
	
	suite "switch statement", ->
		
		test.skip "single lines", ->
			evaluate("If true is... true: 5, false: 0").to(5)
			evaluate("If false is... true: 5, false: 0").to(0)
			evaluate("If 5 is... true: 5, false: 0").to(undefined)
			# if-is-else:
			evaluate("If 5 is... true: 5, false: 0, else: 3").to(3)
			evaluate("If 5 is... true: 5, false: 0, otherwise: 3").to(3)
		
		test.skip "natural", ->
			evaluate("If foo is a, then x, b then y, or c then z").to()
			evaluate("If foo is five, then do x, but if it's six then do y. If it's seven do z. Otherwise, do w").to()
			evaluate("If foo is five, do x; if it's six do y, and if it's seven do z; else, do w").to()
			evaluate("When foo is five, do x; when it's six do y, when seven do z; else do w").to()
			evaluate("""
				If foo happens to be five by some weird chance, do x I guess, but otherwise, y'know, just..
				if it's exactly six do y, and if pertains to seven do z (u kno the drill); and of course, don't forget,
				if it's none of the above, do w. always do w, in that case. just a fyi protip, fwiw, jsyk btw
			""").to()
			evaluate("""
				If foo is...
					a list, show the list elements
					an object, show the object
					anything else, show it
			""").to()
			evaluate("""
				If foo is a...
					list: show the list elements
					object: show the object
					anything else, show it
			""").to()
			evaluate("""
				Depending on what foo is, either
					show its elements (if it's a list)
					show it (otherwise)
			""").to()
			evaluate("""
				Depending on what foo is, either
					show its elements, if it's a list
					show it, otherwise, whatever it is
			""").to()
			evaluate("""
				Depending on foo,
					when a list, show its elements
					otherwise just show it
			""").to()
			evaluate("""
				What is foo?
					if a list, show its elements individually
					else show it normally
			""").to()
			evaluate("""
				What is foo, exactly?
				In the case that it's a list, display the elements it contains individually
				In case it's a balloon, let it float into the sky. Weeeee
				If it be the case that it do be a knife, watch out! put a warning on there, but then log it
				Otherwise, indeed merely present it in a traditional fasion, I urge you, mildly
			""").to()
		
		test.skip "blocks", ->
			evaluate("""
				If true is...
					true:
						1.1
					false:
						0.1
				Else
					0.5
			""").to(1.1)
			evaluate("""
				If false is...
					true,
						1.1
					false,
						0.1
				Otherwise
					0.5
			""").to(0.1)
			evaluate("""
				If "foo" is...
					true,
						1.1
					false,
						0.1
				Otherwise
					0.5
			""").to(0.5)
			evaluate("""
				If false is...
					true:  1.1
					false: 0.1
					Otherwise:
						0.5
			""").to(0.1)
			evaluate("""
				If "foo" is...
					true:  1.1
					false: 0.1
					Otherwise, 0.5
			""").to(0.5)
		
		test.skip "literal switch", ->
			expect(->
				evaluate("Switch true, true: 1, false: 0").to(1)
			).to.throw("For `Switch <switch value>, ...`, use `If <switch value> is... <switch option>: <result>` instead")
			expect(->
				evaluate("Switch based on true... true: 1, false: 0").to(1)
			).to.throw("For `Switch based on <switch value>, ...`, use `If <switch value> is... <switch value option>: <option result>` instead")
			expect(->
				evaluate("""
					Switch true
						case true: 1
						case false: 0
				""").to(1)
			).to.throw("For `Switch <switch value>, ...`, use `If <switch value> is... <switch value option>: <option result>` instead")
			expect(->
				evaluate("""
					switch (true)
						case true:
							1
							break
						case false:
							0
							break
				""").to(1)
			).to.throw("For `Switch <switch value>, ...`, use `If <switch value> is... <switch value option>: <option result>` instead")
	
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
