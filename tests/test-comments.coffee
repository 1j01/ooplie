
{expect} = require?("chai") ? chai
{Context} = require?("../src/ooplie.coffee") ? Ooplie

context = new Context

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	{to}

suite "comments", ->
	
	test "single-line comments with #", ->
		evaluate("""
			#!/usr/bin/english
			# "hiya world"
			"Hello, world!"
			# "Greetings Earth"
		""").to("Hello, world!")
		evaluate("""
			# "hiya world"
			"Hello, world!" # this is the line that shouldn't be ignored
			# "Greetings Earth"
		""").to("Hello, world!")
		evaluate("""
			# "hiya world"
			"#wassup world?" # hashes within strings
			# "Greetings Earth"
		""").to("#wassup world?")
	
	test.skip "notes", ->
		evaluate("Note: Replace with your own token in production.").to(undefined)
		evaluate("NOTE: This is not something you should really do.").to(undefined)
		evaluate("""
			NOTE: This is not something you should really do.
			It will basically blow up in your face so try to avoid it.
		""").to(undefined) # uh, I don't think this one works
		# is it supposed to decide based on newlines surrounding it?
		evaluate("""
			End all life on Earth.
			NOTE: This is not something you should really do.
			It will basically blow up in your face so try to avoid it.
		""").to(undefined) # throw error, hopefully?! AsimovsZerothLawError :P
		# this is kinda ugly:
		evaluate("""
			NOTE:
				This is not something you should really do.
				It will basically blow up in your face so try to avoid it.
		""").to(undefined)
		
		# and also TODO? maybe TODO should be an error (i.e. NotImplementedError)
