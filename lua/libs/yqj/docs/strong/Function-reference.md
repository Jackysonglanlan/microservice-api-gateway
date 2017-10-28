This is the reference for functions that are added to the Lua string library. Note, that like anything else in the string library, these functions can be accessed via the `string.method(s, ...)` syntax, or the much more convenient `s:method(...)` syntax. The method signatures provided will not include the first implied string argument.

## bytes(all)

**Description**  
Iterate through or get all the character codes of the string.

**Parameters**  
`all` (false): Whether or not to return all the character codes in a table.

**Returns**  
If `all` is true, then all the character codes of the string will be returned in a table. Otherwise the function will return the necessary iterator information for a `for` loop.

**Example**  
``` lua
for b in s:bytes() do print(b) end
```

## camelize(upper)

**Description**  
Transforms the string into camel-case.

**Parameters**  
`upper` (false): Whether or not to capitalise the first letter.

**Returns**  
The camel-case string.

**Example**  
``` lua
("hello_world"):camelize() -- "helloWorld"
("foo bar and_all_that"):camelize(true) -- "FooBarAndAllThat"
```

## capitalize()

**Description**  
Makes sure the first character is upper case, and the rest is lower case.

**Returns**  
The capitalised string.

**Example**  
``` lua
("hello world"):capitalize() -- "Hello world"
("HELLO WORLD"):capitalize() -- "Hello world"
```

## center(int, padstr)

**Description**  
Justifies on both the left and the right, which ends up centring the string. See the `ljust` function for more details. The main difference is that an even number of instances of `padstr` added to both the left and the right.

If `center` has to add an uneven number of characters, the function will give preference to left-flushing (adding to the right) over right-flushing.

**Parameters**  
`int`: The length you want the string to be.  
`padstr` (' '): The sub-string to pad the string by. Default is a space, as you can probably see.

**Returns**  
The centred string.

**Example**  
``` lua
("hello"):center(9) -- "  hello  "
("hello"):center(10, "*") -- "**hello***"
```

## chars()

**Description**  
Iterates through all the characters in the string.

**Returns**  
The necessary information for a `for` loop.

**Example**  
``` lua
s = ""
for c in ("Hello"):chars() do s = s .. c .. " " end
-- s == "H e l l o "
```

## chomp(pat)

**Description**  
Removes new lines or the pattern specified off from the end of the string.

**Parameters**  
`pat` (nil): A pattern to use in place of `"[\n\r]"`. Note that '+$' is automatically appended to the pattern.

**Returns**  
A new string.

## endsWith(suffix)

**Description**  
Checks if the string ends with `suffix`.

**Parameters**  
`suffix`: A sub-string to check with. Note this _isn't_ a pattern.

**Returns**  
True if the string ends with `suffix`, otherwise false.

## includes(pat, plain)

**Description**  
Checks if a pattern/sub-string is matched in the string.

**Parameters**  
`pat`: A pattern/sub-string to find in the string.  
`plain` (false): If true, `pat` will be treated as plain text, not a pattern.

**Returns**  
True if the string includes the pattern/sub-string specified, false otherwise.

## insert(index, other)

**Description**  
Inserts the sub-string `other` in the string at the index specified. This thing can handle positive, negative, and zero indicies. Here's some ASCII art to demonstrate the insertion positions for certain indicies:

    ---------------------
    | A | B | C | D | E |
    ---------------------
    1   2   3   4   5   6
    -6 -5  -4  -3  -2  -1

Zero is the same as concatenation.

**Parameters**  
`index`: The index to insert the sub-string `other` at.  
`other`: The sub-string to insert.

**Returns**  
A new string with `other` inserted.

## isLower()

**Description**  
Checks whether all the characters in the string are lower-case letters.

**Returns**  
True if all characters are a lower-case letter; false otherwise.

## isUpper()

**Description**  
Checks whether all the characters in the string are upper-case letters.

**Returns**  
True if all characters are an upper-case letter; false otherwise.

## lines(sep, all)

**Description**  
Either iterates through or returns a table of the string split by the pattern `sep`.

**Parameters**  
`sep`: A pattern to split the string by.
`all` (false): If true, the function will return the same result as running `s:split(sep)`.

**Returns**  
Either a table, or the necessary information to iterate.

**Example**  
``` lua
for s in ("Foo|Bar|Hello"):lines('|') do
  print(s)
end
```

## lines(all)

**Description**  
The same as `lines(sep, all)` but it uses the pattern `[\n\r]+` (newlines) instead of `sep`.

