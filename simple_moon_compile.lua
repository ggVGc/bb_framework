#!/usr/bin/env lua

local parse = require "moonscript.parse"
local compile = require "moonscript.compile"
local util = require "moonscript.util"

local dump_tree = require"moonscript.dump".tree

printSource = false
printSourceMapping = false

-- convert .moon to .lua
function convert_path(path)
	return (path:gsub("%.moon$", ".lua"))
end

function log_msg(...)
  if not printSource then
    io.stderr:write(table.concat({...}, " ") .. "\n")
  end
end

function write_file(fname, code)
	if printSource then
		if code ~= "" then print(code) end
	else
		local out_f = io.open(fname, "w")
		if not out_f then
			return nil, "Failed to write output: "..fname
		end

		out_f:write(code.."\n")
		out_f:close()
	end
	return true
end

function compile_file(text, fname)
	local tree, err = parse.string(text)

	if not tree then
		return nil, err
	end

    local code, posmap_or_err, err_pos = compile.tree(tree)

    if not code then
        return nil, compile.format_error(posmap_or_err, err_pos, text)
    end

    if printSourceMapping then
        printSource = true
        print("Pos", "Lua", ">>", "Moon")
        print(util.debug_posmap(posmap_or_err, text, code))
        return ""
    end
    return code
end

function compile_and_write(from, to)
	local f = io.open(from)
	if not f then
		return nil, "Can't find file"
	end
	local text = f:read("*a")

	local code, err = compile_file(text, from)
	if not code then
		return nil, err
	end

	return write_file(to, code)
end

function append(a, b)
	for _, v in ipairs(b) do
		table.insert(a, v)
	end
end

function remove_dups(tbl)
	local hash = {}
	local final = {}

	for _, v in ipairs(tbl) do
        if v == '-X' then
          printSourceMapping = true
        elseif not hash[v] then
			table.insert(final, v)
			hash[v] = true
		end
	end

	return final
end


local inputs = arg

if #inputs == 0 then
	print("No files specified")
end

local target_dir = "./"

local files = inputs

files = remove_dups(files)

function get_sleep_func()
	local sleep
	if not pcall(function()
		require "socket"
		sleep = socket.sleep
	end) then
		-- This is set by moonc.c in windows binaries
		sleep = require("moonscript")._sleep
	end
	if not sleep then
		error("Missing sleep function; install LuaSocket")
	end
	return sleep
end


function plural(count, word)
	if count ~= 1 then
		word = word .. "s"
	end
	return table.concat({count, word}, " ")
end

for _, fname in ipairs(files) do
    local success, err = compile_and_write(fname, target_dir..convert_path(fname))
    if not success then
        io.stderr:write(fname .. "\t" .. (err or 'nil') .. "\n")
        os.exit(1)
    else
        log_msg("Built", fname)
    end
end

