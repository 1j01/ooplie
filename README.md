
# Ooplie

Ooplie is a [multi-paradigm][] programing system where you write in English.

Currently there's [a nice little console][console],
most of the tokenizing part of a lexer (with some passing tests),
and [a million pending tests][tests].


### Inspiration

At the risk of citing an article where the author calls out a programming system citing the author's work as inspiration as terrible* as inspiration,
Brett Victor's [Learnable Programming][] expresses some great ideas about the future of programming.

*(Basically.) I've used KA's system, and the noun/verb functions from Processing particularly irk me.

If you're not excited by the prospect of programming in your native language,
then at least check out some of [Brett Victor's work](http://worrydream.com/),
or maybe [Toward a better programming][],
and get excited about the future of programming itself.

There's another project called [EVE](http://eve-lang.com/) that looks interesting.
I don't know what it's about particularly.
I'm gonna go follow some of these links and get back to you.


### Roadmap

The first aim will be to get it usable as an imperative interpreter for simple shell scripts.
Scripts will be able to use a shebang comment like `#!/bin/english` or `#!/usr/bin/env english`.

The next step will be more complex control flow and mathematics.

Ooplie should have a good module system.
You should be able to easily write wrappers for modules on [npm][] to give them lingual interfaces.
File system support and other things should be implemented this way.
How the interop should work is not entirely decided.
Translating modules into other languages should be possible.

There should be an IDE, because a plain "language" is not good enough.

* Integrated development environment
  * "Did you mean?" style error handling that can update your actual code
  * Dig down into commands to see the underlying meaning and implementation
    (through your code to libraries to underlying JavaScript)
  * [Light Table][]-like live inspection features
  * Automatic searching for modules related to code you type that isn't understood?
  * Blur the line between entering commands and writing a program (if that's a good thing)
  * Add a dynamic underline to "Every N seconds" / "After N seconds" representing the timer
  * Reusable syntax highlighting engine/module (because Ooplie code will be quite dynamic)
  * Reusable IDE component? i.e. for code editor plugins
  * Mathematical equation/expression editing


### Dev

With [Node.js][], run `npm i` to install.

Open [`test.html`][tests] (maybe with a [live-server][])
and/or run `npm test`


[multi-paradigm]: https://en.wikipedia.org/wiki/Programming_paradigm "Programming paradigm - Wikipedia"
[console]: http://1j01.github.io/ooplie/dooplie/
[tests]: ./test.html
[npm]: https://www.npmjs.com/
[live-server]: https://www.npmjs.com/package/live-server
[Node.js]: https://nodejs.org/
[Light Table]: http://lighttable.com/
[Learnable Programming]: http://worrydream.com/LearnableProgramming/
[Toward a better programming]: http://www.chris-granger.com/2014/03/27/toward-a-better-programming/
