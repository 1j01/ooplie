
{expect} = require "chai"
{Context} = require "../src/ooplie.coffee"

log_to_actual_console = (stuff)-> console.log stuff...

mock_console =
	log: log_to_actual_console

context = new Context console: mock_console

expect_output = (output, fn)->
	got_expected_output = no
	mock_console.log = (text)->
		if text is output
			got_expected_output = yes
		else
			log_to_actual_console arguments...
	fn()
	unless got_expected_output
		throw new Error "Expected console output `#{output}` from #{fn}"

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
		test "for each in range backwards" # throw style error/warning?
		test "for each in range in reverse"
		test "for each in range from the end to the start" # throw style error
		test "for each in range from the last to the first" # throw style error
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

	suite "imperative", ->
		test "run JS", ->
			expect_output "Hello world from JavaScript from Ooplie", ->
				# To run JavaScript code, to execute JS, to eval JS, call the global JS function 'eval' with the code as the parameter
				context.eval("""
					run JS 'console.log("Hello world from JavaScript from Ooplie")'
				""")
		test "JS interop", ->
			expect_output "Hello world from JavaScript from a variable in Ooplie", ->
				context.eval("""
					message = "Hello world from JavaScript from a variable in Ooplie"
					run JS console.log(message)'
				""")
		test "to do x, bla bla bla", ->
			context.eval("to say something, output it to the console")
			context.eval("to output something to the console, run JS console.log(something)")
			context.eval("to output something to the console, `console.log(it)`")
			context.eval("to output something to the console, run JavaScript methed log on the global JavaScript object 'console' with it as a parameter")
			expect_output
			evaluate("say 'Hello World'!")
			# TODO: expect output
		test "to do x, bla bla bla", ->
			context.eval("to draw a circle of radius r at (x, y), run JS ctx.arc(x, y, r, 0, Math.PI * 2)")
			context.eval("""
				To draw a circle of radius r at (x, y),
					run JS
						ctx.beginPath()
						ctx.arc(x, y, r, 0, Math.PI * 2)
						ctx.fill()
			""")
			context.eval("""
				To draw a shape, draw a filled shape?
				To draw a <color> shape?
				To draw a filled shape,
					Run JS ctx.beginPath()
					Run the code for the shape
					Run JS ctx.fill()
				To draw a stroked shape, run JS
					Run JS ctx.beginPath()
					Run the code for the shape
					Run JS ctx.stroke()
				To draw a rectangle at (x, y, w, h),
					Draw the shape with JS code ctx.rect(x, y, w, h)
				To draw a circle at (x, y, r),
					Draw the shape with JS code ctx.arc(x, y, r, 0, Math.PI * 2)
				To draw a rectangle at (x, y) with width w and height h
					draw a rectangle at (x, y, w, h)
					# TODO: DRY
				To draw a circle at (x, y) with radius r, draw a circle at (x, y, r)
			""")
			context.eval("to draw a circle at (x, y), draw a circle of radius 5 at (x, y)")
			context.eval("""
				To draw a filled shape,
					Run JS ctx.beginPath()
					Run the code for the shape
					Run JS ctx.fill()
				
				To draw a stroked shape, run JS
					Run JS ctx.beginPath()
					Run the code for the shape
					Run JS ctx.stroke()
				
				The code for a circle is: ctx.arc(x, y, r, 0, Math.PI * 2)
				The code for a rectangle is: ctx.rect(x, y, w, h)
				
				The code for a circle is: ctx.arc(x, y, r, 0, Math.PI * 2)
				The code for a rectangle is: ctx.rect(x, y, w, h)
				
				The code for a rectangle requires variables such as x, y, w, and h which shall be taken from the rectangle's properties of x, y, width and height respectively.
				
				To draw a rectangle at (x, y, w, h), or
				To draw a rectangle at (x, y) with width w and height h,
					nevermind!
				
			""")
			context.eval("draw a circle")
			context.eval("draw a circle of radius 5")
			context.eval("draw a circle with radius 5")
			context.eval("draw a circle with radius 5 at the center of the screen/canvas")
		
		test "physics!", ->
			context.eval("""
				create a ragdoll
				set the ragdoll's head's velocity to a vector of random orientation with a magnitude between 0 and 10 every frame
				hope it doesn't fall off
			""")
