-- Copyright (c) 2007-2011 Incremental IP Limited.

--[[
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--]]


-- io = require("io")
math = require("math")
-- string = require("string")
-- assert, ipairs, setmetatable, tostring = assert, ipairs, setmetatable, tostring
math_floor = math.floor

-- module(...)

class Heap

    new: (comparison) =>
        @comparison = comparison or (k1, k2) -> return k1 < k2


    -- next_key: =>
    --     assert(@[1], "The heap is empty")
    --     return @[1].key


    empty: =>
        return @[1] == nil


    insert: (v) =>
        assert(v, "You can't insert nil into a heap")

        cmp = @comparison

        -- float the new key up from the bottom of the heap
        child_index = #@ + 1
        while child_index > 1
            parent_index = math_floor(child_index / 2)
            parent_rec = @[parent_index]
            if cmp(v, parent_rec)
                @[child_index] = parent_rec
            else
                break

            child_index = parent_index

        @[child_index] = v


    pop: =>
        assert(@[1], "The heap is empty")

        cmp = @comparison

        -- pop the top of the heap
        result = @[1]
        @[1] = nil

        size = #self

        -- push the last element in the heap down from the top
        last = @[size]
        -- last_key = (last and last.key) or nil
        @[size] = nil
        size = size - 1

        parent_index = 1
        while parent_index * 2 <= size do
            child_index = parent_index * 2
            if child_index+1 <= size and cmp(@[child_index+1], @[child_index])
                child_index = child_index + 1

            child_rec = @[child_index]
            -- child_key = child_rec.key
            if cmp(last, child_rec)
                break
            else
                @[parent_index] = child_rec
                parent_index = child_index

        @[parent_index] = last
        return result


    ----
    -- checking
    check: =>
        cmp = @comparison
        size = #@
        i = 1
        while true
            return true  if i*2 > size
            return false if cmp(@[i*2].key, @[i].key)
            return true  if i*2+1 > size
            return false if cmp(@[i*2+1].key, @[i].key)
            i += 1


    ----
    -- pretty printing
    __tostring: (f, tostring_func) =>
        f = f or io.stdout
        tostring_func = tostring_func or tostring
        size = #@

        write_node = (lines, i, level, end_spaces) ->
            if size < 1 then return 0

            i = i or 1
            level = level or 1
            end_spaces = end_spaces or 0
            lines[level] = lines[level] or ""

            my_string = tostring_func(self[i].key)

            left_child_index = i * 2
            left_spaces, right_spaces = 0, 0
            if left_child_index <= size then
                left_spaces = write_node(lines, left_child_index, level+1, my_string\len())

            if left_child_index + 1 <= size then
                right_spaces = write_node(lines, left_child_index + 1, level+1, end_spaces)

            lines[level] = lines[level]..string.rep(' ', left_spaces)..my_string..string.rep(' ', right_spaces + end_spaces)
            return left_spaces + my_string\len() + right_spaces

        lines = {}
        write_node(lines)
        for _, l in ipairs(lines)
            f\write(l, '\n')