## ljust(int, padstr)

**Description**  
Justifies the text by flushing to the left. This means that the function will ensure that the string is of length `int`, by adding on as many instances of `padstr` as needed to the right.

If `s` is "hello" (length 5), then `s:ljust(10, "!")` would return "hello!!!!!" (length 10). However, if we call something like `s:ljust(10, "!!!")`, we'll still get "hello!!!!!", because the function will add them like this:

``` lua
"hello"
"hello" .. "!!!"
"hello!!!" .. "!!" -- making a sub-string for the last bit
```

Finally, if `int` is less than the length of the string, nothing will be done, and the string itself will be returned.

**Parameters**  
`int`: The length you want the string to be.  
`padstr` (' '): The sub-string to pad the string by. Default is a space, as you can probably see.

**Returns**  
The left-flushed string.

**Example**  
``` lua
("hello"):ljust(10) -- "hello     "
("boo"):ljust(5, "!") -- "boo!!"
```

## lstrip()

**Description**  
Strips whitespace (including newlines) off from the left-side of the string.

**Returns**  
The stripped string.

**Example**  
``` lua
("  hello "):lstrip() -- "hello "
("\r\n\n\t\t hello"):lstrip() -- "hello"
```

## next()

**Description**  
Advances every character in the string by one. It does this by incrementing their character codes. Be warned, at current it doesn't do any checks for going out of bounds.

**Returns**  
A new string.

**Example**  
``` lua
("a"):next() -- "b"
("abcdZ"):next() -- "bcdea"
("101"):next() -- "212"
```

## rjust(int, padstr)

**Description**  
Same as `ljust`, except it flushes to the right.

**Example**  
``` lua
("hello"):rjust(10) -- "     hello"
("boo"):rjust(5, "!") -- "!!boo"
```

## rstrip()

**Description**  
Strips whitespace (including newlines) off from the right-side of the string.

**Returns**  
The stripped string.

**Example**  
``` lua
(" hello  "):rstrip() -- " hello"
("hello\r\n\n\t\t "):rstrip() -- "hello"
```

## split(pat, plain)

**Description**  
Splits up a string by a sub-string, returning the resulting sub-strings in a table.

If you don't know how string splitting works, I'll give a little explanation. The function will look for a sub-string/pattern, in this case `pat`, in the string. Every time a match of `pat` is found, the match is removed, and the two remaining halves are split off from each other. This process then continues on the right side that was just split off. When no more occurrences are found, the function stops searching. So all the "halves" that were split off in the process are then (in the case of this function) returned in a table.

**Parameters**  
`pat`: A sub-string/pattern to look split the string by.  
`plain` (false): If true, `pat` will be treated as plain text, not a pattern. If you do need plain text, then it would be more convenient to use the division operator, see [[Operators]] for more information.

**Returns**  
A table of the sub-strings that were split off (may be empty).

**Example**  
``` lua
t = ("comma,separated,values"):split(',')
-- t == { "comma", "separated", "values" }
t = ("1. Write example. 2. Stop talking."):split('%d%.%s')
-- t == { "Write example.", "Stop talking" }
```

## squeeze(other)

**Description**  
If `other` is specified, the function makes sure that `other` occurs only once in succession. Otherwise it makes sure that _any_ character occurs only onces in succession.

**Parameters**  
`other` (nil): An optional pattern to use, instead of any character.

**Returns**  
A new string.

**Example**  
``` lua
("helloo"):squeeze() -- "helo"
("hello!!!"):squeeze("!") -- "hello!"
```

## startsWith(prefix)

**Description**  
Checks whether the string starts with the sub-string `prefix`.

**Parameters**  
`prefix`: The prefix to check for at the start of the string.

**Returns**  
True if the string begins with `prefix`, false otherwise.

## strip()

**Description**  
Same as using both `lstrip` and `rstrip` on a string. See those two methods.

## swapcase()

**Description**  
Swaps the case of every alphabetical character. If a character is lowercase, it will be turned into its uppercase partner, and vice versa.

**Returns**  
A new string with the cases swapped.

**Example**  
``` lua
("hElLO"):swapcase() -- "HeLlo"
("foo12E"):swapcase() -- "FOO12e"
```

## underscore()

**Description**  
The opposite of `camelize`. Converts the string into a lower-case, underscored string.

**Returns**  
The underscored string.

**Example**
``` lua
("fooBarAndCompany"):underscore() -- "foo_bar_and_company"
("foo bar AndNothing"):underscore() -- "foo_bar_and_nothing"
```