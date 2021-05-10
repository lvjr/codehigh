
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
    {1, "Newline",   "\\\\"},
    {2, "Alignment", "&" },
    {3, "Command",   "\\hline"},
  }

language["latex/table"] =
  {
    {1, "Newline",   "\\\\"},
    {2, "Alignment", "&" },
    {3, "BeginEnd",  P"\\" * (P"begin" + P"end")},
    {4, "Command",   P"\\" * alpha ^ 1},
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
  return b, e, s
end

local count = 0

local function PrintCode(style, code)
  count = count + 1
  local name = "l__codehigh_parse_code_" .. count .. "_tl"
  tex.tprint({"\\expandafter\\gdef\\csname " .. name .. "\\endcsname{"}, {-2, code}, {"}"})
  local name = "l__codehigh_parse_style_" .. count .. "_tl"
  tex.tprint({"\\expandafter\\gdef\\csname " .. name .. "\\endcsname{"}, {-2, style}, {"}"})
end

function ParseCode(lang, code)
  count = 0
  while code ~= "" do
    local b, e, s = FindMatch(lang, code)
    --texio.write_nl(b)
    --texio.write_nl(e)
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
