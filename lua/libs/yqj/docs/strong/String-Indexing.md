Strong allows for two types of indexing. These are documented here.

## Brackets

Indexing with brackets (`[]`) allows you to get a single character of a string by provided its index. It's nearly the same as using `s:sub(i, i)` but it returns nil if the index is out of range.

**Example**  
``` lua
s = "Hello"
print(s[1]) -- "H"
print(s[3]) -- "l"
print(s[-1]) -- "o"
print(s[20]) -- nil
```

## Calling

For more powerful indexing, you can actually call the strings, as in `s(i, j)`. There are three things you can do with it:

* If you provide only `i`, and `i` is a number, it will be the same as `s[i]`.
* If you provide `i` and `j`, and `i` is a number, then it will be the same `s:sub(i, j)`, with the exception that it will return nil if `i` is out of range.
* Finally, if `i` is a string it will be the same as `s:match(i, j)`.

**Example**  
``` lua
s = "Hello"
print(s(2)) -- "e"
print(s(2, 4)) -- "ell"
print(s("ell")) -- "ell"
print(s("nothere")) -- nil
print(s("l", 4)) -- "l"
print(s("l", 5)) -- nil
```