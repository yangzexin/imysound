function versionCode()
    return "6";
end

function baseURLString()
    return "http://www.51voa.com";
end

function specialVOAURLString()
    --return "http://www.51voa.com/VOA_Special_English/";
    return "http://www.51voa.com/VOA_Standard_English/";
end

function linkSeparator()
    return "-*-*-";
end

function itemSeparator()
    return "-|-|-";
end

function analyseSingleLi(liHtml)
    liHtmlReversed = string.reverse(liHtml);
    local beginIndex1, endIndex1 = string.find(liHtmlReversed, "\"=ferh a<");
    titleAndLinkHtml = string.reverse(string.sub(liHtmlReversed, 1, beginIndex1 - 1));
    --print(titleAndLinkHtml);
    --titleAndLinkHtml = "<a href="/VOA_Special_English/isaac-newton-science-45565.html" target="_blank">
    --  On the Shoulders of Giants: Isaac Newton and Modern Science  (2012-5-23)</a>";
    
    local beginIndex2, endIndex2 = string.find(titleAndLinkHtml, "\"");
    local newsLink = baseURLString()..string.sub(titleAndLinkHtml, 1, beginIndex2 - 1);
    
    local beginIndex3, endIndex3 = string.find(titleAndLinkHtml, ">");
    local beginIndex4, endIndex4 = string.find(titleAndLinkHtml, "</");
    local newsTitle = string.sub(titleAndLinkHtml, endIndex3 + 1, beginIndex4 - 1);
    
    return newsTitle, newsLink;
end

function analyseNewsList(html)
	local beginIndex, endIndex = string.find(html, "<span id=\"blist\">");
	local beginIndex2, endIndex2 = string.find(html, "</span>", endIndex);
	html = string.sub(html, endIndex + 1, beginIndex2 - 1);

	endIndex2 = 0;
	resultStr = "";
	while true do
		beginIndex, endIndex = string.find(html, "<li>", endIndex2);
		if beginIndex == nil then
			break;
		end
		beginIndex2, endIndex2 = string.find(html, "</li>", endIndex);
		linkItemStr = string.sub(html, endIndex + 1, beginIndex2 - 1);
        
        local newsTitle, newsLink = analyseSingleLi(linkItemStr);
        --print(newsTitle..linkSeparator()..newsLink);
        
        resultStr = resultStr..newsLink..linkSeparator()..newsTitle..itemSeparator();
	end
	--print(resultStr);
--[[
	for i in pairs(resultList) do
		print(resultList[i]);
	end
--]]
	return resultStr;
end

function removeIMGTag(html)
    local tagName = "IMG";
    local removeContent = true;
	local tagBegin = "<"..tagName;
	local tagEnd = ">";

	local resultStr = html;
	local prefix = "";
	local suffix = "";
	local beginIndex = 0;
	local endIndex = 0;
	local beginIndex2 = 0;
	local endIndex2 = 0;
	
	while true do
		beginIndex, endIndex = string.find(resultStr, tagBegin);
		if beginIndex == nil then
			break;
		end
		if removeContent then
			beginIndex2, endIndex2 = string.find(resultStr, tagEnd, endIndex);
		else
			beginIndex2, endIndex2 = string.find(resultStr, ">", endIndex);
		end
		
		prefix = string.sub(resultStr, 0, beginIndex - 1);
		suffix = string.sub(resultStr, endIndex2 + 1, string.len(resultStr)); 
		resultStr = prefix..suffix;
	end
	resultStr = string.gsub(resultStr, tagEnd, "");
	return resultStr;
end

