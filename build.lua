
module = "codehigh"

-- will be moved from current folder to build/unpacked folder
sourcefiles = {"codehigh.sty", "codehigh.lua"}

-- will be moved from build/unpacked folder to build/test folder
installfiles = {"*.sty", "*.lua"}

checkengines = {"pdftex","luatex"}
checkruns = 2

lvtext = ".tex"

kpse.set_program_name ("kpsewhich")
if not release_date then
 dofile ( kpse.lookup ("l3build.lua"))
end
