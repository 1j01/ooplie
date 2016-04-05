
{expect} = require "chai"
{Context} = require "../src/ooplie.coffee"

context = new Context

evaluate = (expression)->
	to: expect(context.eval(expression)).to.eql

suite "control flow", ->
	
	suite "loops", ->
		test "for each from a to b"
		test "for each from a to b by n"
		test "for each between a and b"
		test "for each between a and b by n"
		test "for each in range"
		test "for each in range by n"
		test "for each in set", ->
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
			# evaluate("").to.a(Set)
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
		test "while"
		test "until"
		test "not 'continue' but some way to skip to the next iteration" # (?)
		test "break" # (?)
		test "break out of multiple loops?" # (?)
		test "GOTO 20" # kidding
		test "unbounded (infinite loop, loop forever until broken)"
		test "as values"
			# like in CoffeeScript
	
	suite "conditionals", ->
		test "if", ->
			# TODO: test multiline and actual actions
			evaluate("If true, 5").to(5)
			evaluate("If false, 5").to(undefined)
			# post-if:
			evaluate("5 if true").to(5)
			evaluate("5 if false").to(undefined)
			# ternary:
			evaluate("If true then 5 else 0").to(5)
			evaluate("If false then 5 else 0").to(0)
			# pythonic ternary:
			evaluate("5 if true else 0").to(5)
			evaluate("5 if false else 0").to(0)
			# TODO: test if-else-if
		test "unless", ->
			# TODO: test multiline and actual actions
			evaluate("Unless true, 5").to(undefined)
			evaluate("Unless false, 5").to(5)
			# post-unless:
			evaluate("5 unless true").to(undefined)
			evaluate("5 unless false").to(5)
			# TODO: test unless-else, unless-else-if, unless-else-unless etc. but maybe throw style warnings/errors
		test "as values"
			# like in CoffeeScript (probably the best thing about CoffeeScript and CoffeeScript is pretty good)
