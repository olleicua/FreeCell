Update
===
Hot Cocoa Lisp doesn't work with modern nodejs unfortunately but I missed this game so I re-implemented it in ruby

    $ git clone git@github.com:olleicua/FreeCell.git
    $ cd FreeCell
    $ ruby freecell.rb

(enter `help` or `?` for instructions)

Currently tested on:
- [KDE](https://kde.org/) [SteamDeck](https://www.steamdeck.com/en/)
- [Termux](https://termux.dev/en/) on an Android Pixel 3a

I plan to test it on:
- Mac OSX (I suspect the colors will need to work differently)

Legacy HCL stuff
===

A command line Implementation of FreeCell in [Hot Cocoa Lisp](https://github.com/olleicua/hcl).

Usage
===

    npm -g install hot-cocoa-lisp
    git clone git@github.com:olleicua/FreeCell.git
    cd FreeCell
    hcl -nu game.hcl

License
===

This project is licensed under the [MIT License](http://opensource.org/licenses/MIT).

Alias setup
===

Add the following line to your `.bashrc` or `.zshrc` file:

    alias free-cell="node ~/path/to/git/repo/game.js"
