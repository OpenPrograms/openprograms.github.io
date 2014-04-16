--[[
	a HTML/CSS generator, designed to make updating the site easier
--]]
local file=io.open("programs.yaml","r")
local yaml=file:read("*a")
file:close()
-- crappy parsing
yaml=yaml:gsub("^#[^\r\n]+","")
:gsub("\r?\n([^\r\n\t]+):\r?\n","\n{\"%1\",\n")
:gsub("\r?\n\t([^\r\n\t]+[^\r\n\t:])\r?\n","\n\t\"%1\",\n")
:gsub("\r?\n{","\n},\n{")
:gsub("\r?\n\t([^\r\n\t]+):\r?\n","\n\t{\"%1\",\n")
local n=1
while n>0 do
	yaml,n=yaml:gsub("\r?\n\t\t([^\r\n\t{\"][^\r\n\t]+)\r?\n","\n\t\t\"%1\",\n")
end
local programs=loadstring("return {"..yaml:gsub(",\r?\n}","\n\t}\n}"):gsub("(\r?\n\t\t([^\r\n\t]+),)\r?\n\t{","%1\n\t},\n\t{"):match("},(.+)").."}}}")()
local css=[[
body {
	background-color:#101010;
	color:#101010;
	font-family:Arial, Helvetica, sans-serif
}
a:link {text-decoration:none;}
a:visited {text-decoration:none;}
a:hover {text-decoration:none;}
a:active {text-decoration:none;}
a {
	font-weight:bold;
	color:#101010;
}
h2 {
	background-color:#F0F0F0;
	color:#101010;
}
#programs {
	color:#101010;
	background-color:#F0F0F0;
	border-radius:5px;
	padding:10px;
}
#title {
	font-weight:bold;
	text-align:center;
	font-size:130%;
	color:#101010;
	background-color:#E0E0E0;
	border-radius:5px;
	text-align:center;
	padding:5px;
}
h5 {
	color:#F0F0F0;
}
table {
	border:0px;
	padding:10px;
}
td {
	border:0px;
}
]]
local html=[[
<html>
	<head>
		<title>OpenPrograms</title>
		<link rel="stylesheet" type="text/css" href="style.css">
		<link rel="icon" type="image/ico" href="favicon.ico">
	</head>
	<body>
		<br><center><a href="https://github.com/OpenPrograms"><img src="logo.png"></a></center><br>
]]
for _,dat in pairs(programs) do
	local name=dat[1]
	if dat[2]~="none" then
		dat[2]="https://github.com"..dat[2]
		html=html.."\t\t<br><div id=\"programs\"><a href=\""..dat[2].."\"><div id=\"title\">"..name.."</div></a>"
	else
		html=html.."\t\t<br><div id=\"programs\"><div id=\"title\">"..name.."</div>"
	end
	html=html.."\n\t\t<table>\n"
	for ind=3,#dat do
		local pdat=dat[ind]
		if type(pdat)=="table" then
			local url=pdat[2]
			if url:sub(1,1)=="/" then
				url=dat[2]..url
			end
			html=html.."\t\t\t<tr><td><a href=\""..url.."\">"..pdat[1].."</a></td><td>: "..pdat[3].."</td></tr>\n"
		else
			html=html.."\t\t\t"..pdat.."\n"
		end
	end
	html=html.."\t\t</table></div>\n"
end
local date=os.date("!*t")
html=html..[[
		<a href=\"https://github.com/OpenPrograms/openprograms.github.io/blob/master/generate.lua\">
			<h5>Generated on ]]..date.month.."/"..date.day.." at "..date.hour..":"..("0"):rep(2-#tostring(date.min))..date.min..[[ UTC</h5>
		</a>
	</body>
</html>
]]
local file=assert(io.open("index.html","w"))
file:write(html)
file:close()
local file=assert(io.open("style.css","w"))
file:write(css)
file:close()
