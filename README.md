# luvit-yt-searcher
Searches for a video on youtube using google's youtube api. (not for youtube-dl)

## How to install this dep?
You do need [Luvit](https://luvit.io/) of course.
You can either get this as zip, use git bash or install it with luvit `lit install dustin10weering/luvit-yt-searcher`

## So how do I use it?
1. First of all, you need a youtube api key. You can get one by following this tutioral: https://developers.google.com/youtube/v3/getting-started. To view your quota, you can view this page https://console.cloud.google.com/apis/.

2. require the module with `local ytsearcher = require('luvit-yt-searcher').new('YOUR_YOUTUBE_API_KEY')` and replace YOUR_YOUTUBE_API_KEY with your youtube api key.

3. search something with ytsearcher:search (for example: `ytsearcher:search('banana+phone')`) it will return the youtube video info with id and a response. If it can't find the video, video table will be nil and response may contain info about what happened. When searching you have to put + on spaces, so you can just use gsub for that.

## Small documentation

Both of them are functions.

* `ytsearcher.new(YT_API_KEY)` Returns ytsearcher module itself, but with the key info included.

* `ytsearcher:search(term,regioncode)` Returns `video-info-table` (table, can be nil if no results.) and `response` (string or nil). 

Note that response may be nil when there's no response.

Can __ONLY__ be run in a coroutine, this will yield till it has the results. 

The returned video-info-table will contain a video `id`, `title`, `thumbnail` (link), `author` (author name). 

Regioncode is optional such as "NL","DE" and the default is "US". May return `No results` as response (video table will be nil) when it has no results from the api.

