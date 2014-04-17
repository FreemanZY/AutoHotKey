-- ahk.lua
-- ==========
-- Part of SciTE4AutoHotkey
-- This file just implements AutoIndent and Abbreviations for AutoHotkey files
-- and some LUA functions for AutoHotkey scripting

-- Functions:
--	AutoIndent
--	Abbreviation expand
--	Indentation checker and fixer

-- ======================= --
-- Read abbreviations file --
-- ======================= --

local abbrevs = {}
local abbnum = 0

local f = io.open(props['SciteDefaultHome'] .. "\\ahk.abbrev.properties")
if f ~= nil then
	while true do
		local readline = f:read("*l")
		if readline == nil then
			break
		end
		abbnum = abbnum + 1
		abbrevs[abbnum] = readline
	end
	f:close()
end

-- =================================================================== --
-- OnChar event -- need to execute AutoIndent and expand abbreviations --
-- =================================================================== --

function OnChar(curChar)
	-- this script only works on AHK lexer
	-- check for new line
	if curChar == "\n" then
		-- then execute AutoIndent
		AutoIndent()
	end
	-- check for space
	if curChar == " " then
		-- then expand abbreviations
		Abbreviations()
	end
	return false
end

-- =================== --
-- AutoIndent function --
-- =================== --

-- this function implements AutoIndent for AutoHotkey

function AutoIndent()
	-- get info
	local prevPos = editor:LineFromPosition(editor.CurrentPos) - 1
	local prevLine = editor:GetLine(prevPos)
	local curPos = prevPos + 1
	local curLine = editor:GetLine(curPos)
	
	-- check for comment
	if string.find(prevLine, "^%s*;") ~= nil then
		return false
	end
	
	-- check for if is neccesary indent current line
	if ((string.find(prevLine, "^%s*{") ~= nil) or (string.find(prevLine, "^.*{") ~= nil)) then
		editor.CurrentPos = editor:PositionFromLine(curPos)
		editor:LineEnd()
		editor:Tab()
	end
	
	-- check for if is neccesary deindent previous line
	if (string.find(prevLine, "^%s*}") ~= nil) then
		editor.CurrentPos = editor:PositionFromLine(prevPos)
		-- deindent only if there are tabs
		if (string.find(prevLine, "%s-.*") ~= nil) then
			editor:Home()
			editor:BackTab()
			-- and deindent current line
			editor.CurrentPos = editor:PositionFromLine(curPos)
			editor:Home()
			editor:BackTab()
		end
	end
	
	-- go to current line
	editor.CurrentPos = editor:PositionFromLine(curPos)
	editor:LineEnd()
	
	return false
end

-- ====================== --
-- Abbreviations function --
-- ====================== --

-- this function implements an abbreviation system for AutoHotkey

function Abbreviations()
	-- get info
	local curLine = editor:GetLine(editor:LineFromPosition(editor.CurrentPos))
	local from = editor:WordStartPosition(editor.CurrentPos-2)
	local to = editor:WordEndPosition(editor.CurrentPos-2)
	local curword = editor:textrange(from, to)
	curword = string.sub(curword, 1, string.len(curword))
	-- proccess abbreviations table & expand abbreviation if is neccesary
	for i = 1, abbnum, 1 do
		local readline = abbrevs[i]
		local posi = string.find(readline, "=")
		local abbrev = ""
		local expand = ""
		if posi ~= nil then
			abbrev = string.sub(readline, 1, posi-1)
			expand = string.sub(readline, posi+1)
		end
		if abbrev ~= "" or expand ~= "" then
			-- check for word
			if curword == abbrev then
				-- expand abbreviation if is neccesary
				local found = string.find(curLine, "%s*" .. curword .. ".*")
				if found ~= nil then
					-- check for start
					if found == 1 then
						editor:SetSel(from, to)
						editor:ReplaceSel(expand .. ",")
						-- and go to end of line
						editor:LineEnd()
					end
				end
			end
		end
	end
	return false
end

-- ==================================== --
-- Indentation checker & fixer function --
-- ==================================== --

-- this function checks the indentation of the script and if neccesary fixes it

function IndentationChecker()
	local tabs = 0
	local lineIndent = 0
	local curLine = ""
--	local indent_size = props['indent.size.*.ahk']
--	local tab_size = props['tab.size.*.ahk']
--	local use_tabs = props['use.tabs.*.ahk']
	-- loop for all lines
	local i = 0
	while true do
		i = i + 1
		-- get current line
		curLine = editor:GetLine(i)
		if curLine == nil then
			break
		end
		-- check for comment
		if string.find(curLine, "^%s*;") == nil then
			-- go to line
			editor.CurrentPos = editor:PositionFromLine(i)
			editor:Home()
			-- get line indentation
			lineIndent = editor.LineIndentation[i]
			-- deindent line if neccesary
			if lineIndent ~= 0 then
				for j = 1, lineIndent, 1 do
					editor:BackTab()
				end
			end
			-- set indentation settings
--			props['indent.size.*.ahk'] = indent_size
--			props['tab.size.*.ahk'] = tab_size
--			props['use.tabs.*.ahk'] = use_tabs
			-- and indent line if neccesary
			if tabs ~= 0 then
				for j = 1, tabs, 1 do
					editor:Tab()
				end
			end
			-- and fix indentation
			-- indent "next" line if is neccesary
			if ((string.find(curLine, "^%s*{") ~= nil) or (string.find(curLine, "^.*{") ~= nil)) then
				tabs = tabs + 1
			end
			-- deindent current line if is neccesary
			if (string.find(curLine, "^%s*}") ~= nil) then
				editor:Home()
				if (string.find(curLine, "%s-.*") ~= nil) then
					tabs = tabs - 1
					editor:BackTab()
				end
			end
		end
		-- go to end of line
		editor:LineEnd()
	end
end