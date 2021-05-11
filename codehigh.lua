
local P, R, S, V, C, Cb, Cc, Cf, Cg, Cp, Cs, Ct = lpeg.P, lpeg.R, lpeg.S, lpeg.V,
  lpeg.C, lpeg.Cb, lpeg.Cc, lpeg.Cf, lpeg.Cg, lpeg.Cp, lpeg.Cs, lpeg.Ct

lpeg.locale(lpeg)
local alnum, alpha, cntrl, digit, graph, lower, punct, space, upper, xdigit =
  lpeg.alnum, lpeg.alpha, lpeg.cntrl, lpeg.digit, lpeg.graph,
  lpeg.lower, lpeg.punct, lpeg.space, lpeg.upper, lpeg.xdigit

local function anywhere(p)
  return P{ Cp() * p * Cp() + 1 * V(1) }
end

local language = {}

language["latex"] =
  {
    {1, "Package",    P"\\" * (P"documentclass" + P"usepackage")},
    {6, "NewCommand", P"\\newcommand"},
    {3, "SetCommand", P"\\set" * alpha ^ 1},
    {4, "BeginEnd",   P"\\" * (P"begin" + P"end")},
    {5, "Section",    P"\\" * (P"part" + P"chapter" + P"section" + P"subsection")},
    {2, "Command",    P"\\" * alpha ^ 1},
    {7, "Brace",      S"{}"},
    {8, "MathMode",   P"$"},
    {9, "Comment",    P"%" * (P(1) - S"\r\n") ^ 0 * (S"\r\n" + -1)},
  }

language["latex/math"] =
  {
    {6, "LeftRight",   P"\\" * (P"left" + P"right")},
    {2, "Command",     P"\\" * alpha ^ 1},
    {8, "MathMode",    P"$"},
    {4, "Script",      S"_^"},
    {5, "Number",      digit ^ 1},
    {1, "Brace",       S"{}"},
    {7, "Bracket",     S"[]"},
    {3, "Parenthesis", S"()"},
    {9, "Comment",     P"%" * (P(1) - S"\r\n") ^ 0 * (S"\r\n" + -1)},
  }

language["latex/table"] =
  {
    {8, "Newline",   P"\\\\"},
    {1, "Alignment", P"&" },
    {6, "BeginEnd",  P"\\" * (P"begin" + P"end")},
    {4, "Command",   P"\\" * alpha ^ 1},
    {2, "Brace",     S"{}"},
    {3, "Bracket",   S"[]"},
    {9, "Comment",   P"%" * (P(1) - S"\r\n") ^ 0 * (S"\r\n" + -1)},
  }

language["latex/latex2"] =
  {
    {1, "Argument",   P"#" ^ 1 * digit},
    {6, "NewCommand", P"\\" * (P"" + S"egx") * P"def"},
    {5, "SetCommand", P"\\set" * alpha ^ 1},
    {4, "PrivateCmd", P"\\" * alpha ^ 0 * P"@" * (alpha + "@") ^ 0},
    {3, "Command",    P"\\" * alpha ^ 1},
    {2, "Brace",      S"{}"},
    {7, "Bracket",    S"[]"},
    {9, "Comment",    P"%" * (P(1) - S"\r\n") ^ 0 * (S"\r\n" + -1)},
  }

language["latex/latex3"] =
  {
    {1, "Argument",   P"#" ^ 1 * digit},
    {2, "PrivateVar", P"\\" * S"cgl" * P"__" * (alpha + S"_:@") ^ 1},
    {6, "PrivateFun", P"\\" * P"__" * (alpha + S"_:@") ^ 1},
    {4, "PublicVar",  P"\\" * S"cgl" * P"_" * (alpha + S"_:@") ^ 1},
    {7, "PublicFun",  P"\\" * (alpha + S"_:@") ^ 1},
    {5, "Brace",      S"{}"},
    {3, "Bracket",    S"[]"},
    {9, "Comment",    P"%" * (P(1) - S"\r\n") ^ 0 * (S"\r\n" + -1)},
  }

local function FindMatch(lang, code)
  syntax = language[lang]
  local b, e, s = -1, -1, ""
  for _, v in ipairs(syntax) do
    local p = v[3]
    mb, me = anywhere(p):match(code)
    if mb and (b == -1 or mb < b) then
      b = mb
      e = me
      s = v[1]
    end
  end
  --print(b, e, s)
  return b, e, s
end

---- We don't have "catcodetable@other" inside source2e
-- local cctab = luatexbase.registernumber("catcodetable@other")
---- Here is the catcodetable from luatexbase package
local cctab = luatexbase.catcodetables.CatcodeTableOther

local function PrintCommand(name, content)
  tex.tprint(
    {"\\expandafter\\gdef\\csname " .. name .. "\\endcsname{"},
    {cctab, content}, -- all characters including spaces have catcode 12
    {"}"}
  )
end

local count = 0

local function PrintCode(style, code)
  count = count + 1
  local name = "l__codehigh_parse_code_" .. count .. "_tl"
  PrintCommand(name, code)
  name = "l__codehigh_parse_style_" .. count .. "_tl"
  PrintCommand(name, style)
end

function ParseCode(lang, code)
  count = 0
  while code ~= "" do
    local b, e, s = FindMatch(lang, code)
    --texio.write_nl(code)
    --texio.write_nl("b = " .. b)
    --texio.write_nl("e = " .. e)
    --texio.write_nl("s = " .. s)
    if b == -1 then
      PrintCode(0, code)
      code = ""
    else
      PrintCode(0, code:sub(1, b-1))
      PrintCode(s, code:sub(b, e-1))
      code = code:sub(e)
    end
  end
  local name = "l__codehigh_parse_code_count_tl"
  tex.sprint("\\expandafter\\gdef\\csname " .. name .. "\\endcsname{" .. count .. "}")
end

return { FindMatch = FindMatch, PrintCode = PrintCode, ParseCode = ParseCode }
