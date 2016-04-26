
Operator = require "../Operator"
Library = require "../Library"

# Should there be separate libraries for Comparison, Arithmetic?
# Should Set Operators go in Sets?
# Maybe we should just have categories.

module.exports = new Library "Operators", operators: [
	
	new Operator
		match: [
			"^"
			"to the power of"
		]
		bad_match: [
			"**"
		]
		precedence: 3
		right_associative: yes
		fn: (lhs, rhs)-> lhs ** rhs
	
	new Operator
		match: [
			"×"
			"*"
			"times"
			"multiplied by"
		]
		bad_match: [
			"✖" # heavy multiplication X
			"⨉" # n-ary times operator
			"⨯" # vector or cross-product
			"∗" # asterisk operator
			"⋅" # dot operator
			"∙" # bullet operator
			"•" # bullet (are you kidding me?)
			"✗" # ballot
			"✘" # heavy ballot
		]
		precedence: 2
		fn: (lhs, rhs)-> lhs * rhs
	
	new Operator
		match: [
			"÷" # obelus
			"/" # slash
			"∕" # division slash
			"divided by"
		]
		bad_match: [
			"／" # fullwidth solidus
			"⁄" # fraction slash
		]
		precedence: 2
		fn: (lhs, rhs)-> lhs / rhs
	
	new Operator
		match: [
			"+"
			"plus"
		]
		bad_match: [
			"＋" # fullwidth plus
			"﬩" # Hebrew alternative plus sign (only English is supported, plus + is the internationally standard plus symbol) 
		]
		precedence: 1
		fn: (lhs, rhs)-> lhs + rhs
	
	new Operator
		match: [
			"−" # minus
			"-" # hyphen-minus
			"minus"
		]
		precedence: 1
		fn: (lhs, rhs)-> lhs - rhs
	
	new Operator
		match: [
			"−" # minus
			"-" # hyphen-minus
			"negative"
			"the opposite of"
		]
		bad_match: [
			"minus"
		]
		precedence: 1
		right_associative: yes
		unary: yes
		fn: (rhs)-> -rhs
	
	new Operator
		match: [
			"+"
			"positive"
		]
		bad_match: [
			"plus"
		]
		precedence: 1
		right_associative: yes
		unary: yes
		fn: (rhs)-> +rhs
	
	new Operator
		match: [
			"≥"
			">="
			"is greater than or equal to"
		]
		bad_match: [
			"is more than or equal to"
		]
		precedence: 0
		fn: (lhs, rhs)-> lhs >= rhs
	
	new Operator
		match: [
			"≤"
			"<="
			"is less than or equal to"
		]
		precedence: 0
		fn: (lhs, rhs)-> lhs <= rhs
	
	new Operator
		match: [
			">"
			"is greater than"
		]
		bad_match: [
			"is more than"
		]
		precedence: 0
		fn: (lhs, rhs)-> lhs > rhs
	
	new Operator
		match: [
			"<"
			"is less than"
		]
		precedence: 0
		fn: (lhs, rhs)-> lhs < rhs
	
	new Operator
		match: [
			"≠"
			"!="
			"does not equal"
			"is not equal to"
			"isn't"
			"is not"
		]
		bad_match: [
			"isnt" # this isn't CoffeeScript, you can actually punctuate contractions
			"isnt equal to" # ditto
			"isn't equal to" # this sounds slightly silly to me
		]
		precedence: 0
		fn: (lhs, rhs)-> lhs isnt rhs
	
	new Operator
		match: [
			"="
			"equals"
			"is equal to"
			"is"
		]
		bad_match: [
			"=="
			"==="
		]
		precedence: 0
		fn: (lhs, rhs)->
			# if a.every((token)-> token.type is "word")
			# 	name = a.join(" ")
			# 	value = @eval_tokens(b)
			# 	if @constants.has(name)
			# 		unless @constants.get(name) is value
			# 			throw new Error "#{name} is already defined as #{@constants.get(name)} (which does not equal #{value})"
			# 	else if @constants.has(name)
			# 		unless @constants.get(name) is value
			# 			throw new Error "#{name} is already defined as #{@variables.get(name)} (which does not equal #{value})"
			# 	else
			# 		@variables.set(name, value)
			# else
			lhs is rhs
	
]
