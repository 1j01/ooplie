
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
	# TODO: put the OOP in Ooplie? well, not necessarily traditional OOP
	# probably not traditional OOP. maybe "concept-oriented programming"?
	# well, that's of course another term that's been coined:
	# http://conceptoriented.org/wiki/Concept-oriented_programming
	# I dunno

	shared_context = new Context
	
	# TODO: better tests in general
	# test defining a class
	# then test inheritance
	# also all these tests require questioning, which they probably shouldn't
	# we should have some tests at the begining that test functionality
	# and then we can have a section with questioning
	
	test.skip "animals 1", ->
		shared_context.eval """
			A mammal is a type of animal with a neocortex, hair, three middle ear bones, and mammary glands.
		"""
		context = shared_context.subcontext()
		evaluate("A mammal is a type of animal").to(yes)
		evaluate("An animal is a type of mammal").to(no)
		evaluate("Is a mammal a type of animal?").to(yes)
		evaluate("Is an animal a type of mammal?").to(undefined)
	
	test.skip "animals 2!", ->
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
	
	test.skip "animals 3!", ->
		context = shared_context.subcontext()
		context.eval """
			Bunnies are cute little animals.
			Frank is a funny bunny.
		"""
		evaluate("Is Frank an animal?").to(yes)
		evaluate("Is Frank a bunny?").to(yes)
		evaluate("Is Frank funny?").to(yes)
		evaluate("Is Frank little?").to(yes)
	
	test.skip "and it's kyoot", ->
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
