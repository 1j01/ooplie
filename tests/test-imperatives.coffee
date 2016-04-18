
{expect} = require?("chai") ? chai
{Context} = require?("../src/ooplie.coffee") ? Ooplie

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
		throw new Error "TODO: expect an exact array of outputs"
	else
		unless output in gotten_outputs
			if gotten_outputs.length > 1
				throw new Error "Expected console output #{JSON.stringify(output)} from #{fn} (instead got outputs #{JSON.stringify(gotten_outputs)})"
			else if gotten_outputs.length is 1
				throw new Error "Expected console output #{JSON.stringify(output)} from #{fn} (instead got output #{JSON.stringify(gotten_outputs[0])})"
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
		context.eval("to output something to the console, run JavaScript methed log on the global JavaScript object 'console' with it as a parameter")
		expect_output "Hello World", ->
			evaluate("say 'Hello World'!")
	test.skip "to do x, bla bla bla", ->
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
		throw new Error "TODO: mock canvas and test"
	
	test.skip "physics!", ->
		context.eval("""
			create a ragdoll
			set the ragdoll's head's velocity to a vector of random orientation with a magnitude between 0 and 10 every frame
			hope it doesn't fall off
		""")
		throw new Error "TODO: what is this?"
