
# Ooplie

Ooplie is a programming system where you write in English.
It runs in [Node.js][] and in the browser.

There's [a nice little console][console] where you can try it out so far.
It has a Parts menu where you can see the available commands and expressions.
Each command has multiple synonyms, often many.
Everything is organized into libraries, including things like conditionals.
To access libraries for File System manipulation etc. you need to install the console as a desktop app.
To do so, [clone the repository][clone a repo], open a terminal/command prompt in `console/` and enter `npm install`.
Then to run the app, enter `npm start`.

<!-- https://en.wikipedia.org/wiki/Controlled_natural_language -->

So far Ooplie is completely [imperative][], and you can't do much with it.
You can output text, evaluate JS, and evaluate Ooplie code (from Ooplie code),
write mathematical expressions with worded operators ("2 to the power of 4"), Unicode operators, or ASCII operators,
write trivial conditionals which are useless because there are no variables yet,
and read and write text files.

## Inspiration

At the risk of citing an article where the author calls out a programming system citing the author's work as inspiration as terrible as inspiration,
Brett Victor's [Learnable Programming][] expresses some great ideas about the future of programming.

If you're not excited by the prospect of programming in English,
then at least check out some of [Brett Victor's work][]
or maybe [Toward a better programming][],
and get excited about the future of programming in general.

There's a project called [EVE][] that looks interesting.
I'll have to try [it](https://github.com/witheve/Eve) out and see what it's like.

Also, check out [Apparatus](http://aprt.us/)!

<!-- 
Could gather some quotes here and relate them to the project:

#### Quotes

> I think the next big step in terms of removing incidental complexity in code will come from automatically managing time. The implications of which would be tremendous for our ability to cleanly express intent.

([Toward a better programming][])

Ooplie will have an expressive and rather comprehensive time module.


> At its deepest, interface design means developing the fundamental primitives human beings think and create with... It is one of the hardest, most important and most fundamental problems humanity grapples with.


> "In summary, I think Parsey McParseface is a very nice milestone on a larger trend. The thing that's really significant is how quickly the speed and accuracy of natural language processing technologies is advancing. I think there are lots of ideas that didn't work yesterday, that are suddenly becoming very viable."
> "I think there are lots of ideas that didn't work yesterday, that are suddenly becoming very viable."


> To paraphrase Will Wright, your software doesn't just run on the computer -- it also runs in each of your users' heads. And to paraphrase Clay Shirky, social software also runs on the "hivemind" of the group as a whole. All together, that's an extraordinarily powerful hardware platform. Take advantage of it!


http://blog.wolfram.com/2010/11/16/programming-with-natural-language-is-actually-going-to-work/

https://multikulti.wordpress.com/2013/01/09/english-as-a-programming-language/

https://repository.cmu.edu/cgi/viewcontent.cgi?article=1165&context=hcii

https://stackoverflow.com/questions/3067377/what-programming-language-is-the-most-english-like

https://stackoverflow.com/questions/19262597/why-no-programming-in-english-what-is-the-difference-between-natural-languages?rq=1

-->

## Motivation

**TL;DR:** Someone's gotta do it.
(Accessibility, curiosity and want for a better world.)

I want see what it would be like to program in English.

I don't think this is the be-all and end-all of programming paradigms.
Unless a future of realtime cross-translated collaborative structured document editing is realized, it's probably not going to be better than a more syntactical programming language for international collaboration on software projects.
High expectations of lingual [disambiguation][] and common sense mean it ~~will~~ may never feel smart enough without machine learning and huge amounts of data.
That would make it harder to distribute programs, so [a compiler would][Programming with Natural Language Is Actually Going to Work] probably work better.
Although then you miss certain possiblities afforded by a dynamic interpreter / runtime.

But anyways, I think Ooplie might be a good tool for learning and getting into programming,
as an alternative to drag-and-drop-based systems,
and for automating lots of things that might be too trivial to automate considering you'd have to write a program for it.

It also could be great option for programming if you're blind, as long as it's designed with that in mind.
(hey, I just realized, that that rhymed...)
(seriously, if you know any blind programmers or blind people interested in programming, hit me up!
I might actively seek blind test users when this project is further along,
but interest in the project would probably motivate me to bring it further along.)

Also, I think radical ideas like this need to be explored.
Because even if Ooplie fails as a whole / as a project,
there still might be ideas in there that,
if people try programming in this new way,
might expand people's minds and end up being applied to other programming languages or systems.
It might raise expectations for clarity in code, expressitivity, richness of authoring environments, etc.
(expressitivity is related to... well, both of those other things.
it's really in the middle. perfect, I planned that.^([sarcasm needed]))


## Roadmap (somewhat muddled... by newer and older ideas colliding)

The first aim will be to get it usable as an imperative interpreter for simple shell scripts.
Scripts will be able to use a shebang comment like `#!/usr/bin/env ooplie`, or hopefully `#!/bin/english`. (`sh`, `bash`, `ksh`, `zsh`, `english`!)

Ooplie will need some better [natural language processing][].

Actually, I think Ooplie code should maybe be stored in a structure with more information,
or at least more concrete and explicit information, than is apparent in the plain language text,
or at least the plain language text that's input.
For instance, you shouldn't have to deal with escaping the contents of string literals.
<!-- (Or disable pieces of code without having to worry about other commented out pieces of code inside it, although this is solved in languages that allow nested comment blocks, and IDEs that let you comment/uncomment batches of lines with EOL comments) -->

It should understand more than it accepts.
In authoring you should be able to use autocomplete and such and express ideas freely and easily,
and then it should also help you form those ideas into clearer, more concrete representations, and more explicit functionality / algorithmic processes.
<!-- I realize it's an implicit problem with English that there are many ways to express the same thing,
but it's also a problem in normal programming languages.
There are callbacks, Promises, and async/await for doing async just in vanilla JavaScript, for instance.
And, maybe "problem" is too strong a word, or that's making it out to be simpler than it is,
because having different ways to express things is also a good thing.
It can enable different ways of thinking! That's a big part of the reason for this project!
I don't know, I'm rambling.
-->

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

It should encourage you to write robust, explicit code.
It might give you fields to fill out in response to commands:

"Draw a circle."
* Where? / Center point: [0, 0]
* How big? / Radius:     [1]
* What color? / Color:   [#000000]

It might highlight paths of execution that aren't handled like failure cases and else clauses.
Of course it's perfectly valid to do else-nothing,
but it *could* require or strongly encourage you to be explicit about it,
because sometimes you really should throw/raise/return an error/exception
(depending on the paradigm we go with),
and you might just not think of it.
It could unhandled paths with questions, like "What if this fails?" or "Else what?",
with easy default answers like
"just continue [below?]" / "do nothing" (no-op),
"this is an error" / "show a failure message" / whatever,
and "let me know if this happens" (ideally you could resume execution of the program after deciding what to do when the case pops up, optionally updating the program with some general handling of that scenario)

Errors should be considered UI.
Errors are already UI, just generally shitty, shoddy, untested UI.
Aside from having good, clear error messages:
* There should be good patterns for propagating error/exception cases up to the user,
with good contextual information in the message
(such as parameters passed to the things that might fail,
or *maybe* separate messages at each `raise`/`throw` level).
* Error messages should be able to contain references to objects/values for inspection,
similar to `console.log`.
That would include strings,
so you wouldn't have to either escape strings with `JSON.stringify()`
which makes them hard to read, in order to make it unambiguous,
or use quote characters around the string
that you think/hope are not going to be used in it (as often).

It could let you dig down into statements and expressions to see the underlying meaning and implementation, through your code, through libraries, and to the underlying JavaScript.
Similar features exist [in other IDEs][Peek Definition], but I can imagine it working more like a variant of [code folding][] where you fold layers of meaning and [abstraction][] rather than just blocks of code.
Perhaps like [this][IP levels of detail]?
(Except you wouldn't have to write that lower layer of code, `print the numbers 1 to 10` would just work :smile:)

It should also let you write code that isn't understood
and subsequently define/explain it, implementing it in detail.


It could automatically search for modules related to phrases it doesn't understand.
Maybe not *totally* automatically as it could be a privacy issue sending code to some server,
but maybe at the click of a button when it gives an "I don't understand" type error.
That would be good.
(And if the search DB was mirrored locally that could eliminate the privacy issue,
but it might take up a decent chunk of space,
so there could be three options for this, auto (not private), manual (not private), and local db (private).)

It should try to show you what's going on with the program as much as possible.

It could have dynamic underlines on timers like `Every N seconds` / `After N seconds`,
and maybe underlines to any line of code being executed.
That would be optional, though, as it could obviously be distracting.
Also I'm not sure how it would work with asynchronous code being run multiple times.

![Execution underlines](./images/execution-underlines.gif)

([Execution underlines CSS animation on jsfiddle](https://jsfiddle.net/1j01/2f2ko6ke/))

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
(Like a notebook? I think I was thinking specifically about being able to extract commands entered into a console out and factor them into a program retroactively... but probably this would work like "notebook IDEs" - [Jupyter Notebook](https://jupyter.org/) for lots of languages including JS, [RunKit](https://runkit.com) for Node.js)

Syntax highlighting in other apps would require a custom, dynamic engine using the parser
(which would be a problem because most things probably only support regular expression based highlighting),
unless the plain text file format includes lots of markup needed to identify semantics.
It would probably also need to be able to hide things, hide the markup unless it's somehow kept terse like markdown.
I don't know how that might work, but it would presumably/probably/generally be a subpar experience anyways...
However, the entire IDE could be made reusable as a component,
and could be included as a plugin in web-based code editors like [Atom][] and [Code][].


## Develop Ooplie

[Fork the repository on GitHub][fork a repo], and
with [Node.js][] installed run `npm install` in the project directory.

Run `npm run dev` (and leave this running) to watch the source files and recompile when changes are made.
(In the future this could also run the tests after each recompile.)

Run `npm test` to run the tests.
You can also open [`test.html`](./test.html) (maybe with a [live-server][]) to test Ooplie in a browser,
but note that only a subset of the tests are run.
The File System module isn't tested in the browser, for instance.
(In the future it could use a mock FS.)

#### Before committing (unless it's a WIP commit)

If you've been running tests in a browser,
be sure to run the full suite of tests with `npm test` at least once before committing.

Run `npm run prepublish` to make sure `ooplie.js` is comiled.
It's included in the repository for [GitHub Pages][] usage.
(In the future this should be an automated step of the release process,
not a manual step before every commit.)

#### Project Structure

The Ooplie console app lives in [`console/`](./console/)
and has a separate [`package.json`](./console/package.json).
It runs as a desktop app with [NW.js][].
(Could use either [electron][] or [NW.js][] since it's not doing anything fancy.)

CoffeeScript is included in 2 different ways:
* `lib/coffeescript.js` is the CoffeeScript browser compiler, used in [`test.html`](./test.html).
* `coffeescript` is a dev dependency, used for building and for testing with `npm test`.

Mocha and Chai are similarly included in 2 different ways:
* via a CDN in [`test.html`](./test.html)
* as dev dependencies for `npm test`


[multi-paradigm]: https://en.wikipedia.org/wiki/Programming_paradigm "Programming paradigm - Wikipedia"
[imperative]: https://en.wikipedia.org/wiki/Imperative_programming "Imperative programming - Wikipedia"
[abstraction]: https://en.wikipedia.org/wiki/Abstraction_(computer_science) "Abstraction (computer science) - Wikipedia"
[code folding]: https://en.wikipedia.org/wiki/Code_folding "Code folding - Wikipedia"
[IP levels of detail]: https://en.wikipedia.org/wiki/Intentional_programming#Levels_of_detail "\"Levels of detail\" in Intentional programming - Wikipedia"
[natural language processing]: https://en.wikipedia.org/wiki/Natural_language_processing
[disambiguation]: https://en.wikipedia.org/wiki/Word-sense_disambiguation "Word-sense disambiguation - Wikipedia"
[Programming with Natural Language Is Actually Going to Work]: http://blog.wolfram.com/2010/11/16/programming-with-natural-language-is-actually-going-to-work/
[console]: https://1j01.github.io/ooplie/console/
[npm]: https://www.npmjs.com/
[live-server]: https://www.npmjs.com/package/live-server
[Node.js]: https://nodejs.org/
[NW.js]: https://nwjs.io/
[electron]: https://electronjs.org/
[fork a repo]: https://help.github.com/articles/fork-a-repo/
[clone a repo]: https://help.github.com/articles/cloning-a-repository/
[Light Table]: http://lighttable.com/
[Atom]: https://atom.io/
[Code]: https://code.visualstudio.com/
[Learnable Programming]: http://worrydream.com/LearnableProgramming/
[Brett Victor's work]: http://worrydream.com/
[Toward a better programming]: http://www.chris-granger.com/2014/03/27/toward-a-better-programming/
[EVE]: http://eve-lang.com/
[Peek Definition]: https://msdn.microsoft.com/en-us/library/dn160178.aspx
[GitHub Pages]: https://pages.github.com/
