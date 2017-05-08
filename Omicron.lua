--Deps and init
local discordia = require('discordia')
local fs = require('fs')
local client = discordia.Client()
local modPreFunctions = {}
local modFunctions = {}

--Read token and log in
local tokenFile = io.open("token.txt", "rb")
local tokenContent = tokenFile:read("*all")
tokenFile:close()
client:run(tokenContent)

-- Load all files in mods directory and assign each file/command into a function
local function loadOmicron()
	local modFiles = fs.readdirSync("mods")

	modPreFunctions = {}
	modFunctions = {}

	-- fucking fix this, really? has to be a better way than two tables
	for k, v in pairs(modFiles) do
		modPreFunctions[#modPreFunctions+1] = string.match(v, "(.-)%.lua")
	end
	
	for k, v in pairs(modPreFunctions) do
		what, modFunctions[v] = pcall(loadfile, "mods/" .. v ..".lua")
	end
end

-- On each new message...
client:on('messageCreate', function(message)
	if message.author == client.user then return end -- She will ignore herself
	
	local bang, cmd, arg

	-- Parse input for the bang (!), command, and argument (if a space exists after command)
	if string.match(message.content, '^([!/])(%S+) (.+)') then 
		bang, cmd, arg = string.match(message.content, '^([!/])(%S+) (.+)')
	elseif string.match(message.content, '^([!/])(%S+)') then
		bang, cmd = string.match(message.content, '^([!/])(%S+)')
	else
		return
	end

	-- Reload command, let's clean this up a bit later
	if cmd == 'reload' then
		if message.author.id == "204778195038240769" then
			loadOmicron()
			message.channel:sendMessage(string.format('`Cryogenic subsections A through J online…`'))
		else
			message.channel:sendMessage(string.format('`Denied.`'))
		end
	end

	-- Dynamic command functionality, tying to the functions we linked to files in loadOmicron()
	if cmd ~= "reload" then
		local status, err = pcall(modFunctions["about"], client, message)
	end

end)


client:on('ready', function()
	print('Logged in as '.. client.user.username)
	loadOmicron()
end)