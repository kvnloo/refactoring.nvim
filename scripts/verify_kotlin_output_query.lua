-- Regression for ThePrimeagen/refactoring.nvim#552 reviewer feedback:
-- both top-level and class-body output-function query patterns must match
-- every declaration, not just the first sibling in either container.
-- Run: nvim --headless --clean -u scripts/minimal_init.lua -l scripts/verify_kotlin_output_query.lua
local path = "tests/files/kotlin_output_query_multiple_functions.kt"
vim.opt.runtimepath:prepend(vim.fn.getcwd())
local bufnr = vim.fn.bufadd(vim.fn.fnamemodify(path, ":p"))
vim.fn.bufload(bufnr)
assert(vim.api.nvim_buf_is_loaded(bufnr))
local parser = vim.treesitter.get_parser(bufnr, "kotlin")
local root = assert(parser:parse()[1]):root()
local query = assert(vim.treesitter.query.get("kotlin", "refactor_output_function"))
local capture_id
for id, capture in ipairs(query.captures) do
    if capture == "output_function" then
        capture_id = id
        break
    end
end
assert(capture_id, "Kotlin output-function query has no @output_function capture")

local counts = {}
for _, match in query:iter_matches(root, bufnr, 0, -1) do
    local nodes = match[capture_id] or {}
    -- Neovim's current iter_matches returns capture nodes as arrays.
    if type(nodes) ~= "table" then nodes = { nodes } end
    for _, node in ipairs(nodes) do
        local code = vim.treesitter.get_node_text(node, bufnr)
        local name = code:match("^%s*fun%s+([%w_]+)")
        assert(name, "Function declaration capture does not begin with fun: " .. code)
        counts[name] = (counts[name] or 0) + 1
    end
end

local expected = { "resetFirst", "resetSecond", "clear", "increment" }
for _, name in ipairs(expected) do
    assert(counts[name] == 1, ("query must capture %s once; got %s"):
        format(name, tostring(counts[name])))
    counts[name] = nil
end
assert(next(counts) == nil, "query unexpectedly captured extra declarations")
print("PASS: Kotlin output-function query matches all 4 declarations")
