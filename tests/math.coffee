
OOPLiE = require "./src/ooplie.coffee"

{Range} = OOPLiE
context = new OOPLiE

evaluate = (expression)->
	to: expect(context.eval(expression)).to.eql

suite "mathematics", ->
	test "plain numbers", ->
		evaluate("5").to(5)
		evaluate("-2").to(-2)
		evaluate("-2.5").to(-2.5)
		evaluate("+2.345").to(+2.345)
	test "numbers with commas", ->
		evaluate("5,000").to(5000) # throw style error? commas are sometimes used as decimal marks
		# https://en.wikipedia.org/wiki/Decimal_mark
	test "numbers with exponents", ->
		evaluate("5e3").to(5000)
		evaluate("5.5e3").to(5000)
	test "infinity", ->
		evaluate("∞").to(Infinity)
		evaluate("-∞").to(-Infinity)
	test "addition", ->
		evaluate("1 + 2").to(3)
		evaluate("992+345").to(1337)
	test "subtraction", ->
		evaluate("1 - 2").to(-1)
		evaluate("992-345").to(647)
	test "multiplication", ->
		evaluate("5 * 2").to(10)
		evaluate("7*4").to(28)
	test "division", ->
		evaluate("2 / 4").to(0.5)
		evaluate("100 / 4").to(25)
	test "exponentiation", ->
		evaluate("2 ^ 8").to(256)
		evaluate("32^0.8").to(16)
	test "plus-minus", ->
		# should probably be a set of two possible numbers
		evaluate("9 +- 0.1").to(new Range(8.9, 9.1))
	test "equality", ->
		evaluate("5 = 5").to(true)
		evaluate("5 = 5 = 5").to(true)
		evaluate("5 = 3").to(false)
		evaluate("5 = 5 = 3").to(false)
		evaluate("5 = 5 = true").to(false)
	test "inequality", ->
	test "parenthesis", ->
	test "order of operations", ->
	test "unicode operators", ->
		evaluate("5 <times> 6").to(11)
		evaluate("5 − 6").to(5 - 6)
		evaluate("5 ⋅ 6").to(5 * 6)
		evaluate("5∕6").to(5/6)
		evaluate("5  6").to(5 / 6)
		evaluate("9 ∓ 0.1").to(new Range(8.9, 9.1)) # probably not a range
	test "basic word numbers", ->
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
	test "complex word numbers", ->
		evaluate("twenty one").to(21)
		evaluate("twenty-two").to(22)
		evaluate("twenty + 3").to(23)
		evaluate("twenty+4").to(24)
		evaluate("twenty-5").to(25)
		evaluate("twentysix").to(26)
		evaluate("twenty‒seven").to(27) # figure dash used (probably not really correct usage)
		evaluate("thirty-eight").to(38)
		evaluate("fourty-nine").to(49)
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
		evaluate("Twenty-three hundred sixty-one").to(2361)
		evaluate("a dozen").to(12)
		evaluate("a baker's dozen").to(13)
		evaluate("a million").to(1000000)
		evaluate("a million and a half").to(1000000.5) # (the year mankind is enslaved by giraffe)
		evaluate("a and a half million").to(1500000)
		evaluate("a billion").to(1000000000) # throw style error? https://en.wikipedia.org/wiki/Long_and_short_scales
		evaluate("a trillion").to(1000000000000) # throw style error? https://en.wikipedia.org/wiki/Long_and_short_scales
	test "fractional word numbers", ->
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
	test "word operators", ->
		evaluate("5 plus 6").to(11)
		evaluate("5 minus 6").to(-1)
		evaluate("5 times 6").to(5 * 6)
		evaluate("5 divided by 6").to(5 / 6)
		evaluate("5 over 6").to(5 / 6)
		evaluate("half of 6").to(3)
		evaluate("a third of 12").to(4)
		evaluate("2 thirds of 12").to(8)
		evaluate("twice 6").to(12) # throw style warning / error?
		evaluate("thrice 2").to(6) # throw style warning / error?
		evaluate("3 doubled").to(6) # throw style warning / error?
		evaluate("2 to the power of 8").to(256)
		evaluate("2 to the 8th power").to(256)
		evaluate("9 plus or minus 0.1").to(new Range(8.9, 9.1)) # probably not a range
	test "ranges", ->
		evaluate("between 4 and 6").to(new Range(4, 6)) # exclusive?
		evaluate("from 4 to 6").to(new Range(4, 6)) # inclusive?
		evaluate("4..6").to(new Range(4, 6)) # ?
		evaluate("4...6").to(new Range(4, 6)) # ?
	test "units", ->
		evaluate("5mm").to("5m")
		evaluate("5mm = 5m").to(false)
		evaluate("5000mm = 5m").to(true)
		evaluate("5m - 500mm = 4.5m").to(true)
		evaluate("5m / 1m").to(5)
		evaluate("5m = 5g").to(false) # throw comparison error?
	test "derived units", ->
		evaluate("10m2 / 2m = 5m").to(true)
	test "word units", ->
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
	test "time units", ->
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
	test "temperature units", ->
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
	test "legit math", ->
		evaluate("1 like = 1 prayer").to(false)
		evaluate("a goof + a laugh = a laugh").to(true)
		evaluate("a goof + a gaff = a gaff").to(true)
		evaluate("a laugh + a goof = a spoof").to(true)
		evaluate("bad + rad = Brad").to(true)
		evaluate("Pegasus + unicorn = pegacorn").to(true)
		evaluate("shark + octopus = Sharktopus").to(true)
		evaluate("shark + tornado = Sharknado").to(true)
	test "unit equality", ->
		# should this be a thing?
		# what if you want a variable s? what about s = sec = second = 2nd?
		evaluate("s = ms").to(false)
		evaluate("s = seconds").to(true)
		evaluate("sec = 1000ms").to(true)
	test "placement (1st, 2nd, 3rd, 4th)", ->
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
		evaluate("41st = fourty-first").to(true)
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
		evaluate("101st = one hundred first").to(true)
		evaluate("102nd = one hundred second").to(true)
		evaluate("103rd = last place").to(true)
		evaluate("104th = ????").to(false) # throw error, numbers don't go that high
	test "whether", ->
		evaluate("whether 10 = 10").to(true)
		evaluate("whether 10 is 10").to(true)
		evaluate("whether 10 = 4").to(false)
		evaluate("whether 10 is 4").to(false)
		evaluate("(whether 10 is 4) = false").to(true)
