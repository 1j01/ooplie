
# Ooplie

Ooplie is a programming system where you write in English.
It runs in [Node.js][] and in the browser.

There's [a nice little console][console] where you can try it out so far.
It has a Parts menu where you can see the available commands and expressions.
Each command has multiple synonyms, often many.
Everything is organized into libraries, and yes, conditionals are defined in a library.
To access libraries for File System manipulation etc. you need to install the console as a desktop app.
To do so, clone the repository, open a terminal/command prompt in `console/` and run `npm install`.
To run the console app, do `npm start`.

<!-- https://en.wikipedia.org/wiki/Controlled_natural_language -->

So far Ooplie is completely [imperative][], and you can't do much with it.
You can output text, evaluate JS, and evaluate Ooplie code,
write mathematical expressions with worded operators, Unicode operators, or ASCII operators,
write trivial (read: useless because there are no variables yet) conditionals,
and read and write text files.

## Inspiration

At the risk of citing an article where the author calls out a programming system citing the author's work as inspiration as terrible as inspiration,
Brett Victor's [Learnable Programming][] expresses some great ideas about the future of programming.

If you're not excited by the prospect of programming in English,
then at least check out some of [Brett Victor's work][]
or maybe [Toward a better programming][],
and get excited about the future of programming in general.

<!-- 
There's a project called [EVE][] that looks interesting.
I'll have to try [it](https://github.com/witheve/Eve) out and see what it's like.

Could gather some quotes here and relate them to the project:

#### Quotes

> I think the next big step in terms of removing incidental complexity in code will come from automatically managing time. The implications of which would be tremendous for our ability to cleanly express intent.

([Toward a better programming][])

Ooplie will have an expressive and rather comprehensive time module.

http://blog.wolfram.com/2010/11/16/programming-with-natural-language-is-actually-going-to-work/

https://multikulti.wordpress.com/2013/01/09/english-as-a-programming-language/

http://repository.cmu.edu/cgi/viewcontent.cgi?article=1165&context=hcii

http://stackoverflow.com/questions/3067377/what-programming-language-is-the-most-english-like

http://stackoverflow.com/questions/19262597/why-no-programming-in-english-what-is-the-difference-between-natural-languages?rq=1

-->

## Motivation

I want see what it would be like to program in English.

I don't think this is the be-all and end-all of programming paradigms.
Unless a future of realtime cross-translated collaborative structured document editing is realized, it's probably not going to be better than a more syntactical programming language for international collaboration on software projects.
High expectations of lingual [disambiguation][] and common sense mean it will never feel smart enough without machine learning and huge amounts of data.
That's not very distributable, so [a compiler would][Programming with Natural Language Is Actually Going to Work] probably work better.
But then you miss certain possiblities afforded by a dynamic interpreter.

**TL;DR:** Someone's gotta do it.


## Roadmap

The first aim will be to get it usable as an imperative interpreter for simple shell scripts.
Scripts will be able to use a shebang comment like `#!/usr/bin/env ooplie`, or hopefully `#!/bin/english`. (`sh`, `bash`, `ksh`, `zsh`, `english`!)

Ooplie will need some better [natural language processing][].

Ooplie should have a good module system.
You should be able to easily write wrappers for modules on [npm][] to give them lingual interfaces.
File system support and other things should be implemented this way.
How the interop should work is not entirely decided.

After that, more complex control flow and mathematics can be added,
and various modules can be developed.

Eventually I want to try hooking speech recognition up to Ooplie
and playing around on a canvas with physics,
maybe try making a web app with this...

#### Integrated Development Environment

There should be an IDE, because an interpreter is not good enough.

It would feature "Did you mean?" style error handling that can update your actual code (especially for disambiguation).

It could let you dig down into statements and expressions to see the underlying meaning and implementation, through your code, through libraries, and to the underlying JavaScript.
Similar features exist [in other IDEs][Peek Definition], but I can imagine it working more like a variant of [code folding][] where you fold layers of meaning and [abstraction][] rather than just blocks of code.
Perhaps like [this][IP levels of detail]?
(Except you wouldn't have to write that lower layer of code, `print the numbers 1 to 10` would just work :smile:)

It should let you write code that isn't understood
and subsequently implement in detail.

It could automatically search for modules related to code you type that isn't understood.
When typed, when run, or at the click of a button.
(A button's probably good.)

It would try to show you what's going on with the program as much as possible.
I'd add a dynamic underline to `Every N seconds` / `After N seconds` representing the timer, and maybe underlines to any line of code being executed.
This might warrant some controls to toggle or dim the underlines as they could be distracting.
<!-- I've never gotten [Light Table][]'s live connection features to work on a real project, but they look cool. -->

![Execution underlines](./images/execution-underlines.gif)

([Execution underlines CSS animation on multifiddle](http://multifiddle.ml/#execution-underlines))

When you have multiple asynchronous code paths,
they may be run either in parallel or in series.
The IDE could show the flow of execution with lines in the margin, making it clearer what would happen.

<!-- Insert larger example of control flow indicators here? -->

For example, here the intent is clear, but will the second action actually run after 10 seconds, or after 15?
```
After 5 seconds, say "reached 5 seconds mark"
After 10 seconds, say "reached 10 seconds mark"
```

Here it's disambiguated:
```
After 5 seconds, say "reached 5 seconds mark"
Then after 5 seconds, say "reached 10 seconds mark"
```

You could also write:
```
After 5 seconds, say "reached 5 seconds mark"
After 5 more seconds, say "reached 10 seconds mark"
```

Dragging the line could change the control flow, updating the code to reflect the changes.

![Control flow indication mockup](./images/control-flow-indication-mockup.png)


The IDE could support visual mathematical equation/expression editing, and resources like images could be dragged and dropped and used directly in expressions.

It could blur the line between entering commands and writing a program (if that's a good thing).

The necessarily dynamic syntax highlighting engine could be made reusable if many things actually allow for dynamic stuff like that, but most things probably only support regular expressions.
However, the entire IDE could be made reusable as a component,
and could be included as a plugin in web-based code editors like [Atom][].


### Dev

Fork the repository on GitHub, and
with [Node.js][] run `npm install` in the project directory.

Run `npm test` to run the tests.
You can also open [`test.html`][tests] (maybe with a [live-server][]) to test Ooplie in a browser,
but note that only a subset of the tests are run.
The File System module can't be tested in the browser, for instance.
If you've been running tests in a browser, be sure to run `npm test` at least once before committing.

Before committing, run `npm run prepublish` to compile `ooplie.js`,
which is included in the repository for [GitHub Pages][] usage.


[multi-paradigm]: https://en.wikipedia.org/wiki/Programming_paradigm "Programming paradigm - Wikipedia"
[imperative]: https://en.wikipedia.org/wiki/Imperative_programming "Imperative programming - Wikipedia"
[abstraction]: https://en.wikipedia.org/wiki/Abstraction_(computer_science) "Abstraction (computer science) - Wikipedia"
[code folding]: https://en.wikipedia.org/wiki/Code_folding "Code folding - Wikipedia"
[IP levels of detail]: https://en.wikipedia.org/wiki/Intentional_programming#Levels_of_detail "\"Levels of detail\" in Intentional programming - Wikipedia"
[natural language processing]: https://en.wikipedia.org/wiki/Natural_language_processing
[disambiguation]: https://en.wikipedia.org/wiki/Word-sense_disambiguation "Word-sense disambiguation - Wikipedia"
[Programming with Natural Language Is Actually Going to Work]: http://blog.wolfram.com/2010/11/16/programming-with-natural-language-is-actually-going-to-work/
[console]: http://1j01.github.io/ooplie/console/
[tests]: ./test.html
[npm]: https://www.npmjs.com/
[live-server]: https://www.npmjs.com/package/live-server
[Node.js]: https://nodejs.org/
[Light Table]: http://lighttable.com/
[Atom]: https://atom.io/
[Learnable Programming]: http://worrydream.com/LearnableProgramming/
[Brett Victor's work]: http://worrydream.com/
[Toward a better programming]: http://www.chris-granger.com/2014/03/27/toward-a-better-programming/
[EVE]: http://eve-lang.com/
[Peek Definition]: https://msdn.microsoft.com/en-us/library/dn160178.aspx
[GitHub Pages]: https://pages.github.com/
