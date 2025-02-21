
module = "codehigh"

-- will be moved from current folder to build/unpacked folder
sourcefiles = {"codehigh.sty", "codehigh.lua"}

-- will be moved from build/unpacked folder to build/test folder
installfiles = {"*.sty", "*.lua"}

-- all files that match checksuppfiles in the supportdir are moved to build/test folder
supportdir = "./testfiles"
checksuppfiles  = {"regression-test.cfg"}

-- we need to check test files with different regression-test.cfg files
checkconfigs = {"build", "config-pdftex", "config-xetex"}

checkengines = {"luatex"}
--checkruns = 2

lvtext = ".tex"
tlgext = ".nlog"
