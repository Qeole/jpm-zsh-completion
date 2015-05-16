# jpm Zsh completion

Zsh completion function for Mozilla's **jpm** add-on building tool

**Warning**: this work is experimental.
This is my first attempt at creating completion code for Zsh.
Feedback and/or fixes are most welcome.

**jpm** documentation is available [on MDN](https://developer.mozilla.org/en-US/Add-ons/SDK/Tools/jpm).

## Install

Copy this file to any directory among those listed in `$fpath` environment variable.

For instance:
```bash
$ git clone https://github.com/Qeole/jpm-zsh-completion.git
$ cd jpm-zsh-completion

$ cp _jpm $fpath[1]/
```
(You might need to add `sudo` before `cp`)
