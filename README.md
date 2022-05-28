# fennel-love2d-api

Fennel is a great language, and (in my opinion) more ergonomic than Lua. Among other things it supports interactive development via its REPL, which provides nice autocompletion, interactive execution, and documentation search. However, this functionality is lacking when working on a Love2d project, mainly because the Love2d API is provided as a global variable when in a Love2d execution environment.

This repo provides a file that contains a set of _mocks_ functions provided by Love2d. These mock functions don't really do anything but they do use the same names and documentation as the original Love2d ones. This allows you to import the api file and have all the nice REPL features except for interactive execution.

Example:

TODO add Gif


## How it works

This project is composed of a simple Fennel script that reads the Love2d API definition from [love2d-community/love-api](https://github.com/love2d-community/love-api), and then generates a Fennel file that contains all the mock functions, using the appropriate names and documentation.

When you require this file, it will first check if the file is being executed in a Love2d enviroment (this is done by checking if `_G.love` is not `nil`), and if it is then the actual `_G.love` reference is returned instead of the mocks. This has the effect that you can use the mocks during development (from the REPL) and the real Love2d functions will be used when running the actual game.


## How to use

Just grab the latest release from [Releases](https://github.com/tupini07/fennel-love2d-api/releases) and put it somewhere in your project. 

Once that's done just _require_ it where you need the Love2d api and that's it! See a very minimal example [here](example.fnl)

