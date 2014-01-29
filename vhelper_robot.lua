-- 
-- Copyright (C) 2013-2014, agile6v
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.
--

local http = require "resty.http"
local cjson = require "cjson"
local weather_conf = require "weather_conf"

function trim(s)
    return s:match("^%s-(.-)%s-$")
end

function hex2string(bytes)
    local hexstr = ""
    for i = 1, string.len(bytes) do
        local charcode = string.byte(bytes, i, i)
        hexstr = hexstr .. string.format("%02x", charcode)
    end
    return hexstr
end

function makeArticleInfo(title, descr, url, picUrl)
    
    return {
        {title = title, descr = descr, url = url, picUrl = picUrl}
    }
end

function sendHttpRequest(url)
    
    local httpc = http.new()
    
    local res, err = httpc:request_uri(url, {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
        }
    })

    if not res then
        ngx.log(ngx.ERR, err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    
    --ngx.log(ngx.DEBUG, res.body)
    
    return res.body
end

function makeArticlesBooksInfo(books)
    local articles = {}
    local article1 = {}
    local article2 = {}
    local article3 = {}
    
    article1["title"] = "<<" .. books[1]["title"] .. ">>  " .. books[1]["author"][1] .. "\n" ..
                        books[1]["publisher"] .. "  " .. books[1]["price"]
    article1["descr"] = ""
    article1["url"] = books[1]["alt"]
    article1["picUrl"] = books[1]["images"]["large"]
    
    article2["title"] = "<<" .. books[2]["title"] .. ">>  " .. books[2]["author"][1] .. "\n" ..
                        books[2]["publisher"] .. "  " .. books[2]["price"]
    article2["descr"] = ""
    article2["url"] = books[2]["alt"]
    article2["picUrl"] = books[2]["images"]["small"]
    
    article3["title"] = "<<" .. books[3]["title"] .. ">>  " .. books[3]["author"][1] .. "\n" ..
                        books[3]["publisher"] .. "  " .. books[3]["price"]
    article3["descr"] = ""
    article3["url"] = books[3]["alt"]
    article3["picUrl"] = books[3]["images"]["small"]

    articles[1] = article1
    articles[2] = article2
    articles[3] = article3

    return articles
end

function makeArticlesWeatherInfo(weather)
    local articles = {}
    local article1 = {}
    local article2 = {}
    local article3 = {}
    local article4 = {}
    local article5 = {}
    local article6 = {}
    local day1 = ""
    local day2 = ""
    local day3 = ""
    local weather_url = "http://mp.weixin.qq.com/mp/appmsg/show?__biz=MzA5MDI0MDcxMQ==&appmsgid=10000293&itemidx=1&sign=f97db66725bf19c824f68da100917579#wechat_redirect"

    if tonumber(weather.weatherinfo.fchh) >= 18 then
        day1 = "明天"
        day2 = "后天"
        day3 = "大后天"
    else
        day1 = "今天"
        day2 = "明天"
        day3 = "后天"
    end
    
    --  1
    article1["title"] = "『" .. weather.weatherinfo.city .. "』" .. "天气预报"
    article1["descr"] = ""
    article1["url"] = weather_url
    article1["picUrl"] = ""
    
    --  2
    article2["title"] = day1 .. " " .. weather.weatherinfo.temp1 .. " " 
                        .. weather.weatherinfo.weather1 .. " " .. weather.weatherinfo.wind1
    article2["descr"] = ""
    article2["url"] = weather_url
    article2["picUrl"] = "http://m.weather.com.cn/img/a" .. weather.weatherinfo.img1 .. ".gif"

    -- 3
    article3["title"] = day2 .. " " .. weather.weatherinfo.temp2 .. " " 
                        .. weather.weatherinfo.weather2 .. " " .. weather.weatherinfo.wind2
    article3["descr"] = ""
    article3["url"] = weather_url
    article3["picUrl"] = "http://m.weather.com.cn/img/a" .. weather.weatherinfo.img3 .. ".gif"
    
    -- 4
    article4["title"] = day3 .. " " .. weather.weatherinfo.temp3 .. " " 
                        .. weather.weatherinfo.weather3 .. " " .. weather.weatherinfo.wind3
    article4["descr"] = ""
    article4["url"] = weather_url
    article4["picUrl"] = "http://m.weather.com.cn/img/a" .. weather.weatherinfo.img5 .. ".gif"
    
    -- 5
    article5["title"] = "穿衣建议：" .. weather.weatherinfo.index_d .. "\n舒适指数："
                        .. weather.weatherinfo.index_co .. "\n旅游指数：" .. weather.weatherinfo.index_tr
    article5["descr"] = ""
    article5["url"] = weather_url
    article5["picUrl"] = ""

    -- 6
    article6["title"] = "\n如要查询其他城市的天气：\n\n发送：天气+城市名\n例如：天气北京"
    article6["descr"] = ""
    article6["url"] = weather_url
    article6["picUrl"] = ""

    articles[1] = article1
    articles[2] = article2
    articles[3] = article3
    articles[4] = article4
    articles[5] = article5
    articles[6] = article6

    return articles
end

function getMenuUsage()
    local description = "请回复数字或字母查看服务使用方法:\n" .. 
                        "1. 天气查询\n" .. 
                        "2. 人脸检测\n" .. 
                        "3. 智能听歌\n" .. 
                        "4. 智能查书\n" .. 
                        "5. 智能翻译\n" .. 
                        "v. 关于作者\n\n" .. 
                        "ps: 回复 [h|H]显示帮助菜单"
                        
    return makeArticleInfo("<V哥助手>", description, "", "")
end

function getWeatherUsage()
    local description = "输入:  天气+城市名称\n" .. 
                        "例如:  天气北京\n\n" .. 
                        "回复“[h|H]”显示主菜单"
                        
    return makeArticleInfo("天气预报使用指南:", description, "", "")
end

function getImageUsage()
    local description = "发送一张清晰的照片，就能帮你分析出种族、年龄、性别等信息.\n" .. 
                        "还等什么?\n\n" .. 
                        "回复“[h|H]”显示主菜单"
                             
    return makeArticleInfo("人脸检测使用指南:", description, "", "")
end

function getMusicUsage()
    local description = "输入:  歌曲+歌名\n" .. 
                        "例如:  歌曲单身情歌\n" .. 
                        "例如:  歌曲touch my hand\n\n" .. 
                        "回复“[h|H]”显示主菜单"
                             
    return makeArticleInfo("智能听歌操作指南:", description, "", "")
end

function getTranslateUsage()
    local description = "输入:  翻译+内容\n" .. 
                        "例如:  翻译我是美女\n" .. 
                        "例如:  翻译I am pretty.\n\n" .. 
                        "回复“[h|H]”显示主菜单"
                             
    return makeArticleInfo("智能翻译操作指南:", description, "", "")
end

function getSearchBooksUsage()
    local description = "输入:  查书+内容\n" .. 
                        "例如:  查书tomcat\n" .. 
                        "例如:  查书本色\n\n" .. 
                        "回复“[h|H]”显示主菜单"
                             
    return makeArticleInfo("智能查书操作指南:", description, "", "")
end

function getPersonalInfo()
    local description = "V哥, 80后, 擅长nginx定制开发. 业余时间喜欢写些小工具并托管在github, " .. 
                        "也希望能与兴趣相同的帅哥美女多多交流。这个微信公共账号的代码使用nginx + lua实现，源代码可以在我的github上找到 :)\n秋秋: 412845078\n" .. 
                        "微信: weiwei_009"
    local url = "https://github.com/agile6v";
    local PicUrl = "http://mmbiz.qpic.cn/mmbiz/govJ6sqSicNPQkClUt8ialprRIrozQuLP3UmdibxJYxeaJHZkz5KYxoswGHQJ85tKqWrerTUZC0euajK1ZCBagPfw/0";
                             
    return makeArticleInfo("关于作者:", description, url, PicUrl)
end

function findCityCodeByName(city)
    
    if weather_conf[city] then
        return weather_conf[city]
    elseif weather_conf[string.gsub(city, "市", "")] then
        return weather_conf[string.gsub(city, "市", "")]
    elseif weather_conf[city .. "市"] then
        return weather_conf[city .. "市"]
    elseif weather_conf[string.gsub(city, "县", "")] then
        return weather_conf[string.gsub(city, "县", "")]
    elseif weather_conf[city .. "县"] then
        return weather_conf[city .. "县"]
    elseif weather_conf[string.gsub(city, "区", "")] then
        return weather_conf[string.gsub(city, "区", "")]
    elseif weather_conf[city .. "区"] then
        return weather_conf[city .. "区"]
    elseif weather_conf[string.gsub(city, "旗", "")] then
        return weather_conf[string.gsub(city, "旗", "")]
    elseif weather_conf[city .. "旗"] then
        return weather_conf[city .. "旗"]
    elseif weather_conf[string.gsub(city, "省", "")] then
        return weather_conf[string.gsub(city, "省", "")]
    elseif weather_conf[city .. "省"] then
        return weather_conf[city .. "省"]
    else
        return nil
    end
end

function faceService(picUrl)
    
    local body = sendHttpRequest("http://apicn.faceplusplus.com/v2/detection/detect?url=" .. picUrl .. "&api_secret=Zu3v_4batx_RqOIDIVhxnELtGGbx_28I&api_key=614a7dbc8f0e0d187d00c1e52d2d275d")
    
    local json = cjson.decode(body)
    local face = json["face"]
    
    if not face then
        return nil
    end
    
    local content = "共检测到 " .. table.maxn(json["face"]) .. " 张人脸\n\n"
    local genderMap = {Male = "男性", Female = "女性"}
    local raceMap = {Asian = "黄色", White = "白色", Black = "黑色"}
    
    for i = 1, table.maxn(json["face"]) do
        
        local race = face[i]["attribute"]["race"]["value"]
        local gender = face[i]["attribute"]["gender"]["value"]
        local age = face[i]["attribute"]["age"]["value"]
        
        content = content .. raceMap[race] .. "人种, " .. genderMap[gender] .. ", " .. age .. "岁左右\n"
    end

    return content
end

function musicService(music)

    local json = ""
    
    local body = sendHttpRequest("http://mp3.baidu.com/dev/api/?tn=getinfo&ct=0&word=" .. ngx.escape_uri(music) .. "&ie=utf-8&format=json")
    
    json = cjson.decode(body)
    local song_id = json[1]["song_id"]
    
    if not song_id then
        return nil
    end
    
    body = sendHttpRequest("http://ting.baidu.com/data/music/links?songIds=" .. song_id)
    
    json = cjson.decode(body)
    local link = json["data"]["songList"][1]["songLink"]
    local artistName = json["data"]["songList"][1]["artistName"]
    
    return { title = music, 
             desc = artistName .. "\nbaidu mp3提供",
             url = link, 
             hurl = link }
end

function booksService(book)
    
    local body = sendHttpRequest("http://api.douban.com/v2/book/search?q=" .. book .. "&apikey=072d17a75ded49f5158746f619c7dddf&count=3")
    
    local json = cjson.decode(body)
    local books = json["books"]
    
    if not books then
        return nil
    end
    
    return makeArticlesBooksInfo(books)
end

function weatherService(ctiyCode)
    
    local body = sendHttpRequest("http://m.weather.com.cn/data/" .. ctiyCode .. ".html")
    
    local weather = cjson.decode(body)
    
    return makeArticlesWeatherInfo(weather)
end

function translateService(source)

    local body = sendHttpRequest("http://openapi.baidu.com/public/2.0/bmt/translate?client_id=HmEwOf2gXoIFDV3cMhpUQX0B&q=" .. source .. "&from=auto&to=auto")

    local data = cjson.decode(body)
    
    return data.trans_result[1].dst
end

function testMsgToXml(content, toUserName, fromUserName)
    local newXML = xml.new("xml")
    
    newXML:append("ToUserName")[1] = toUserName 
    newXML:append("FromUserName")[1] = fromUserName 
    newXML:append("CreateTime")[1] = ngx.localtime()
    newXML:append("MsgType")[1] = 'text'
    newXML:append("Content")[1] = content 
    newXML:append("FuncFlag")[1] = '0'
    return newXML;
end

function musicMsgToXml(content, toUserName, fromUserName)
    local newXML = xml.new("xml")
    local music = xml.new("Music")
    
    newXML:append("ToUserName")[1] = toUserName 
    newXML:append("FromUserName")[1] = fromUserName 
    newXML:append("CreateTime")[1] = ngx.localtime()
    newXML:append("MsgType")[1] = 'music'
    
    music:append("Title")[1] = content.title 
    music:append("Description")[1] = content.desc
    music:append("MusicUrl")[1] = content.url
    music:append("HQMusicUrl")[1] = content.hurl
    --music:append("ThumbMediaId")[1] = 0
    
    newXML:append(music)
    
    return newXML
end

function newsMsgToXml(news, toUserName, fromUserName)
    local newXML = xml.new("xml")
    local articles = xml.new("Articles")

    for k,v in ipairs(news) do
        local item = xml.new("item") 
        item:append("Title")[1] = v["title"]
        item:append("Description")[1] = v["descr"]
        item:append("PicUrl")[1] = v["picUrl"] 
        item:append("Url")[1] = v["url"]
        articles:append(item);
    end

    newXML:append("ToUserName")[1] = toUserName 
    newXML:append("FromUserName")[1] = fromUserName 
    newXML:append("CreateTime")[1] = ngx.localtime()
    newXML:append("MsgType")[1] = 'news'
    newXML:append("ArticleCount")[1] = #(news) 
    newXML:append(articles);
    
    return newXML;
end 

-- ################  main  ################
local method = ngx.req.get_method()
local token = "agile6v"

if method == "GET" or method == "POST" then
    
    local args = ngx.req.get_uri_args()
    
    local tbl = {token, args["timestamp"], args["nonce"]}
    table.sort(tbl)
    local result = ngx.sha1_bin(table.concat(tbl))
    
    if args["signature"] ~= hex2string(result) then
        ngx.exit(ngx.HTTP_FORBIDDEN)
    end
    
    if method == "GET" then
        ngx.say(args["echostr"])
        ngx.exit(ngx.HTTP_OK)
    end
else
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

local body = ngx.req.get_body_data()
local xmlfile = xml.eval(body)

local msgType = xmlfile:find("MsgType")[1]
local ToUserName = xmlfile:find("ToUserName")[1]
local FromUserName = xmlfile:find("FromUserName")[1]

local RESP_MESSAGE_TYPE_TEXT = "text"
local RESP_MESSAGE_TYPE_MUSIC = "music"
local RESP_MESSAGE_TYPE_NEWS = "news"

local respMsgType = RESP_MESSAGE_TYPE_NEWS
local respContent = "Sorry, service is currently unavaiable!"
local respMessage = ""


if msgType == "text" then
    
    local reqContent = xmlfile:find("Content")[1]
    
    reqContent = trim(reqContent)
    
    if reqContent == "h" or reqContent == "H" then
        respContent = getMenuUsage()
    elseif reqContent == "v" or reqContent == "V" then
        respContent = getPersonalInfo()
    elseif reqContent == "1" then
        respContent = getWeatherUsage()
    elseif reqContent == "2" then
        respContent = getImageUsage()
    elseif reqContent == "3" then
        respContent = getMusicUsage()
    elseif reqContent == "4" then
        respContent = getSearchBooksUsage()
    elseif reqContent == "5" then
        respContent = getTranslateUsage()
    else
        local keyword = string.sub(reqContent, 1, 6)
        local value = string.sub(reqContent, 7, -1)
        
        if keyword == "天气" then
            local cityCode = findCityCodeByName(value)
            if cityCode then
                respContent = weatherService(cityCode)
            else
                respMsgType = RESP_MESSAGE_TYPE_TEXT
                respContent = "Sorry, 没有找到<" .. value .. ">天气信息"
            end
        elseif keyword == "翻译" then
        
            local result = translateService(value)
            respContent = makeArticleInfo("V哥翻译 o(∩_∩)o :", value .. "\n\n~~~~~~~~~~\n\n" .. result, "", "")
            
        elseif keyword == "歌曲" then

            respContent = musicService(value)
            if not respContent then
                respMsgType = RESP_MESSAGE_TYPE_TEXT
                respContent = "Sorry, 没有找到歌曲<" .. value .. ">"
            else
                respMsgType = RESP_MESSAGE_TYPE_MUSIC
            end
            
        elseif keyword == "查书" then
            respContent = booksService(value)
        else
            respContent = getMenuUsage()
        end
    end
 
elseif msgType == "image" then
    
    local picUrl = xmlfile:find("PicUrl")[1]
    local result = faceService(picUrl)
    
    respContent = makeArticleInfo("人脸检测结果 :\n", result)

elseif msgType == "event" then

    local eventType = xmlfile:find("Event")[1]
    
    if eventType == "subscribe" then
        respContent = getMenuUsage()
    end
else
    respContent = getMenuUsage()
end

if respMsgType == RESP_MESSAGE_TYPE_NEWS then
    respMessage = newsMsgToXml(respContent, FromUserName, ToUserName)
elseif respMsgType == RESP_MESSAGE_TYPE_MUSIC then
    respMessage = musicMsgToXml(respContent, FromUserName, ToUserName)
else
    respMessage = testMsgToXml(respContent, FromUserName, ToUserName)
end

ngx.say(xml.str(respMessage))

