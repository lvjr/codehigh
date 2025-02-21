
testfiledir = "./testfiles-xetex"
checkengines = {"xetex"}

-- l3build always passes "-no-pdf" option to xetex
function runtest_tasks(name, run)
  return "xdvipdfmx " .. name
end
