
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
    {2, "NewCommand", P"\\newcommand"},
    {3, "SetCommand", P"\\set" * alpha ^ 1},
    {4, "BeginEnd",   P"\\" * (P"begin" + P"end")},
    {5, "Section",    P"\\" * (P"part" + P"chapter" + P"section" + P"subsection")},
    {6, "Command",    P"\\" * alpha ^ 1},
    {7, "Brace",      S"{}"},
    {8, "MathMode",   P"$"},
    {9, "Comment",    P"%" * (P(1) - S"\r\n") ^ 0 * (S"\r\n" + -1)},
  }

language["latex/math"] =
  {
    {1, "LeftRight",   P"\\" * (P"left" + P"right")},
    {2, "Command",     P"\\" * alpha ^ 1},
    {3, "MathMode",    P"$"},
    {4, "Script",      S"_^"},
    {5, "Number",      digit ^ 1},
    {6, "Brace",       S"{}"},
    {7, "Braket",      S"[]"},
    {8, "Parenthesis", S"()"},
    {9, "Comment",     P"%" * (P(1) - S"\r\n") ^ 0 * (S"\r\n" + -1)},
  }

language["latex/table"] =
  {
    {1, "Newline",   P"\\\\"},
    {2, "Alignment", P"&" },
    {3, "BeginEnd",  P"\\" * (P"begin" + P"end")},
    {4, "Command",   P"\\" * alpha ^ 1},
    {5, "Brace",     S"{}"},
    {6, "Braket",    S"[]"},
    {9, "Comment",   P"%" * (P(1) - S"\r\n") ^ 0 * (S"\r\n" + -1)},
  }

language["latex/latex2"] =
  {
    {1, "Argument",   P"#" ^ 1 * digit},
    {2, "NewCommand", P"\\" * (P"" + S"egx") * P"def"},
    {3, "SetCommand", P"\\set" * alpha ^ 1},
    {4, "PrivateCmd", P"\\" * (alpha + P"@") ^ 0 * P"@" * (alpha + P"@") ^ 0},
    {5, "Command",    P"\\" * alpha ^ 1},
    {6, "Brace",      S"{}"},
    {7, "Braket",     S"[]"},
    {9, "Comment",    P"%" * (P(1) - S"\r\n") ^ 0 * (S"\r\n" + -1)},
  }

language["latex/latex3"] =
  {
    {1, "Argument",   P"#" ^ 1 * digit},
    {2, "NewCommand", P"\\cs_new" * (alpha + S"_:") ^ 1},
    {3, "SetCommand", P"\\" * alpha ^ 1 * P"_" * (P"" + P"g") * P"set" * (alpha + S"_:") ^ 1},
    {4, "PrivateCmd", P"\\" * S"cgl" * P"__" * (alpha + S"_:") ^ 1 },
    {5, "Command",    P"\\" * (alpha + S"@_:") ^ 1},
    {6, "Brace",      S"{}"},
    {7, "Braket",     S"[]"},
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

local function PrintCommand(name, content)
  tex.tprint(
    {"\\expandafter\\gdef\\csname " .. name .. "\\endcsname{"},
    {-2, content}, -- same as \tl_to_str:n function
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
