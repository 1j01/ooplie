
{expect} = require?("chai") ? chai
{Context, Range} = require?("../src/ooplie.coffee") ? Ooplie

context = new Context

evaluate = (expression)->
	result = context.eval(expression)
	to = (value)-> expect(result).to.eql(value)
	to.a = (type)-> expect(result).to.be.a(type)
	{to}

suite "mathematics", ->
	test "plain numbers", ->
		evaluate("5").to(5)
		evaluate("-2").to(-2)
		evaluate("-2.5").to(-2.5)
		evaluate("+2.345").to(+2.345)
		evaluate("90").to(90)
		evaluate("90.00").to(90.00)
	test.skip "numbers with commas", ->
		evaluate("5,000").to(5000) # throw style error? commas are sometimes used as decimal marks
		evaluate("5,000,000").to(5000000) # throw style error? commas are sometimes used as decimal marks
		evaluate("5,0").to(5.0) # throw style error
		# https://en.wikipedia.org/wiki/Decimal_mark
	test.skip "numbers with exponents", ->
		evaluate("5e3").to(5000)
		evaluate("5.5e3").to(5500)
		evaluate("5.5E3").to(5500) # throw style error for uppercase
	test.skip "numbers with radices", ->
		evaluate("0xf0f0").to(0xf0f0)
		evaluate("0b0101").to(0b0101)
		evaluate("0o744").to(0o744)
		evaluate("0Xf0f0").to(0xf0f0) # throw style error for uppercase
		evaluate("0Bf0f0").to(0b0101) # throw style error for uppercase
		evaluate("0O744").to(0o744) # throw style error for uppercase
		evaluate("0744").to(0o744) # throw style error for implicit octal!
		evaluate("0x0b0").to(176)
		evaluate("0x0B1").to(177)
		evaluate("0xE1").to(225)
	test.skip "infinity", ->
		evaluate("∞").to(Infinity)
		evaluate("-∞").to(-Infinity)
	test.skip "addition", ->
		evaluate("1 + 2").to(3)
		evaluate("992+345").to(1337)
	test.skip "subtraction", ->
		evaluate("1 - 2").to(-1)
		evaluate("992-345").to(647)
	test.skip "multiplication", ->
		evaluate("5 * 2").to(10)
		evaluate("7*4").to(28)
	test.skip "division", ->
		evaluate("2 / 4").to(0.5)
		evaluate("100 / 4").to(25)
	test.skip "exponentiation", ->
		evaluate("2 ^ 8").to(256)
		evaluate("2 ** 8").to(256) # throw error
		evaluate("32^0.8").to(16)
	test.skip "equality comparison", ->
		evaluate("5 = 5").to(true)
		evaluate("5 = 5 = 5").to(true)
		evaluate("5 = 3").to(false)
		evaluate("false = false").to(true)
		evaluate("true = true").to(true)
		evaluate("true = false").to(false)
		evaluate("5 = 5 = 3").to(false)
		evaluate("5 = 5 = true").to(false)
		evaluate("5 == 5").to(true) # throw error, just use =
		evaluate("5 === 5").to(true) # throw error, just use =
	test.skip "inequality comparison", ->
		evaluate("5 <= 5").to(true)
		evaluate("5 >= 5").to(true)
		evaluate("5 < 5").to(false)
		evaluate("5 > 5").to(false)
		evaluate("4 > 5").to(false)
		evaluate("4 < 5").to(true)
		evaluate("4 > 5").to(true)
		evaluate("4 >= 5").to(true)
		evaluate("4 <= 5").to(false)
		evaluate("-0 < +0").to(false)
		evaluate("-1 < +1").to(true)
		evaluate("5 != 3").to(true)
		evaluate("5 != 5").to(false)
	test.skip "parenthesis", ->
		evaluate("(1)").to(1)
		evaluate("3 * (6 - 1)").to(3 * (6 - 1))
		evaluate("(3 * 6) - 1").to((3 * 6) - 1)
	test.skip "order of operations", ->
		evaluate("3 * 6 - 1").to(3 * 6 - 1)
		evaluate("3 * 6-1").to(3 * 6 - 1) # throw style error when whitespace obfuscates order of operations
		evaluate("3*6 - 1").to(3 * 6 - 1) # but not when it enforces it
		evaluate("0.0 + -.25 - -.75 + 0.0").to(0.5)
		evaluate("2, 2^1^3").to(0.5)
		evaluate("1 + 3 ^ 3 * 2").to(55) # throw style error / warning for exponents with whitespace
		evaluate("1+3 ^ 3*2").to(55) # definitely throw here
		evaluate("1 + 3^3 * 2").to(55) # that's more like it
		evaluate("-2^2").to(-4)
	test.skip "percentages", ->
		# should this be a style error? percentages, like degrees, are kinda arbitrary and I don't like them
		# but that's probably not a good enough basis for forbidding them
		evaluate("50%").to(50 / 100)
		evaluate("50‰").to(50 / 1000) # permille, tho?
		evaluate("50‱").to(50 / 10000) # c'mon
		# ridiculous:
		evaluate("1 basis point = 1 permyriad = one one-hundredth percent").to(true)
		evaluate("1 bp = 1‱ = 0.01% = 0.1‰ = 10^(−4) = 1⁄10000 = 0.0001").to(true)
		evaluate("1% = 100 bp = 100‱").to(true)
	test.skip "implicit multiplication", ->
		# should this be a style error? explicit is generally better than implicit
		context.eval("x = 5")
		evaluate("2x").to(10)
		evaluate("1/2x").to(1/10) # or...
		evaluate("1/2x").to(5/2)
		# yeah, maybe this should be disallowed
		# at least the slash division without whitespace should be
		evaluate("1 / 2x").to(1/10)
		evaluate("(1/2)x").to(5/2)
		# TODO: also e.g. five x
	test.skip "unicode operators", ->
		evaluate("5 − 6").to(5 - 6)
		evaluate("5 × 6").to(5 * 6)
		evaluate("5 ⋅ 6").to(5 * 6) # dot operator (throw style error?)
		evaluate("5 ∗ 6").to(5 * 6) # asterisk operator (throw style error?)
		evaluate("5 ∙ 6").to(5 * 6) # bullet operator (throw style error?)
		evaluate("5 • 6").to(5 * 6) # bullet (throw style error!)
		evaluate("5⁄6").to(5/6) # fraction slash
		evaluate("5 ⁄ 6").to(5/6) # fraction slash used wrong (throw style error!)
		evaluate("5 ∕ 6").to(5 / 6) # division slash
		evaluate("5 ／ 6").to(5 / 6) # full width solidus
		evaluate("5 ÷ 6").to(5 / 6) # obelus
	test.skip "unicode inequality comparisons", ->
		evaluate("5 ≤ 5").to(true)
		evaluate("5 ≥ 5").to(true)
		evaluate("4 ≥ 5").to(true)
		evaluate("4 ≤ 5").to(false)
		evaluate("5 ≠ 3").to(true)
		evaluate("5 ≠ 5").to(false)
		evaluate("5 ≟ 3").to(false) # questioned equal (should we be using this for within expressions? I guess not since there's no oposite version)
		evaluate("5 ≟ 5").to(true)
	test.skip "basic word numbers", ->
		evaluate("zero").to(0)
		evaluate("one").to(1)
		evaluate("two").to(2)
		evaluate("three").to(3)
		evaluate("four").to(4)
		evaluate("five").to(5)
		evaluate("six").to(6)
		evaluate("seven").to(7)
		evaluate("eight").to(8)
		evaluate("nine").to(9)
		evaluate("ten").to(10)
		evaluate("eleven").to(11)
		evaluate("twelve").to(12)
		evaluate("thirteen").to(13)
		evaluate("fourteen").to(14)
		evaluate("fifteen").to(15)
		evaluate("sixteen").to(16)
		evaluate("seventeen").to(17)
		evaluate("eighteen").to(18)
		evaluate("nineteen").to(19)
		evaluate("twenty").to(20)
	test.skip "complex word numbers", ->
		evaluate("twenty one").to(21)
		evaluate("twenty-two").to(22)
		evaluate("twenty + 3").to(23)
		evaluate("twenty+4").to(24)
		evaluate("twenty-5").to(25)
		evaluate("twentysix").to(26)
		evaluate("twenty‒seven").to(27) # figure dash used (probably not really correct usage)
		evaluate("thirty-eight").to(38)
		evaluate("fourty-nine").to(49) # throw spelling error
		evaluate("forty-nine").to(49)
		evaluate("fifty").to(50)
		evaluate("sixty-one").to(61)
		evaluate("seventy-two").to(72)
		evaluate("eighty-three").to(83)
		evaluate("ninety-four").to(94)
		evaluate("a hundred").to(100)
		evaluate("one hundred").to(100)
		evaluate("two hundred").to(200)
		evaluate("Two hundred fifty-six").to(256)
		evaluate("Two-hundred-fifty-six").to(256) # TODO: throw style error
		evaluate("Two-thousand five").to(2005)
		evaluate("Two-thousand and five").to(2005) # throw style error / warning
		evaluate("Twenty-three hundred sixty-one").to(2361)
		evaluate("negative one").to(-1)
		evaluate("negative twenty-three hundred sixty-one").to(-2361)
	test.skip "special word numbers", ->
		evaluate("nought = naught = zilch = nada = zip = zero").to(true)
		evaluate("a banker's dozen").to(11)
		evaluate("a dozen").to(12)
		evaluate("a baker's dozen").to(13)
		evaluate("a score").to(20) # might conflict with scoring games, and shouldn't really be used
		evaluate("a million").to(1000000)
		evaluate("a million and a half").to(1000000.5) # (the year mankind is enslaved by giraffe)
		evaluate("a and a half million").to(1500000)
		evaluate("a billion").to(1000000000) # throw style error? https://en.wikipedia.org/wiki/Long_and_short_scales
		evaluate("a trillion").to(1000000000000) # throw style error? https://en.wikipedia.org/wiki/Long_and_short_scales
		# lots more here: https://en.wikipedia.org/wiki/English_numerals#Cardinal_numbers
	test.skip "fractional word numbers", ->
		evaluate("half").to(1/2)
		evaluate("one half").to(1/3)
		evaluate("one third").to(1/3)
		evaluate("one fourth").to(1/4)
		evaluate("one quarter").to(1/4)
		evaluate("a fifth").to(1/5)
		evaluate("a sixth of 2").to(2/6)
		evaluate("one seventh").to(1/7)
		evaluate("three eighths").to(3/8)
		evaluate("one nineth").to(1/9)
		evaluate("one tenth").to(1/10)
		evaluate("one eleventh").to(1/11)
		evaluate("one twelth").to(1/12)
		evaluate("one thirteenth").to(1/13)
	test.skip "word operators", ->
		evaluate("5 plus 6").to(11)
		evaluate("5 minus 6").to(-1)
		evaluate("5 times 6").to(5 * 6)
		evaluate("5 divided by 6").to(5 / 6)
		evaluate("5 over 6").to(5 / 6) # throw style warning / error
		evaluate("half of 6").to(3)
		evaluate("a third of 12").to(4)
		evaluate("2 thirds of 12").to(8)
		evaluate("twice 6").to(12) # throw style warning / error?
		evaluate("thrice 2").to(6) # throw style warning / error?
		evaluate("3 doubled").to(6) # throw style warning / error?
		evaluate("5 less than 7").to(2) # throw style warning / error?
		evaluate("5 more than 7").to(5 + 7) # throw style error
		evaluate("5 greater than 7").to(5 + 7) # throw style warning / error?
		evaluate("2 to the power of 8").to(256)
		evaluate("2 to the 8th power").to(256)
		evaluate("the square root of 2").to(Math.sqrt(2))
		evaluate("the cubic root of 2").to(Math.pow(2, 1/3)) # throw style error
		evaluate("the cube root of 2").to(Math.pow(2, 1/3))
		# TODO: nth roots
	test.skip "worded comparisons", ->
		evaluate("5 equals 5").to(true)
		evaluate("5 is 5").to(true)
		evaluate("5 is not 4").to(true)
		evaluate("5 does not equal 4").to(true)
		evaluate("5 isnt 4").to(true) # throw error
		evaluate("5 isn't 4").to(true)
		evaluate("5 is not equal to 4").to(true)
		evaluate("5 is equal to 4").to(false)
		evaluate("5 is equal to 5").to(true)
		evaluate("Does 4 equal 5?").to(no)
		evaluate("Does 4 = 5?").to(no)
		evaluate("Does 5 equal 5?").to(yes)
		evaluate("Does 5 = 5?").to(yes)
		evaluate("Is 5 less than 3?").to(no)
		evaluate("Is 3 less than 5?").to(yes)
		evaluate("Is 3 more than 5?").to(no) # throw style error
		evaluate("Is 5 greater than 3?").to(yes)
	test.skip "ranges (intervals)", ->
		evaluate("from 4 to 6").to(new Range(4, 6)) # inclusive?
		evaluate("between 4 and 6").to(new Range(4, 6)) # exclusive?
		evaluate("between 4 and 6, inclusive").to(new Range(4, 6)) # inclusive
		evaluate("between 4 and 6, exclusive").to(new Range(4, 6)) # exclusive
		evaluate("from 4 to 6, inclusive").to(new Range(4, 6)) # inclusive
		evaluate("from 4 to 6, exclusive").to(new Range(4, 6)) # exclusive
		evaluate("9 plus or minus 0.1").to(new Range(8.9, 9.1)) # throw error/warning? can mean plus-minus
		evaluate("9 give or take 0.1").to(new Range(8.9, 9.1))
		evaluate("4..6").to(new Range(4, 6)) # should we have these? (inclusive?)
		evaluate("4...6").to(new Range(4, 6)) # should we have these? (exclusive?)
		# TODO: mathematical interval notation
	test.skip "units", ->
		evaluate("5mm").to("5m")
		evaluate("5mm = 5m").to(false)
		evaluate("5000mm = 5m").to(true)
		evaluate("5m - 500mm = 4.5m").to(true)
		evaluate("5m / 1m").to(5)
		evaluate("5m = 5g").to(false) # throw comparison error?
	test.skip "derived units", ->
		evaluate("10m2 / 2m = 5m").to(true)
	test.skip "word units", ->
		evaluate("1 second = 1s").to(true)
		evaluate("1 millisecond = 1ms").to(true)
		evaluate("1 kilogram = 1kg").to(true)
		evaluate("10 kilos = 10kg").to(true)
		evaluate("10meters = 10m").to(true) # throw style warning?
		evaluate("1sec = 1s").to(true)
		evaluate("1A = 1 ampere").to(true)
		evaluate("300 K = 300 kelvin").to(true)
		evaluate("1 mole = 1mol").to(true)
		evaluate("1 candela = 1cd").to(true)
		evaluate("1m2 = 1 square meter").to(true)
		evaluate("1m = 1 linear meter").to(true) # explicitly denoting the first power of the unit
	test.skip "time units", ->
		# TODO: move to time.coffee?
		evaluate("1h = 1hr = 1 hour").to(true)
		evaluate("1min = 60s").to(true)
		evaluate("1hr = 60min").to(true)
		evaluate("1h = 60m").to(true) # don't throw comparison error? (m is normally meters)
		evaluate("1 day = 24 hours").to(true)
		evaluate("1 day = 34 hours").to(false) # just throwing some falsities in there for good measure
		evaluate("an hour = 1h").to(true)
		evaluate("half a day = 12 hours").to(true)
		evaluate("half a day = 12 hours").to(true)
		# let's maybe not define months and years? since they vary in days?
		# maybe it should throw an error and tell you to do calcualtions on specific date-time values
		evaluate("a decade = 10 years").to(true)
		evaluate("a century = 100 years").to(true)
		evaluate("a millennium = 1000 years").to(true)
		evaluate("an eon = one million years").to(true) # throw error for ill-defined unit?
	test.skip "temperature units", ->
		evaluate("32°F = 0°C").to(true)
		evaluate("38°C = thirty-eight degrees Celsius").to(true)
		evaluate("80°F = 80 degrees Fahrenheit").to(true)
		evaluate("0 K = −273.15 °C = −459.67 °F").to(true)
		evaluate("233.15 K −40 °C = −40 °F").to(true)
		evaluate("0 K = 0K").to(true) # throw style error?
		evaluate("5℃ = 5°C").to(true) # throw style error! ("The Unicode standard explicitly discourages the use of this character")
		evaluate("70 µ°C = 70 µK").to(true) # ?
		evaluate("100°R = 100°Ra = 100 degrees Rankine = 100 rankine").to(true)
		evaluate("0°R = 0 K").to(true)
		evaluate("491.67 °R = 273.15 K = 0 °C").to(true)
	test.skip "legit math", ->
		evaluate("1 like = 1 prayer").to(false)
		evaluate("a goof + a laugh = a gaff").to(true)
		evaluate("a goof + a gaff = a gaff").to(true) # the distributive poppardy
		evaluate("a laugh + a goof = a spoof").to(true)
		evaluate("a laugh + a goof + a gaff = a romp").to(true)
		evaluate("a look + a gaff = a gander").to(true)
		evaluate("a spoof + a boo = a spook").to(true)
		evaluate("a gaff + a neck = a giraffe").to(true)
		evaluate("Pegasus + unicorn = pegacorn").to(true)
		evaluate("shark + octopus = Sharktopus").to(true)
		evaluate("shark + tornado = Sharknado").to(true)
	test.skip "unit equality", ->
		# should this be a thing?
		# what if you want a variable s? what about s = sec = second = 2nd?
		evaluate("s = ms").to(false)
		evaluate("s = seconds").to(true)
		evaluate("sec = 1000ms").to(true)
	test.skip "ordinal numbers (1st, 2nd, 3rd, 4th...)", ->
		evaluate("1st = first").to(true)
		evaluate("2st = second").to(true) # throw style error
		evaluate("2nd = second").to(true)
		evaluate("1nd = second").to(false) # throw style error
		evaluate("3rd = third").to(true)
		evaluate("2rd = second").to(false) # throw style error
		evaluate("4th = fourth").to(true)
		evaluate("5th = fifth").to(true)
		evaluate("6th = sixth").to(true)
		evaluate("7th = seventh").to(true)
		evaluate("8th = eighth").to(true)
		evaluate("9th = nineth").to(true)
		evaluate("10th = tenth").to(true)
		evaluate("11th = eleventh").to(true)
		evaluate("12th = twelth").to(true)
		evaluate("13th = thirteenth").to(true)
		evaluate("20th = twentieth").to(true)
		evaluate("21th = twenty-first").to(true) # throw style error
		evaluate("21st = twenty-first").to(true)
		evaluate("22nd = twenty-second").to(true)
		evaluate("23rd = twenty-third").to(true)
		evaluate("30th = thirtieth").to(true)
		evaluate("31st = thirty-first").to(true)
		evaluate("40th = fourtieth").to(true)
		evaluate("41st = fourty-first").to(true) # throw spelling error
		evaluate("41st = forty-first").to(true)
		evaluate("50th = fiftieth").to(true)
		evaluate("51st = fifty-first").to(true)
		evaluate("60th = sixtieth").to(true)
		evaluate("61st = sixty-first").to(true)
		evaluate("70th = seventieth").to(true)
		evaluate("71st = seventy-first").to(true)
		evaluate("80th = eightieth").to(true)
		evaluate("81st = eighty-first").to(true)
		evaluate("90th = ninetieth").to(true)
		evaluate("91st = ninety-first").to(true)
		evaluate("100th = one hundredth").to(true)
		evaluate("101st = one hundred first").to(true) # should this be "one hundred and first"?
		evaluate("102nd = one hundred second").to(true) # should this be "one hundred and second"?
		evaluate("103rd = last place").to(true)
		evaluate("104th = ????").to(false) # throw error, numbers don't go that high
		evaluate("105th = one hundred fifth").to(true) # should this be "one hundred and fifth"?
		evaluate("100 seconds = one hundred second").to(false)
	test.skip "boolean logic", ->
		evaluate("true and true").to(true)
		evaluate("false and true").to(false)
		evaluate("true and false").to(false)
		evaluate("false and false").to(false)
		evaluate("10 = 10 and 5 = 5").to(true)
		evaluate("10 = 10 and 5 = 3").to(false)
		evaluate("10 = 5 and 5 = 5").to(false)
		evaluate("true or true").to(true)
		evaluate("true or false").to(true)
		evaluate("false or true").to(true)
		# TODO: order of operations should be tested for boolean logic
		# TODO: xor, nor, xnor
		# TODO: test unicode boolean operators
	test.skip "whether", ->
		evaluate("whether 10 = 10").to(true)
		evaluate("whether 10 is 10").to(true)
		evaluate("whether 10 = 4").to(false)
		evaluate("whether 10 is 4").to(false)
		evaluate("(whether 10 is 4) = false").to(true)
	test.skip "modulo", ->
		evaluate("10 modulo 4").to(2)
		evaluate("10 modulo 14").to(10)
		evaluate("10 mod 5").to(0)
		evaluate("-10 mod 5").to(0)
		evaluate("-10 mod 3.25").to(3)
		evaluate("10 mod -3.25").to(3)
		evaluate("-10 mod -3.25").to(-0.25)
		evaluate("-10 % -3.25").to(-0.25) # throw style error
	test.skip "more unicode fun", ->
		evaluate("√2 = √(2) = sqrt(2) = the square root of two").to(true)
		evaluate("1ˢᵗ = 1st").to(true)
		evaluate("2ⁿᵈ = 2nd").to(true)
		evaluate("3ʳᵈ = 3rd").to(true)
		evaluate("4ᵗʰ = 4th").to(true)
		evaluate("⊨").to(true)
		evaluate("⊭").to(false)
		evaluate("⊤").to(true)
		evaluate("⊥").to(false)
		evaluate("¬true").to(false)
		evaluate("¬false").to(true)
		# TODO: superscript/subscript fractions and stuff
	test.skip "defining functions", ->
		context.eval("f(x) = x * 2")
		evaluate("f(5)").to(10)
		context.eval("funk(x, y) = f(x) + y")
		evaluate("funk(5, 0)").to(10)
		evaluate("funk(5, 1)").to(11)
		evaluate("funk(5)").to(undefined) # throw error: not enough arguments
		evaluate("funk(5, 5, 5)").to(undefined) # throw error: too many arguments
		evaluate("f()").to(undefined) # throw error: not enough arguments
	test.skip "complex functions", ->
		context.eval("signat(x) = if x < 0 then -1 else if x > 0 then +1 else 0")
		evaluate("signat(5)").to(+1)
		evaluate("signat(-5)").to(-1)
		evaluate("signat(0)").to(0)
	test.skip "recursive functions"
	test.skip "built-in math functions"
	
	test.skip "overwriting variable values? e.g. incrementing/decrementing"
	# hopefully not? except for with interop?
	
	suite "sets", ->
		test.skip "use native Set objects", ->
			expect(context.eval("{1, 2, 3}")).to.be.a(Set)
			expect(context.eval("{1}").has(1)).to.be(true)
			expect(context.eval("{}")).to.be.a(Set)
			expect(context.eval("{}").has(1)).to.be(false)
		test.skip "set identity", ->
			evaluate("{} = {}").to(true)
			evaluate("Ø = {}").to(true) # throw style error/warning?
			evaluate("∅ = {}").to(true) # this character is the proper one
			evaluate("∅ = {1}").to(false)
			evaluate("{} = the empty set").to(true)
			evaluate("{} = the null set").to(true)
			evaluate("{} = nothing").to(true)
			evaluate("{} = null").to(true)
			evaluate("∅ is empty").to(true)
			evaluate("{} is empty").to(true)
			evaluate("{∅} is empty").to(false)
			evaluate("{1} = {1}").to(true)
			evaluate("{1, 2, 3} = {1, 2, 3}").to(true)
			evaluate("{1, 2} = {1, 2, 3}").to(false)
			evaluate("{3, 2, 1} = {1, 2, 3}").to(true)
			evaluate("{11, 6, 6} = {11, 6}").to(true)
			evaluate("{1, 1+1, 1+1+1} = {1, 2, 3}").to(true)
		test.skip "set membership", ->
			evaluate("{1, 2, 3} contains 2").to(true)
			evaluate("{1, 2, 3} contains 5").to(false)
			evaluate("{1, 2, 3} contains {1, 2, 3}").to(false) # unless you define a contains b as a is a superset of b
			evaluate("{{1, 2, 3}} contains {1, 2, 3}").to(true)
			# I hope you're not dealing with inventory items and DOM Elements because that could be confusingly ambiguous
			# I guess if you're trying to check how many Elements are in a set, the set is probably a set of Elements anyways
			evaluate("{0} contains -0").to(true)
			evaluate("{-0} contains 0").to(true)
			evaluate("1 ∈ {1, 2, 3}").to(true) # 1 belongs to {1, 2, 3} = true
			evaluate("4 ∈ {1, 2, 3}").to(false) # 4 belongs to {1, 2, 3} = false
			evaluate("4 ∉ {1, 2, 3}").to(true) # 4 does not belong to {1, 2, 3} = true
			evaluate("1 ∉ {1, 2, 3}").to(true) # 1 does not belong to {1, 2, 3} = false
			evaluate("1 belongs to {1}").to(true)
			evaluate("1 is within {1}").to(true)
			evaluate("1 belongs to {}").to(false)
			evaluate("1 is within {}").to(false)
			evaluate("1 belongs to {one}").to(true)
			evaluate("1 is within {one}").to(true)
			evaluate("one belongs to {1}").to(true)
		test.skip "set cardinality", ->
			evaluate("{1, 2, 3} contains 3 items").to(true)
			evaluate("{1, 2, 3} contains 2 or more items").to(true)
			evaluate("{1, 2, 3} contains 3 elements").to(true)
			evaluate("{1, 2, 3} contains 2 or more elements").to(true)
			evaluate("{1, 2, 3} has 2 or more elements").to(true)
			evaluate("{1, 2, 3} has 2 or more members").to(true)
			evaluate("the number of members of {1, 2, 3}").to(3)
			evaluate("the number of elements in {1, 2, 3}").to(3)
			evaluate("the cardinality of {1, 2, 3}").to(3)
			evaluate("What's the cardinality of {1, 2, 3}?").to(3)
			evaluate("| {1, 2, 3} |").to(3)
			evaluate("How many items does {1, 2, 3} contain?").to(3)
			evaluate("How many items does {1, 100, 30, 4} have?").to(4)
			evaluate("How many elements does {2, 4, 6, 8, 10} contain?").to(5)
			evaluate("How many elements does {-1, 0, 1} have?").to(3)
			evaluate("How many members does {-1, 0, 1} have?").to(3)
		test.skip "subsets", ->
			evaluate("{} is a subset of {1}").to(true)
			evaluate("{1} is a subset of {}").to(false)
			evaluate("{} is a subset of {}").to(true)
			evaluate("{1} is a subset of {1}").to(true)
			evaluate("{} ⊆ {1}").to(true)
			evaluate("{} ⊆ {}").to(true)
			evaluate("{1} ⊆ {1}").to(true)
			evaluate("{1} ⊆ {}").to(false)
		test.skip "supersets", ->
			evaluate("{1} is a superset of {}").to(true)
			evaluate("{} is a superset of {1}").to(false)
			evaluate("{} is a superset of {}").to(true)
			evaluate("{1} is a superset of {1}").to(true)
			evaluate("{1} ⊇ {}").to(true)
			evaluate("{} ⊇ {1}").to(false)
			evaluate("{} ⊇ {}").to(true)
			evaluate("{1} ⊇ {1}").to(true)
		test.skip "strict subsets", ->
			evaluate("{1} is a strict subset of {}").to(true)
			evaluate("{} is a strict subset of {1}").to(false)
			evaluate("{} is a strict subset of {}").to(false)
			evaluate("{1} is a strict subset of {1}").to(true)
			evaluate("{} ⊊ {1}").to(true)
			evaluate("{} ⊊ {}").to(true)
			evaluate("{1} ⊊ {1}").to(true)
			evaluate("{1} ⊊ {}").to(false)
		test.skip "strict supersets", ->
			evaluate("{1} is a strict superset of {}").to(true)
			evaluate("{} is a strict superset of {1}").to(false)
			evaluate("{} is a strict superset of {}").to(false)
			evaluate("{1} is a strict superset of {1}").to(true)
			evaluate("{} ⊋ {1}").to(true)
			evaluate("{} ⊋ {}").to(true)
			evaluate("{1} ⊋ {1}").to(true)
			evaluate("{1} ⊋ {}").to(false)
		# TODO: negative operators (⊄⊅⊈⊉)
		test.skip "ambiguous subset/superset operators", ->
			# ideally these operators would be the strict operators
			evaluate("{1} ⊂ {1}").to(false) # throw ambiguity error
			evaluate("{1} ⊃ {1}").to(false) # throw ambiguity error
		test "unions"
		test "intersections"
		test "compliments"
		test "Cartesian product"
		test "power sets"
	
	test.skip "plus-minus", ->
		evaluate("9 +- 0.1").to(9 - 0.1) # throw style error!
		evaluate("9 -+ 0.1").to(9 - 0.1) # throw style error!
		evaluate("9 ± 0.1 = {9 - 0.1, 9 + 0.1}").to(true)
		evaluate("9 ∓ 0.1 = {9 - 0.1, 9 + 0.1}").to(true) # style error/warning? should you always use plus-minus when there's only one use?
		evaluate("10 ± 2 ∓ 0.1 = {10 + 2 - 0.1, 10 - 2 + 0.1}").to(true)
		# Another example is x^3 ± 1 = (x ± 1)(x^2 ∓ x + 1) which represents two equations.
		evaluate("")
		# "plus and minus" or "plus-minus" for plus-minus?
		# "minus and plus" or "minus-plus" for minus-plus?
		# "plus or minus" or "plus-minus" for plus-minus
		# "minus or plus" or "minus-plus" for minus-plus
		# NOTE: can mean other things, such as a margin of error
	test "null, nil, nothin'?"
	test "bitwise operators"
	test "ordered pairs (i.e. coordinates)"
	test "matrices"
	test "quaternions"
	test "complex numbers"
	test "algebra and all the other math (easy enough, right? haha? hahaha? hahahahaha? AHAHAHAHAAAAAAAGH)"
		# TODO: https://en.wikipedia.org/wiki/ISO_31-11
	test "interaction of various things"
	test "MathML"
