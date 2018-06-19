----
--
--

sm = setmetatable
infix = (f) ->
  mt = { __sub: (self, b) -> return f(self[1], b) }
  return sm({}, { __sub: (a, _) -> return sm({ a }, mt) })


merge_postfix = (a, b) ->
    return a unless b
    return b unless a

    for key, value in pairs b
        -- if b.amend == true

        if a[key] == nil
            a[key] = value
            continue
        if type(a[key]) == "table"
            if #a[key] == 0
                -- if value.amend == true
                    -- a[key] = amend(a[key], value)
                -- else
                a[key] = {a[key], value}
            elseif type(value) == "table"
                if #value == 0
                    table.insert(a[key], value)
                else
                    for val in *value
                        table.insert(a[key], val)
    return a


return infix(merge_postfix)
