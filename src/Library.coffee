
module.exports =
class Library
	constructor: (@name, {@patterns, @operators, @constants})->
		@patterns ?= []
		@operators ?= []
		@constants ?= []
