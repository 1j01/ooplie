
module.exports =
class Library
	constructor: (@name, {@patterns, @operators})->
		@patterns ?= []
		@operators ?= []
