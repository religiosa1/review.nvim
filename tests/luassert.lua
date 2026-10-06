---@meta
--- Minimal luassert type stub so LuaLS knows about the busted `assert` object.
--- Only the matchers used in the specs are declared; add more as specs need them.

---@class luassert
---@overload fun(value: any, message?: any): any
assert = {}

---@param value any
---@param message? string
function assert.is_true(value, message) end

---@param value any
---@param message? string
function assert.is_false(value, message) end

---@param value any
---@param message? string
function assert.is_nil(value, message) end

---@param value any
---@param message? string
function assert.is_not_nil(value, message) end

---@param expected any
---@param actual any
---@param message? string
function assert.equals(expected, actual, message) end

---@param expected any
---@param actual any
---@param message? string
function assert.same(expected, actual, message) end
