
module.exports =
class Pattern
	constructor: ({match, action})->
		@defs = match
		@fn = action
	
	match: (tokens)->
		for def in defs
			for token in tokens
				if the token matches up w/ the def
					looks good
					continue
				else
					nope
			wow did you match the whole thing?
			if so then return the match
			otherwise you have failed
