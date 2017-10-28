require('yqj.strong')

local function testContents(t, ...)
  local args = {...}
  
  for i = 1, #args do
    if t[i] ~= args[i] then
      return false
    end
  end
  
  return true
end

context('String operators', function()
    
    test('Add', function()
        assert.equal('Foo' + 'Bar', 'FooBar')
      end)
    
    context('Subtract', function()
        test('It should remove instances of one or more characters', function()
            assert.equal('Hello World ... Blah' - ' ', 'HelloWorld...Blah')
            assert.equal('Hello World' - 'lo', 'Hel World')
            end)
        
        test('It should accept patterns', function()
            assert.equal('123 Hello' - '[%d%s]', 'Hello')
            end)
      end)
    
    test('Multiply', function()
        assert.equal('a' * 8, 'aaaaaaaa')
      end)
    
    context('Divide', function()
        test('It should act like split', function()
            local str = 'a,b,c,deee'
            assert.is_true(testContents(str / ',', unpack(str:split(','))))
            end)
        
        test('It should default to plain text splitting', function()
            assert.is_true(testContents('a.b.c' / '.', 'a', 'b', 'c'))
            end)
      end)
    
    context('Modulo', function()
        test('without string identifier', function()
            assert.equal('a' % 'b', 'a')
            end)
        test('with one string identifier', function()
            assert.equal('a%sz' % 'b', 'abz')
            end)
        test('with two string identifiers', function()
            assert.equal( 'a%s %sz' % {'b', 'c'}, 'ab cz')
            end)
      end)
end)

context('Indexing', function()
    local str = 'Hello!'
    
    context('s[i] type indexing', function()
        test("It should be able to index positive and negative indicies", function()
            assert.equal(str[1], 'H')
            assert.equal(str[4], 'l')
            assert.equal(str[ - 1], '!')
            end)
        
        test("It should return nil for out of range indicies", function()
            assert.is_nil(str[0])
            assert.is_nil(str[10])
            end)
      end)
    
    context('s(i, j) type indexing', function()
        test('It should be able to index a single character', function()
            assert.equal(str(1), 'H')
            assert.equal(str( - 1), '!')
            end)
        
        test('It should be able to index a range', function()
            assert.equal(str(1, 4), 'Hell')
            assert.equal(str( - 3, - 1), 'lo!')
            end)
        
        test('It should be able to index a sub-string', function()
            assert.equal(str('ll'), 'll')
            assert.is_nil(str('foo'))
            end)
        
        test("It should return nil for out of range indicies", function()
            assert.is_nil(str(0))
            assert.is_nil(str(10))
            assert.is_nil(str(10, - 2))
            end)
      end)
end)

