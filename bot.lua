local discordia = require('./deps/discordia')
local ytsearcher = require('ytsearcher').new('AIzaSyAUY4qArWyqWqw4cPg8Zs_xoh-sv8GQj6Y')
local http = require('coro-http')
local waitmodule = require('timer')
local wait = require('timer').sleep
local client = discordia.Client()
local fs = require('fs')
-- variables owo--
local connection
local looping = false
local pingtimes = {}
local shard = "unknown"
local heartbeat = "unknown"
local downloadnum = 0
local letters = {"1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","ä","ë","ü","ö","`"}
local questions = {"NO.","you're gonna be eaten.","**e**","Could you explain more?","YES.","Cookies are good.","Rooster","Tommorow, yes.","At 18:00, no.",
"Lets kidnap someone","When you are ready.","Cookie?","Only if you can.","GOOD!","Gib more.","Totally.","None.","Never","<@371015059343933441>","The person above is drnuk","OwO",
"fuwwy yes yes","Nooooooooooooo\nooooooooooo\noooooo\noo\nooooooooooooooooooooooooooooo\noooooooooooooooooo\noo\nooooooooooooo\no\nooooooooooooooooo\nooooooooooo","lol imagine",
"Are you autistic?","What about you?","You're coming with me.","The person under me will answer your question shortly.","Go prepare, NOW","nuclear fallout","Do u know da wae?",
"You not","He say yes","Lets go in the bathroom","you 2 should go to bed","Idk lol","You tell me","I won't tell you","That's a secret","If I wasnt so hungry",
"Dustins elevators very good yes yes","ask again","69","What time is it?","<@350335672277794816> says yes.","Pati pati pati pati pati pati pati","PATI FOOD IS IN FRIDGE",
"you're in danger, NO!!!!"}
-- scrupt

client:on('shardReady', function(sharde)
	shard = sharde
end)

client:on('ready', function()
	print('Logged in as '.. client.user.username)
end)

client:on('heartbeat', function(sharde,latency)
	shard = sharde
	heartbeat = math.floor(latency+0.5)
end)

function string:remove(sep)
    return string.gsub(self,sep,"")
end

function wait(n) -- note: dont loop this a lot
  if n == nil then
      n = 0.1
  end
  os.execute([[powershell start-sleep -s ]]..tonumber(n))
end

function clonefile(file,chosedn,callback)
    local writable = fs.createWriteStream('musicshare'..chosedn..'.mp3')
    writable:on('open',function()
        local readablestream = fs.createReadStream(file,{chunkSize = 4096})
        readablestream:open(function()
            readablestream:read()
        end)
        readablestream:on('data',function(data)
            writable:write(data)
		end)
		readablestream:on('end',function()
			writable:close()
			readablestream:close()
			if callback then
			    callback()
			end
        end)
    end)
end

