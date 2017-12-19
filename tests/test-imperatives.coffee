
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

suite "imperatives", ->
	
	test "output to the console", ->
		expect_output "Hello world", ->
			context.eval("""
				output "Hello world"
			""")
	test "interpret text as English", ->
		expect_output 8, ->
			context.eval("""
				run Ooplie code "output 5 + 3"
			""")
		evaluate("""
			execute Ooplie code "interpret '5 + 4' as English"
		""").to(9)
		evaluate("""
			interpret code "eval '5 + 5' as Ooplie code" with Ooplie
		""").to(10)
	test "run JS", ->
		expect_output "Hello world thru JavaScript from Ooplie", ->
			# To run JavaScript code, to execute JS, to eval JS, call the global JS function 'eval' with the code as the parameter
			context.eval("""
				run JS 'console.log("Hello world thru JavaScript from Ooplie")'
			""")
		expect_output "Hello world again", ->
			# To run JavaScript code, to execute JS, to eval JS, call the global JS function 'eval' with the code as the parameter
			context.eval("""
				execute 'console.log("Hello world again")' as JavaScript
			""")
	test.skip "JS interop", ->
		expect_output "Hello world thru JavaScript from a variable in Ooplie", ->
			context.eval("""
				message = "Hello world thru JavaScript from a variable in Ooplie"
				run JS console.log(message)'
			""")
	test.skip "to do x, bla bla bla", ->
		context.eval("to say something, output it to the console")
		context.eval("to output something to the console, run JS console.log(something)")
		context.eval("to output something to the console, `console.log(it)`")
		context.eval("to output something to the console, execute the JavaScript method named 'log' on the global JavaScript object 'console' with the thing as a parameter")
		expect_output "Hello World", ->
			evaluate("say 'Hello World'!")
	test.skip "to draw things, bla bla bla", ->
		# these are just some sketches of some canvas API glue code / API definition
		# to figure out what some stuff might look like
		# I'm not really happy with most of this stuff

		context.eval("to draw a circle of radius r at (x, y), run JS ctx.arc(x, y, r, 0, Math.PI * 2)")
		context.eval("to draw a circle of a given radius, x, and y, run JS ctx.arc(x, y, radius, 0, Math.PI * 2)")
		context.eval("to draw a circle of a given radius and x and y position, run JS ctx.arc(x, y, radius, 0, Math.PI * 2)")
		context.eval("to draw a circle of a given radius and position, run JS ctx.arc(position.x, position.y, radius, 0, Math.PI * 2)")
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

		# verbose optional arguments with room for errors:
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
			
			The code for a rectangle requires variables such as x, y, w, and h which shalt be takeneth from the rectangle's properties of x, y, width and height respectivisimally.
			
			To draw a rectangle at (x, y, w, h), or
			To draw a rectangle at (x, y) with width w and height h,
				nevermind!
			
		""")
		context.eval("""
			To draw a circle, blah blah blah.
			
			Circles should be drawn like this: blah blah blah.
			
			Circles can be drawn by blah blah blah-ing.
			
			Draw a circle by blah blah blah-ing. (This sounds like it would actually do the thing not just define the functionality)

			To draw a given shape, do the following:
				circle: blah blah blah
				rectangle: blah blah blah
			
			The code to draw a specific shape is (by shape):
				circle: blah blah blah
				rectangle: blah blah blah
		""")

		context.eval("draw a circle")
		context.eval("draw a circle of radius 5")
		context.eval("draw a circle with radius 5")
		context.eval("draw a circle with radius 5 at the center of the screen/canvas")
		throw new Error "TODO: mock canvas and test"
	
	test.skip "physics!", ->
		context.eval("""
			create a ragdoll
			set the ragdoll's head's velocity to a vector of random orientation with a magnitude between 0 and 10 every frame
			hope it doesn't fall off
		""")
		# set the ragdoll's head velocity
		# set the ragdoll head's velocity
		# set the velocity of the ragdoll's head
		# set the velocity of the head of the ragdoll
		# add velocity to the head of the ragdoll
		# apply velocity to the ragdoll's head
		# apply acceleration to the ragdoll's head
		# apply a force to the ragdoll's head
		throw new Error "TODO: what is this?"
