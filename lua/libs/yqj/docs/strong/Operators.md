Strong adds a few handy operators to strings. These are listed below.

## Addition

Some people like to use `+` instead of `..` to concatenate strings, and that's what this operator is about.

**Example**

``` lua
"Hello " + target
"Foo" + "Bar" -- "FooBar"
```

## Subtraction

This operator allows you to take anything matching the specified pattern out of a string. This makes `s - p` the same as `s:gsub(p, '')`.

**Example**

``` lua
"com.novafusion.nothing.here" - "^%w%.%w%.?" -- "nothing.here"
"Aliens!!!!!!" - "!+$" -- "Aliens"
```

## Multiplication

This is the most useful in my opinion, it allows you to repeat a string a certain number of times. This makes `s * i` the same as `s:rep(i)`.

**Example**

``` lua
"Hello... " * 3 -- "Hello... Hello... Hello... "
("Boo " * 3) - " $" -- "Boo Boo Boo"
```

## Division

See the `split` method over at the [[function reference]]. Note that when using the division operator the `plain` option is always set to true.

## Modulo (Interpolation)

Does simple string interpolation by calling `string.format`. Works with a single value or a table of values.

``` lua
"Hello %s" % "World" -- "Hello World"
"%s for all, all for %d" % {"One", 1} -- "One for all, all for 1"
```