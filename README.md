
# Ooplie

Ooplie is a [multi-paradigm][] programming system where you write in English.

<!-- An NLP system? https://en.wikipedia.org/wiki/Natural_language_programming seems to have a somewhat narrow definition, and https://en.wikipedia.org/wiki/Natural_language_processing is rather broad -->

So far you can output text, eval JS, and eval Ooplie code from within Ooplie,
write expressions with worded operators, unicode operators, or ASCII operators, and
write trivial (read: useless because there are no variables yet) conditionals.

There's [a nice little console][console] where you can try it out so far,
and [a million pending tests][tests] (as well as some passing ones).

It runs in [Node.js][] and in the browser.

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
-->


## Roadmap

The first aim will be to get it usable as an imperative interpreter for simple shell scripts.
Scripts will be able to use a shebang comment like `#!/usr/bin/env ooplie`, or hopefully `#!/bin/english`. (`sh`, `bash`, `ksh`, `zsh`, `english`!)

Ooplie should have a good module system.
You should be able to easily write wrappers for modules on [npm][] to give them lingual interfaces.
File system support and other things should be implemented this way.
How the interop should work is not entirely decided.
(Translating modules into other spoken languages should be possible, theoretically.
There are some [opinions][Why are programming languages in English?] about programming in other languages, at least from people who can speak English,
but that's a significant selection bias and I feel like the attitude may be different when it comes to programming in natural language,
especially when you just want to tell the computer to do something,
as opposed to potentially collaborating internationally on a project.)

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

![Execution underlines](./execution-underlines.gif)

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

![Control flow indication mockup](./control-flow-indication-mockup.png)


The IDE could support visual mathematical equation/expression editing, and resources like images could be dragged and dropped and used directly in expressions.

It could blur the line between entering commands and writing a program (if that's a good thing).

The necessarily dynamic syntax highlighting engine could be made reusable if many things actually allow for dynamic stuff like that, but most things probably only support regular expressions.
However, the entire IDE could be made reusable as a component,
and could be included as a plugin in web-based code editors like [Atom][].


### Dev

With [Node.js][], run `npm i` to install.

Open [`test.html`][tests] (maybe with a [live-server][])
and/or run `npm test`


[multi-paradigm]: https://en.wikipedia.org/wiki/Programming_paradigm "Programming paradigm - Wikipedia"
[abstraction]: https://en.wikipedia.org/wiki/Abstraction_(computer_science) "Abstraction (computer science) - Wikipedia"
[code folding]: https://en.wikipedia.org/wiki/Code_folding "Code folding - Wikipedia"
[IP levels of detail]: https://en.wikipedia.org/wiki/Intentional_programming#Levels_of_detail "\"Levels of detail\" in Intentional programming - Wikipedia"
[Why are programming languages in English?]: https://www.reddit.com/r/explainlikeimfive/comments/1ugrcl/eli5_why_are_programming_languages_in_english/
[console]: http://1j01.github.io/ooplie/dooplie/
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
