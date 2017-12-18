
# See also: test-nonsense.coffee
suite "integration", ->

	test.skip "bla bla bla", ->
		context = shared_context.subcontext()
		context.eval """
			To say or log something, output it to the console.
			Say "Hello world!"
			Greeting = "Hello"
			Log greeting " world!"
			output the greeting followed by " world!"
		"""
