-- searches video on youtube, made by dustin.
-- uses the coro-http module from luvit
--[[ 

HOW TO USE:
require it with something like "local ytsearcher = require('ytsearcher').new(YOUTUBE_API_KEY as string)"
then search a video with it like "local searcher = ytsearcher:search('banana+phone')"
because this function is async, you will need to use a coroutine.
Now you can do something like this:

local ytsearcher = require('ytsearcher').new(YOUTUBE_API_KEY as string)
local search = coroutine.wrap(function()
    local video,response = ytsearcher:search('banana+phone')
    print(video.id) -- youtube video id
    print(video.title) -- video title
    print(video.thumbnail) -- thumbnail link
    print(video.author) -- author name
end)
search()

When there's an error, it will return nil (and as second argument the response if it cannot connect to the website).

]]

local http = require('coro-http')

local apiurl = "https://www.googleapis.com/youtube/v3/search?"

local function find(body,term)
    local begin, last = body:find(term)
    if last then
        local last2 = body:find('"', last+3)
        return body:sub(last+3,last2-1)
    else
        return ""
    end
end

local module = {}
module.__index = module

module.new = function (ytkey,regioncode)
    local classSelf = {}
    setmetatable(classSelf, module)
    classSelf.key = ytkey
    return classSelf
end

function module:search(searchparam,regioncode)
    local searchParams = {
        key = self.key,
        maxResults = 1,
        part = 'snippet',
        q = searchparam,
        regionCode = regioncode or "US",
        type = 'video'
    }
    local queryUrl = ""
    for param,info in pairs(searchParams) do
        queryUrl = queryUrl.."&"..param.."="..info
    end
    queryUrl = string.sub(queryUrl,2)
    local response,body = http.request("GET",apiurl..queryUrl)
    if not body then
        return nil,response
    end
    local from = body:find('"high":')
    if not from then
        return nil, "Cannot find thumbnail"
    end
    local videoinfo = {
        id = find(body,'"videoId":'),
        title = find(body,'"title":'),
        thumbnail = find(body,'"url":',from),
        author = find(body,'"channelTitle":')
    }
    return videoinfo
end

return module