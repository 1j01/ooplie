
{expect} = require?("chai") ? chai
{Context} = require?("../src/ooplie.coffee") ? Ooplie

shared_context = null
context = null

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	{to}

suite "object-oriented programming", ->
	shared_context = new Context
	# put the OOP in Ooplie
	# TODO: better tests in general
	# test defining a class
	# then test inheritance
	test "animals 1", ->
		shared_context.eval """
			A mammal is a type of animal with a neocortex, hair, three middle ear bones, and mammary glands.
		"""
		throw new Error "TODO: this isn't a test, it's setup"
	test "animals 2!", ->
		context = shared_context.subcontext()
		context.eval """
			A bunny is a cute type of animal.
			Frank is a funny little bunny.
		"""
		evaluate("Is Frank an animal?").to(yes)
		evaluate("Is Frank a bunny?").to(yes)
		evaluate("Is Frank funny?").to(yes)
		evaluate("Is Frank little?").to(yes)
		evaluate("Is Frank a type of bunny?").to(no)
		evaluate("Is Frank a type of animal?").to(no)
		evaluate("Is a bunny a type of bunny?").to(no)
		evaluate("Is a bunny a type of animal?").to(yes)
		evaluate("Is a bunny a type of mammal?").to(undefined)
	test "animals 3!", ->
		context = shared_context.subcontext()
		context.eval """
			Bunnies are cute little animals.
			Frank is a funny bunny.
		"""
		evaluate("Is Frank an animal?").to(yes)
		evaluate("Is Frank a bunny?").to(yes)
		evaluate("Is Frank funny?").to(yes)
		evaluate("Is Frank little?").to(yes)
	test "and it's kyoot", ->
		context = shared_context.subcontext()
		context.eval """
			A bunny is a type of mammal, and it's cute!
			Frank is a funny bunny.
		"""
		evaluate("Is Frank an animal?").to(yes)
		evaluate("Is Frank a bunny?").to(yes)
		evaluate("Is Frank a mammal?").to(yes)
		evaluate("Is Frank funny?").to(yes)
		evaluate("Is a bunny a type of mammal?").to(yes)
		evaluate("Is a bunny a type of animal?").to(yes)
		evaluate("Is a mammal a type of animal?").to(yes)
		evaluate("Is a mammal a type of bunny?").to(no)
	test "bla bla bla", ->
		throw new Error "TODO: move or remove this, it isn't OOP"
		context = shared_context.subcontext()
		context.eval """
			To say or log something, output it to the console.
			Say "Hello world!"
			Greeting = "Hello"
			Log greeting " world!"
			output the greeting followed by " world!"
		"""
		
