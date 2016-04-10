
# Ooplie

Ooplie is a [multi-paradigm][] programing "language" where you write in English.

Currently there's only [a nice little console][console],
a most of the tokenizing part of a lexer (with some passing tests),
and a [million ~~failing~~ pending tests][tests].

### "Roadmap"

* Lots and lots of pending tests

* Lex

* Rewrite this "Roadmap"

* Research how people would write programs in English

* Try to implement something

* Usable for simple shell scripts (`#!/bin/english`!)

* More complex control flow

* Mathematics

* Module system (extract file system stuff and anything else to modules)

* Automatic searching for modules related to code you type that isn't understood?

* JavaScript interop (access node modules etc. and make Ooplie wrappers)

* Try to write a web app with this

* Internationalization (multiple language support)

* Integrated development environment
  * especially with "Did you mean?" style error handling that can update your actual code
  * but also hopefully with [Light Table][]-like live inspection features
  * and it could possibly blur the line between entering commands and writing a program
  * add a dynamic underline to "Every N seconds" / "After N seconds" representing the timer
  * and stuff like that

* Reusable syntax highlighting engine/module

* Reject a pull request for a performance optimization

(with lots of rewriting along the way; nothing necessarily in that order; nothing *likely* to be in that order)


### Dev

With [Node.js][], run `npm i` to install.

Open [`test.html`][./test.html]
and/or run `npm test -- --grep "tokenize|strings"`


[multi-paradigm]: https://en.wikipedia.org/wiki/Programming_paradigm "Programming paradigm - Wikipedia"
[console]: http://1j01.github.io/ooplie/dooplie/
[tests]: ./test.html
[Node.js]: https://nodejs.org/
[Light Table]: http://lighttable.com/
