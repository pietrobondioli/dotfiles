---@class utils.inject
local M = {}

-- Function to wrap a function with another function that can modify its arguments
-- The wrapper function is called with the same arguments as the original function
-- If the wrapper function returns false, the original function is not called
-- Otherwise, the original function is called with the same arguments and its result is returned
---@generic A: any
---@generic B: any
---@generic C: any
---@generic F: function
---@param fn F|fun(a:A, b:B, c:C)
---@param wrapper fun(a:A, b:B, c:C): boolean?
---@return F
function M.args(fn, wrapper)
    return function(...)
        if wrapper(...) == false then return end
        return fn(...)
    end
end

-- Function to get the value of an upvalue of a function
-- An upvalue is a variable from an outer scope that is used in a function
-- This function iterates over all upvalues of the given function until it finds one with the given name
-- If it finds an upvalue with the given name, it returns its value
-- If it doesn't find an upvalue with the given name, it returns nil
function M.get_upvalue(func, name)
    local i = 1
    while true do
        local n, v = debug.getupvalue(func, i)
        if not n then break end
        if n == name then return v end
        i = i + 1
    end
end

return M
