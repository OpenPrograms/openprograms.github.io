--[[
	a HTML/CSS generator, designed to make updating the site easier
--]]
os.execute("cd "..(... or ""))
local err,https=pcall(require,"ssl.https")
local arg=...
if not err then
	print("you need to install luasec")
	print("install using luarocks")
	print("or http://love2d.org/forums/viewtopic.php?f=5&t=76728")
	print(https)
	os.exit()
end

local res,err=xpcall(function()
	local file=assert(io.open((arg or "").."repos.cfg","r"))
	local repodat=setfenv(assert(loadstring("return "..file:read("*a"))),{})()
	file:close()
	local repos={}
	for name,data in pairs(repodat) do
		local out={
			name,(data.repo or "none")
		}
		for k,v in pairs(data.programs or {}) do
			table.insert(out,{
				k,v.repo,v.desc
			})
		end
		table.insert(repos,out)
	end

	table.sort(repos,function(a,b)
		return a[1]:lower()<b[1]:lower()
	end)
	-- crappy parsing
	local function parse(yaml)
		local out={}
		for line in yaml:gmatch("[^\r\n]+") do
			if not line:match("^#") then
				local t,m=line:match("^(%s*)(.*)")
				t=t:gsub("  ","\t")
				if #t==0 and #m>0 then
					table.insert(out,{m:match("(.+):")})
				elseif #t==1 then
					if m:match(":$") then
						table.insert(out[#out],{m:match("(.+):")})
					else
						table.insert(out[#out],m)
					end
				elseif #t==2 then
					local t=out[#out]
					table.insert(t[#t],m)
				end
			end
		end
		return out
	end

	local function get(url)
		local res,code=https.request(url)
		if code==200 then
			return res
		end
	end

	for l1=1,#repos do
		local prog=repos[l1]
		if prog[2]~="none" then
			local data=get("https://raw.githubusercontent.com/"..prog[2].."/master/programs.cfg")
			if data then
				data,err=loadstring("return "..data)
				if not data then
					print("Error in "..prog[2])
					error(err)
				end
				data=setfenv(data,{})()
				for name,dat in pairs(data) do
					if dat.repo then
						table.insert(prog,{
							name,
							prog[2].."/"..dat.repo,
							dat.description,
						})
					else
						table.insert(prog,{
							name,
							nil,
							dat.description,
						})
					end
				end
			else
				print("WARNING: "..prog[2].." doesnt have a programs.cfg")
				local data=get("https://raw.githubusercontent.com/"..prog[2].."/master/programs.yaml")
				if data then
					repos[l1]=parse(data)
					table.insert(repos[l1],1,prog[2])
					table.insert(repos[l1],1,prog[1])
				else
					print("WARNING: "..prog[2].." doesnt have a programs.yaml and cant be listed")
				end
			end
		end
	end
	
	local url_override_because_vexatos={
		["immibis-compress"]="/tree/master/immibis-compress",
		ipack="/blob/master/immibis-compress/ipack.lua",
		dnsd="/blob/master/dns-server.lua",
		midi="/blob/master/midi.lua",
		geo2holo="/blob/master/midi.lua",
		libnoise="/blob/master/noise.lua",
		["holo-demos"]="/",
	}

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
.bvc { left: -10px }
.bevel, .content { border-width: 10px }
.bevel, .content { border-color: #F0F0F0; border-style:solid; }

.bvc {
	margin: 15 15 15 15;
	position: relative;	`   margin-bottom: 0px;
}

.bvc .tr, .bvc .tl, .bvc .br, .bvc .bl { height: 0px; width: 100%; }
.bvc .tr, .bvc .tl { border-top: 0; }
.bvc .br, .bvc .bl { border-bottom: 0; }
.bvc .tr, .bvc .br { border-right-color: transparent; }
.bvc .tl, .bvc .bl { border-left-color: transparent; }
.no_bevel { height: 0px; width: 100%; border-bottom: 0; }

.content {
	width: 100%;
	border-top: 0;
	border-bottom: 0;
	color:#101010;
	background-color:#F0F0F0;
}

.programs {
	color:#101010;
	background-color:#F0F0F0;
	border-radius:5px;
	padding:10px;
}
.title {
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
		<center><a href="https://github.com/OpenPrograms"><img src="logo.png"></a></center>
]]
	print("\ngenerating page\n")
	for _,dat in pairs(repos) do
		local name=dat[1]
		print("repo "..tostring(name))
		if dat[2]~="none" then
			dat[2]="https://github.com/"..dat[2]
			html=html.."\t\t<div class=\"bvc\"><div class=\"bevel tl tr\"></div><div class=\"content\"><a href=\""..dat[2].."\"><div class=\"title\">"..name.."</div></a>"
		else
			dat[2]="https://github.com/"
			html=html.."\t\t<div class=\"bvc\"><div class=\"bevel tl tr\"></div><div class=\"content\"><div class=\"title\">"..name.."</div>"
		end
		html=html.."\n\t\t<table>\n"
		for ind=3,#dat do
			local pdat=dat[ind]
			if type(pdat)=="table" then
				print("\tprogram "..tostring(pdat[1]))
				local url=pdat[2] or url_override_because_vexatos[pdat[1]]
				if url then
					if url:sub(1,1)=="/" then
						url=dat[2]..url
					else
						url="https://github.com/"..url
					end
					html=html.."\t\t\t<tr><td><a href=\""..url.."\">"..pdat[1].."</a></td><td>: "..pdat[3].."</td></tr>\n"
				else
					print("\t\tWARNING: "..pdat[1].." doesnt have a url!")
					html=html.."\t\t\t<tr><td><a style=\"color:#505050\">"..pdat[1].."</a></td><td>: "..pdat[3].."</td></tr>\n"
				end
			else
				html=html.."\t\t\t"..pdat.."\n"
			end
		end
		html=html.."\t\t</table></div><div class=\"bevel bl br\"></div></div>\n"
	end
	local date=os.date("!*t")
	local gen=date.month.."/"..date.day.." at "..date.hour..":"..("0"):rep(2-#tostring(date.min))..date.min
	html=html..[[
	</body>
</html>
	]]
	css=css
	local file=assert(io.open((arg or "").."index.html","w"))
	file:write(html)
	file:close()
	local file=assert(io.open((arg or "").."style.css","w"))
	file:write(css)
	file:close()
end,debug.traceback)
if not res then
	print(err)
end
