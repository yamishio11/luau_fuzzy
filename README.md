# luau_fuzzy (fuzzy hashing in pure luau)

A pure luau implementation of fuzzy hashing, based on the spamsum (aka ssdeep) algorithm.
Heavily based on [ppdeep](https://github.com/elceef/ppdeep/) (basically 1:1) but works on strings instead of files / buffers (which means they wont output the same hash as ssdeep!!!!).

This probably has lots of issues and bugs, but it works for the most part.

Note: this uses roblox's bit32 library for most of the bitwise operations, most luau runtimes (like lune) support this, but if you are using a different luau runtime you may need to implement your own bitwise operations.

## Usage

```lua
local luau_fuzzy = require(path to luau_fuzzy)
local hash = luau_fuzzy("hello world")
print(hash)
```

## Credits

- [ppdeep](https://github.com/elceef/ppdeep/)
- [ssdeep](https://ssdeep-project.github.io/ssdeep/index.html)