function removeTag(html, tagName, removeContent)
	local tagBegin = "<"..tagName;
	local tagEnd = "</"..tagName..">";

	local resultStr = html;
	local prefix = "";
	local suffix = "";
	local beginIndex = 0;
	local endIndex = 0;
	local beginIndex2 = 0;
	local endIndex2 = 0;
	
	while true do
		beginIndex, endIndex = string.find(resultStr, tagBegin);
		if beginIndex == nil then
			break;
		end
		if removeContent then
			beginIndex2, endIndex2 = string.find(resultStr, tagEnd, endIndex);
		else
			beginIndex2, endIndex2 = string.find(resultStr, ">", endIndex);
		end
		
		prefix = string.sub(resultStr, 0, beginIndex - 1);
		suffix = string.sub(resultStr, endIndex2 + 1, string.len(resultStr)); 
		resultStr = prefix..suffix;
	end
	resultStr = string.gsub(resultStr, tagEnd, "");
	return resultStr;
end

function fixedNewAnalyseNewsContent(htmlContent)
    --print(htmlContent);
    local beginIndex1, endIndex1 = string.find(htmlContent, "<div id=\"menubar\">");
    beginIndex1, endIndex1 = string.find(htmlContent, "<span class=", endIndex1);
    if beginIndex1 == nil then
        beginIndex1, endIndex1 = string.find(htmlContent, "<SPAN class=");
    end
    
    beginIndex1, endIndex1 = string.find(htmlContent, ">", beginIndex1);
    
    local beginIndex2, endIndex2 = string.find(htmlContent, "</div>", endIndex1);
    
    --print(htmlContent);

    local fixContent = string.sub(htmlContent, endIndex1 + 1, beginIndex2 - 1);
    fixContent = removeTag(fixContent, "DIV", true);
    fixContent = removeTag(fixContent, "SPAN", false);
    fixContent = removeTag(fixContent, "A", false);
    
    return fixContent;
end

function analyseNewsContent(html)
    --print(html);
	if string.len(html) == 0 then
		return wrapNewsContent("No content yet");
	end
    local fixContent = fixedNewAnalyseNewsContent(html);
    fixContent = wrapNewsContent(fixContent);
    --print(fixContent);
    return fixContent;
end

function wrapNewsContent(content)
	local html = "<html><head>";
	html = html.."<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">";
	html = html.."<meta name=\"viewport\" content=\"width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no\">";
	html = html.."<meta name=\"format-detection\" content=\"telephone=no\">";
	html = html.."</head>";
	html = html.."<body style=\"padding-top:0px;padding-bottom:44px;\">";
    html = html.."$title";
	html = html..content;
	html = html.."</body>";
	html = html.."</html>";

	return html;
end

function analyseSoundURL(html)
    local beginIndex, endIndex = string.find(html, "http://down.51voa.com/");
    if beginIndex then
        local beginIndex2, endIndex2 = string.find(html, "\"", beginIndex);
        local sound = string.sub(html, beginIndex, beginIndex2 - 1);
        return sound;
    end
    
    return "";
end

function nullContent(en)
    local msg = "No content yet";
    if en == "0" then
        msg = "No content yet";
    end
    return msg;
end

function dictionaryName()
    return "LNMXBLHNHLLC";
end

function dictionaryURLForWord(word)
    local haiciURL = "http://3g.dict.cn/s.php?q=";
    word = string.gsub(word, " ", "+");
    
    return haiciURL..word;
end

function filterDictionaryResult(result)
    
    local beginIndex3, endIndex3 = string.find(result, "</head>");
    local prefixStr = "";
    if beginIndex3 then
        prefixStr = string.sub(result, 0, endIndex3);
    end
    --print(prefixStr);
    --print(result);
    local beginIndex1, endIndex1 = string.find(result, "<div class=\"content\">");
    if beginIndex1 then
        local beginIndex2, endIndex2 = string.find(result, "</body>");
        local resultStr = string.sub(result, beginIndex1, beginIndex2);
        resultStr = removeTag(resultStr, "a", false);
        resultStr = prefixStr.."<body>"..resultStr.."</body>";
        return resultStr;
    else
        return "";
    end
    
    return result;
end