context('Methods', function()
    context('bytes', function()
        local str = "hello"
        
        test('When calling normally it should provide an iterator', function()
            local t = {}
              for b in str:bytes() do table.insert(t, b) end
      assert.is_true(testContents(t, 104, 101, 108, 108, 111))
              end)
          
          test('When not calling with first parameter as true, it should provide a table of all bytes', function()
              assert.is_true(testContents(str:bytes(true), 104, 101, 108, 108, 111))
              end)
        end)
      
      context("camelize", function()
          test("It should lower the first letter by default", function()
              assert.equal(("hello"):camelize(), "hello")
              assert.equal(("Hello"):camelize(), "hello")
              end)
          
          test("It should work with underscores, space characters, and dashes", function()
              assert.equal(("hello_world_foo"):camelize(), "helloWorldFoo")
              assert.equal(("hello world\tfoo"):camelize(), "helloWorldFoo")
              assert.equal(("hello-world-foo"):camelize(), "helloWorldFoo")
              end)
          
          test("It should accept an option to capitalize the first letter", function()
              assert.equal(("hello_world"):camelize(true), "HelloWorld")
              end)
        end)
      
      test('capitalize', function()
          for _, v in pairs{'hello', 'HeLlO', 'hELLO', 'HELLo'} do
            assert.equal(v:capitalize(), 'Hello')
          end
        end)
      
      context("center", function()
          test("It should default to using spaces as the padding character", function()
              assert.equal(("hello"):center(7), " hello ")
              end)
          
          test("It should evenly justify strings when possible", function()
              assert.equal(("hello"):center(11), "   hello   ")
              end)
          
          test("It should prefer left-flushing to right-flushing", function()
              assert.equal(("hello"):center(12), "   hello    ")
              end)
        end)
      
      test('chars', function()
          local t = {}
            for c in ("hello"):chars() do table.insert(t, c) end
    assert.is_true(testContents(t, 'h', 'e', 'l', 'l', 'o'))
          end)
        
        context('chomp', function()
            test('When calling without a separator it should remove newlines', function()
                assert.equal(("hello\n\n"):chomp(), 'hello')
                assert.equal(("hello\r\n\r"):chomp(), 'hello')
                end)
            
            test('When calling with a separator it should remove the whatever specified', function()
                assert.equal(("hello...."):chomp('%.'), 'hello')
                end)
            
            test("It shouldnt remove the separator anywhere else than the end", function()
                assert.equal(("\n\nhello\n"):chomp(), "\n\nhello")
                assert.equal(("..hello.."):chomp('%.'), '..hello')
                end)
          end)
        
        context('lines', function()
            test('When calling with a separator it should use it to split the string', function()
                local t = {}
                
                for line in ("foo|bar|ha"):lines('|') do
                  table.insert(t, line)
                end
                
                assert.is_true(testContents(t, 'foo', 'bar', 'ha'))
                end)
            
            test('When calling without a separator it should go through each line', function()
                local t = {}
                
                for line in ("foo\nbar\r\nha"):lines() do
                  table.insert(t, line)
                end
                
                assert.is_true(testContents(t, 'foo', 'bar', 'ha'))
                end)
          end)
        
        test('endsWith', function()
            assert.is_true(("foobar!"):endsWith("ar!"))
            assert.is_false(("foobar!"):endsWith("Please return false"))
          end)
        
        test('includes', function()
            assert.is_true(("foobar!"):includes("oba"))
            assert.is_false(("foobar!"):includes("nada"))
          end)
        
        context('insert', function()
            test('Greater than zero indicies', function()
                assert.equal(("world"):insert(1, "hello "), "hello world")
                assert.equal(("far!"):insert(2, "oob"), "foobar!")
                end)
            
            test('Zero indicies should just concatenate', function()
                assert.equal(("hello"):insert(0, " world"), "hello world")
                end)
            
            test('Negative indicies', function()
                assert.equal(("hello"):insert( - 1, "ooo"), "helloooo")
                assert.equal(("hello"):insert( - 3, "ll"), "hellllo")
                end)
          end)
        
        context("isLower", function()
            test("Should return true for lower case letters", function()
                assert.is_true(("a"):isLower())
                end)
            
            test("Should return false for numbers and anything else", function()
                assert.is_false(("1"):isLower())
                assert.is_false(("!"):isLower())
                end)
            
            test("Should return false for upper case letters", function()
                assert.is_false(("A"):isLower())
                end)
            
            test("Should handle multi-character strings", function()
                assert.is_true(("aaaabb"):isLower())
                assert.is_false(("AAbb"):isLower())
                assert.is_false(("!$@#$A"):isLower())
                end)
            
            test("Should return false for empty strings", function()
                assert.is_false((""):isUpper())
                end)
          end)
        
        context("isUpper", function()
            test("Should return false for lower case letters", function()
                assert.is_false(("a"):isUpper())
                end)
            
            test("Should return false for numbers and anything else", function()
                assert.is_false(("1"):isUpper())
                assert.is_false(("!"):isUpper())
                end)
            
            test("Should return true for upper case letters", function()
                assert.is_true(("A"):isUpper())
                end)
            
            test("Should handle multi-character strings", function()
                assert.is_true(("AAAAAB"):isUpper())
                assert.is_false(("AAbb"):isUpper())
                assert.is_false(("!$@#$A"):isUpper())
                end)
            
            test("Should return false for empty strings", function()
                assert.is_false((""):isUpper())
                end)
          end)
        
        context('ljust', function()
            local str = "hello"
            
            test('When the length provided is less than or equal to the length of the string, ' .. 
              'it should return the string itself', function()
                assert.equal(str:ljust(#str - 1), str)
                assert.equal(str:ljust(#str), str)
                end)
            
            test('When the length provided is greater than the length of the string, it should pad it properly', function()
                local justified = str:ljust(#str + 10)
                assert.equal(justified, str .. (' ' * 10))
                assert.equal(#justified, #str + 10)
                end)
            
            test('It should pad with the string provided (if one is provided)', function()
                assert.equal(str:ljust(#str + 2, '!'), str .. '!!')
                end)
            
            test('It should be the correct length when the padding string is more than one character', function()
                local justified = str:ljust(#str + 10, '!!!')
                assert.equal(justified, str .. ('!' * 10))
                assert.equal(#justified, #str + 10)
                end)
          end)
        
        context('lstrip', function()
            test('It should strip spaces and tabs', function()
                assert.equal(('  \t hello'):lstrip(), 'hello')
                end)
            
            test('It should strip newlines', function()
                assert.equal(("\n\nhey"):lstrip(), 'hey')
                assert.equal(("\r\nhey"):lstrip(), 'hey')
                end)
            
            test('It should not strip to the right or the middle', function()
                assert.equal(('  hello world  '):lstrip(), 'hello world  ')
                end)
          end)
        
        context('next', function()
            test('When dealing with a single character, it should advance it', function()
                assert.equal(('a'):next(), 'b')
                assert.equal(('F'):next(), 'G')
                end)
            
            test('When dealing with multiple characters, it should advance them all', function()
                assert.equal(('aaa'):next(), 'bbb')
                assert.equal(('aBc'):next(), 'bCd')
                end)
          end)
        
        context('rjust', function()
            local str = "hello"
            
            test('When the length provided is less than or equal to the length of the string, ' .. 
              'it should return the string itself', function()
                assert.equal(str:rjust(#str - 1), str)
                assert.equal(str:rjust(#str), str)
                end)
            
            test('When the length provided is greater than the length of the string, it should pad it properly', function()
                local justified = str:rjust(#str + 10)
                assert.equal(justified, (' ' * 10) .. str)
                assert.equal(#justified, #str + 10)
                end)
            
            test('It should pad with the string provided (if one is provided)', function()
                assert.equal(str:rjust(#str + 2, '!'), '!!' .. str)
                end)
            
            test('It should be the correct length when the padding string is more than one character', function()
                local justified = str:rjust(#str + 10, '!!!')
                assert.equal(justified, ('!' * 10) .. str)
                assert.equal(#justified, #str + 10)
                end)
          end)
        
        context('rstrip', function()
            test('It should strip spaces and tabs', function()
                assert.equal(("hello   \t  "):rstrip(), 'hello')
                end)
            
            test('It should strip newlines', function()
                assert.equal(("hey\n\n"):rstrip(), 'hey')
                assert.equal(("hey\r\n"):rstrip(), 'hey')
                end)
            
            test('It should not strip to the left or the middle', function()
                assert.equal(('  hello world  '):rstrip(), '  hello world')
                end)
          end)
        
        context('split', function()
            test('It should split a string up properly', function()
                assert.is_true(testContents(('hello!world!foo!bar'):split('!'), 'hello', 'world', 'foo', 'bar'))
                end)
            
            test('It should accept patterns by default', function()
                assert.is_true(testContents(('hello1world2foo'):split('%d'), 'hello', 'world', 'foo'))
                end)
            
            test('It should accept an option to turn off patterns', function()
                assert.is_true(testContents(('com.nowhere.nada'):split('.', true), 'com', 'nowhere', 'nada'))
                end)
          end)
        
        context('squeeze', function()
            test('When a string is not specified, remove all duplicates', function()
                assert.equal(('helloo'):squeeze(), 'helo')
                assert.equal(('boo!!!'):squeeze(), 'bo!')
                end)
            
            test('When a string is specified, remove duplicates of it', function()
                assert.equal(('helloo'):squeeze('o'), 'hello')
                assert.equal(('boo!!!'):squeeze('!'), 'boo!')
                end)
          end)
        
        test('startsWith', function()
            assert.is_true(('001 hello world'):startsWith('001 '))
            assert.is_false(('blah'):startsWith('foo'))
          end)
        
        test('strip', function()
            local str = " \t\n  hello world  "
            assert.equal(str:strip(), str:lstrip():rstrip())
          end)
        
        test("swapcase", function()
            assert.equal(("HeLLoO"):swapcase(), "hEllOo")
            assert.equal(("goo"):swapcase(), "GOO")
            assert.equal(("GOO"):swapcase(), "goo")
          end)
        
        context("underscore", function()
            test("It should result in a lower-case string", function()
                assert.is_nil(("HelloWorld"):underscore():match('%u'))
                end)
            
            test("It should work with camel-case and space characters", function()
                assert.equal(("helloWorld"):underscore(), "hello_world")
                assert.equal(("HelloWorld"):underscore(), "hello_world")
                assert.equal(("hello world"):underscore(), "hello_world")
                end)
          end)
    end)
    
    
    
    
    
    
    