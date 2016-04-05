
{expect} = require "chai"
{Context} = require "../src/ooplie.coffee"

shared_context = null
context = null

evaluate = (expression)->
	to: expect(context.eval(expression)).to.eql

suite "object-oriented programming", ->
	shared_context = new Context
	test "animals 1", ->
		shared_context.eval """
			A mammal is a type of animal with a neocortex, hair, three middle ear bones, and mammary glands.
		"""
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
		context = shared_context.subcontext()
		context.eval """
			To say or log something, output it to the console.
			Say "Hello world!"
			Greeting = "Hello"
			Log greeting " world!"
			output the greeting followed by " world!"
		"""
		