function downloadmusic(message,filename,command)
	local downloadurl
	local name 
	local volumeparam = message.content:find('volume:')
	local speedparam = message.content:find('speed:')
	if message.attachment then
		downloadurl = message.attachment.url
		name = message.attachment.filename
	else
		downloadurl = tostring(message.content:remove(command))
		if volumeparam or speedparam then
			local i = volumeparam or speedparam
			if speedparam and speedparam < i then
				i = speedparam
			end
			i = i-#command
			downloadurl = downloadurl:sub(1,i-1)
		end
		if downloadurl:sub(1,23) == 'https://www.roblox.com/' then
			downloadurl = downloadurl:sub(32,downloadurl:find("/",33)-1)
		end
		if downloadurl:sub(1,8) == 'https://' then
			local to = downloadurl:find(' ')
			if to then
				downloadurl = downloadurl:sub(1,to-1)
			end
			name = downloadurl
		elseif #downloadurl == 9 or #downloadurl == 10  and downloadurl:gsub("%d","") == "" then
			local response,body = http.request("GET","https://www.roblox.com/library/"..downloadurl)
			local begin,last = body:find('"MediaPlayerControls"')
			if last then
				begin = body:find('"https://',last)
				downloadurl = body:sub(begin+1,begin+54)
				print(downloadurl)
				name = body:sub(body:find("<title>")+7,body:find("- Roblox")-2)
			else
				message.channel:send("<@"..message.author.id..">, Not a valid roblox music id!")
				return
			end
		else
			message.channel:send("🔍 searching video...")
			downloadurl = downloadurl:gsub(" ","+")
			print(downloadurl)
			video, response = ytsearcher:search(downloadurl)
			if video then
				message.channel:send {
					embed = {
						title = "Found video: "..video.title,
						description = "by "..video.author.." ([video link](".."https://www.youtube.com/watch?v="..video.id.."))",
						thumbnail = {
							url = video.thumbnail
						},
						color = discordia.Color.fromRGB(0, 200, 0).value,
						timestamp = discordia.Date():toISO('T', 'Z')
					}
				}
				downloadurl = "https://www.youtube.com/watch?v="..video.id
				name = video.title
			else
				if response == "No results" then
					message.channel:send("<@"..message.author.id..">, No results!")
				else
				    message.channel:send("<@"..message.author.id..">, failed to search! This is due to either: No internet OR api quota exceeded. Response: "..tostring(response))
				end
				return
			end
		end
	end
	message.channel:send("<@"..message.author.id..">, now downloading `"..name.."`")
	print("---------------------------------------------------")
	if not message.attachment then
		if not downloadurl or #downloadurl < 6 then
			return
		end
		if downloadurl:find('youtu') then
			local start = downloadurl:find("&")
			if start then
				downloadurl = downloadurl:sub(1,start-1)
			end
			fs.unlinkSync('./music.aac')
			local result = os.execute([[youtube-dl --extract-audio --audio-format aac --output ]]..filename..[[ ]]..downloadurl)
			if not result then
				print(result)
				message.channel:send("<@"..message.author.id..">, please enter a valid youtube url! (failed to download)")
				return
			end
			downloadurl = nil
		end -- otherwise it will attempt to download it using the download thing
	end
	if downloadurl then
		local result = os.execute([[powershell -Command "Invoke-WebRequest ]]..downloadurl..[[ -OutFile ]]..filename..[["]])
		if not result then
			message.channel:send("<@"..message.author.id..">, please enter a valid download url!")
			return
		end
	end
	if string.reverse(name):sub(1,4) == "dim." then
		message.channel:send("<@"..message.author.id..">, converting mid file to ogg...")
		os.rename(filename,'music.mid')
		os.execute([[fluidsynther -nli -r 48000 -o synth.cpu-cores=8 -T oga -F music.ogg music.mid]])
		os.rename('music.ogg',filename)
		os.remove('music.mid')
		os.remove('music.ogg')
	end
	local extra = ""
	if volumeparam or speedparam then
		message.channel:send("<@"..message.author.id..">, converting file's speed/volume!")
	end
	if volumeparam then
		local begin2 = message.content:find(' ',volumeparam+7)
		print("begin: "..tostring(volumeparam))
		print("begin2: "..tostring(begin2))
		local num
		if begin2 then
			num = message.content:sub(volumeparam+7,begin2-1)
		else
			num = message.content:sub(volumeparam+7)
		end
		volumeparam = num:match("[%d%p]+")
		os.rename(filename,'music2.aac')
		local returned, processed
		local changevolume = coroutine.wrap(function()
			returned = os.execute([[ffmpeg -i music2.aac -filter:a "volume=]]..volumeparam..[[dB" ]]..filename..[[ -vcodec libx264]]) -- -c:v copy -c:a aac
			processed = true
		end)
		changevolume()
		local starttime = os.time()
		while not returned and not processed do
			wait(0.1)
			if os.difftime(os.time(),starttime) == 10 then
				os.execute([[taskkill /IM "ffmpeg.exe" /F]])
				break
			end
		end
		if not returned then
			message.channel:send("<@"..message.author.id..">, Can't convert volume! (try between 1-100)")
			return
		end
		os.remove('music2.aac')
		extra = extra.." with volume: "..tostring(volumeparam)
	end
	if speedparam then
		local begin2 = message.content:find(' ',speedparam+6)
		print("begin: "..tostring(speedparam))
		print("begin2: "..tostring(begin2))
		local num
		if begin2 then
			num = message.content:sub(speedparam+6,begin2-1)
		else
			num = message.content:sub(speedparam+6)
		end
		speedparam = tonumber(num:match("[%d%p]+"))
		extra = extra.." with speed: "..tostring(speedparam)
		if speedparam > 2 then
			local i = 1
			while speedparam > 2 do
				speedparam = speedparam^0.5
				i = i*i 
				if i == 1 then
					i = 2
				end
			end
			for d = 1,i do
				if d == 1 then
					loopstr = "atempo="..speedparam
				else
					 loopstr = loopstr..",atempo="..speedparam
				end
			end
		else
			loopstr = "atempo="..speedparam
		end
		os.rename(filename,'music2.aac')
		os.execute([[ffmpeg -i music2.aac -filter:a "]]..loopstr..[[" ]]..filename..[[ -vcodec libx264]]) -- -c:v copy -c:a aac
		os.remove('music2.aac')
	end
	return name, extra
end

local function joinuservc(message,guild,userid)
	local found = false
	for _,vc in pairs(guild.voiceChannels:toArray()) do
		for _,user in pairs(vc.connectedMembers) do
			if user.id == userid then
				local sucess, connect = pcall(function() return vc:join() end)
				found = true
				if sucess then
					connection = connect
					message.channel:send("<@"..message.author.id..">, joined your vc!")
				else
					message.channel:send("Error! "..tostring(connect))
				end
				return true
			end
		end
	end
	return false
end

local function messagereceived(message)
	if message.content == 'LOL!ping' then
		message.channel:send("Pong! I'm on shard `"..shard.."`! heartbeat: `"..tostring(heartbeat).." ms`, `"..math.floor(((message.createdAt-os.time())*1000)+0.5).." ms` to react (send at "..os.time().." )")
	end
	if message.content:sub(1,5) == 'Pong!' then
		local createdat = string.reverse(message.content)
		local found,last = createdat:find(" ta dnes%(")
		createdat = string.reverse(createdat:sub(3,found))
		message:setContent(message.content:sub(1,#message.content-(last+1)).." and `"..math.floor(((message.createdAt-createdat)*1000)+0.5).." ms` to send message")
	end
	if message.content:sub(1,8) == 'LOL!play' then
		if not connection or not connection.channel.connection then
			local worked = joinuservc(message,message.guild,message.author.id)
			if not worked then
		        message.channel:send("I need to be in a voice channel! <@"..message.author.id..">. Use LOL!joinvc <voicechannelid> or join a vc lol")
			    return
			end
		end
		local name,extra = downloadmusic(message,'music.aac',"LOL!play ")
		if not name then
			return
		end
		message.channel:send("<@"..message.author.id..">, now playing: `"..name.."`"..extra)
		-- you could use -i filename to check if it can be run
		connection:stopStream()
		local elapsed, reason = connection:playFFmpeg('./music.aac')
		if elapsed == 0 then
		    message.channel:send("<@"..message.author.id..">, Unsupported file format!")
		else
		    while looping do
			    elapsed, reason = connection:playFFmpeg('./music.aac')
			    print(reason)
		    end
		end
	end
	if message.content:sub(1,12) == 'LOL!download' then
		local chosedn = downloadnum
		downloadnum = downloadnum+1
		if message.content:sub(1,13) == 'LOL!download ' then
			local result = downloadmusic(message,'downloadedmusic'..chosedn..'.aac',"LOL!download ")
			if not result then
				return
			end
			os.execute([[ffmpeg -i "]]..'downloadedmusic'..chosedn..'.aac'..[[" "]]..'musicshare'..chosedn..'.mp3'..[[" -vcodec libx264]])
			os.remove('downloadedmusic'..chosedn..'.aac')
			message.channel:send{
				content = "<@"..message.author.id..">, got music:",
				file = 'musicshare'..chosedn..'.mp3'
			}
			os.remove('musicshare'..chosedn..'.mp3')
		else
			clonefile('./music.aac',chosedn,coroutine.wrap(function()
				message.channel:send{
					content = "<@"..message.author.id..">, currently playing this:",
					file = 'musicshare'..chosedn..'.mp3'
				}
			end))
			os.remove('musicshare'..chosedn..'.mp3')
		end
	end
	if message.content:sub(1,11) == 'LOL!joinvc ' then
	    local text = tostring(message.content:remove("LOL!joinvc "))
		local channel = client:getChannel(text)
		local sucess, connect = pcall(function() return channel:join() end)
		if sucess then
		    connection = connect
		    message.channel:send("<@"..message.author.id..">, joined the vc!")
		else
		    message.channel:send("Thats not a voice channel! <@"..message.author.id..">")
		end
	end
	if message.content == 'LOL!leave' then
	    if connection and connection.channel.connection then
		    print(connection)
			connection:close()
			message.channel:send("<@"..message.author.id..">, left the voice channel!")
		end
	end
	if message.content == 'LOL!loop' then
		if connection and connection.channel.connection then
			print(connection)
			looping = not looping
			if looping then
				message.channel:send("<@"..message.author.id..">, now looping ")
			else
				message.channel:send("<@"..message.author.id..">, stopped looping ")
			end
		end
	end
	if message.content == "LOL!help" then
		message.channel:send("Rolling random number...")
		local page = math.random(1,100)
		message.channel:send("Random number is "..page)
		local msg = "Available commands:\n"..
		"`LOL!ping` -- pings the bot\n"..
		"`LOL!help` -- this\n"..
		"`LOL!math [math command]` -- do maths without needing brain\n"..
		"`LOL!run [command]` -- runs commands but only dustin can do this\n"..
		"`LOL!say [message]` -- bot will say this\n"..
		"`LOL!ask [message]` -- ASK THE BOT SOMETHING. BOT HUMAN.\n"..
		"MUSIC COMMANDS\n"..
		"`LOL!play [search term/link/attachment/roblox music id or link] (volume: [volume]) (speed: [speed]) ` -- play musik (even supports mid(LOWERCASE) files!)\n"..
		"`LOL!joinvc [voicechannelid]` -- needed for the bot to join the voice channel\n"..
		"`LOL!leave` -- leaves vc\n"..
		"`LOL!loop` -- loops current song\n"..
		"`LOL!download [search term/link/attachment/roblox music id or link] (volume: [volume]) (speed: [speed])` -- download the current song or download the song in arguments.\n"..
		"--  --  --  --  --  Page "..page.."  --  --  --  --  --\n"..
		"[] is required for the command, () is optional. / means that you can chose 1."
		message.channel:send(msg)
	end
	if message.content:sub(1,9) == 'LOL!math ' then
	    local text = "return "..tostring(message.content:remove("LOL!math "))
		if text:find("os") then
		    message.channel:send("<@"..message.author.id.."> using 'os' wont work lol")
			return
		end
		local run = loadstring(text)
		local _, returned = pcall(run)
	    message.channel:send(tostring(returned))
	end
	--[[if message.content:find('LOL!volume ') then
	    local text = "return "..tostring(message.content:remove("LOL!volume "))
		text = tonumber(text)
		if text == nil then
		    message.channel:send("<@"..message.author.id..">, that isnt a number")
			return
		end
		
	end]]
	if message.content:sub(1,8) == 'LOL!ask ' then
		if message.content:reverse():sub(1,1) == '?' then
			local lowered = message.content:lower()
			local randomnum = 0
			for i,char in pairs(letters) do
				local e = lowered:gsub(char,"")
				randomnum = randomnum+i*#e
			end
			math.randomseed(randomnum)
			message.channel:send(questions[math.random(1,#questions)])
		else
			message.channel:send("thats not a question! smh")
		end
	end
	if message.content:sub(1,8) == 'LOL!run ' then
	    if message.author.id ~= "243085529598525441" then
		    message.channel:send("no u <@"..message.author.id..">")
			return
		end
		local text = tostring(message.content:remove("LOL!run "))
		if text == "restart" then
			message.channel:send("ok be right back")
			coroutine.wrap(function()
				os.execute([[luvit bot.lua]])
			end)()
			os.exit(0)
		elseif text == "stop" then
			message.channel:send("bye, dad :((((((((")
			os.exit(0)
		end
		local run = loadstring(text)
		_G.message = message
		_G.client = client
		_G.http = http
		local _, returned = pcall(run)
		_G.message = nil
		_G.client = nil
		_G.http = nil
	    message.channel:send("returned: `"..tostring(returned).."`")
	end
	if message.content:sub(1,8) == 'LOL!say ' then
	    local text = tostring(message.content:remove("LOL!say "))
	    message.channel:send(text)
	end
end

client:on('messageCreate',messagereceived)

client:run('Bot NTA1NzY1ODI2NDE5NDkwODQ2.Dy52GQ.7esqUQPM9mK1zHTv4bse9SwrMUg')