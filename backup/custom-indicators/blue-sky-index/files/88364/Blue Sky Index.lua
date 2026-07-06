-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58967
-- Id: 9663

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Blue Sky Index");
    indicator:description("Blue Sky Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);

    indicator.parameters:addString("TF", "Time frame", "", "d");
    indicator.parameters:addStringAlternative("TF", "Day", "", "d");
    indicator.parameters:addStringAlternative("TF", "Week", "", "w");
    indicator.parameters:addStringAlternative("TF", "Month", "", "m");
    indicator.parameters:addDate("FROM", "Date from", "", -1000);
    indicator.parameters:addDate("TO", "Date to", "", 0);
    indicator.parameters:setFlag("TO", core.FLAG_DATE);
end

local O, H, L, C, V
local loadingRequest1, loadingRequest2;
local loading, loadError;
local token1 = {}; 
local token2 = {};

-- initializes the instance of the indicator
function Prepare(onlyName)

    local TF = instance.parameters.TF;

    local name = profile:id() .. " ( OEX / VIX ) " .. ", " .. TF .. ")";

    instance:name(name);
    if onlyname then
        return ;
    end

    instance:initView("BSI", 2, 0.01, true, false);


    O = instance:addStream("O", core.Line, name .. ".O", "O", core.rgb(255, 0, 0), 0);
    H = instance:addStream("H", core.Line, name .. ".H", "H", core.rgb(255, 0, 0), 0);
    L = instance:addStream("L", core.Line, name .. ".L", "L", core.rgb(255, 0, 0), 0);
    C = instance:addStream("C", core.Line, name .. ".C", "C", core.rgb(255, 0, 0), 0);
    V = instance:addStream("V", core.Line, name .. ".V", "V", core.rgb(255, 0, 0), 0);
    instance:createCandleGroup("BSI", "BSI", O, H, L, C, V, TF);
	
    core.host:execute("setTimer", 2, 2);

	local maxRepeat = 5;
	local res1 = false; 
    local res2 = false;
    while res1 == false or res2 == false do
        if res1 == false then
			loadingRequest1, res1 = StartLoading("^OEX", TF, instance.parameters.FROM, instance.parameters.TO);
		end	
		if res2 == false then
			loadingRequest2, res2 = StartLoading("^VIX", TF, instance.parameters.FROM, instance.parameters.TO);
		end	
        maxRepeat = maxRepeat - 1;
        if maxRepeat < 0 then
            errorLoad = true;
            core.host:execute("setStatus", "load failed");
            return;
		end	
    end 
	
	loading = true;
    core.host:execute("setStatus", "loading...");
end

function Update(period)
end

function getToken(index)

    local token = {};
    local req = http_lua.createRequest();
    local url = string.format("https://finance.yahoo.com/quote/%s?p=&s", index, index);
    
    req:start(url);
    while req:loading() do
        end
        
    if not(req:success()) then
        errorLoad = true;
        core.host:execute("setStatus", "load failed");
        return nil;
    end    
    
    if req:httpStatus() ~= 200 then
        errorLoad = true;
        core.host:execute("setStatus", "load failed");
        return nil;
    end

    local response = req:response();
    
    local cookie = req:responseHeader("set-cookie");
    
    if  cookie == nil then 
        errorLoad = true;
        core.host:execute("setStatus", "load failed");
        return nil;
    end
    
    token.cookie = string.sub(cookie, 0, string.find(cookie, ";") - 1);
    token.crumb = string.match(response, '"CrumbStore":{"crumb":"(%P+)"}');
    
    if  token == nil or token.cookie == nil or token.crumb == nil then 
        errorLoad = true;
        core.host:execute("setStatus", "load failed");
        return nil;
    end
    
    return token;
end

function StartLoading(index, timeframe, _from, _to)

    token = getToken(index)
    
    if token == nil then 
        return nil,false;
    end 

    local from = core.dateToTable(_from);
    local to = core.dateToTable(_to);

    if timeframe == "d" then
      timeframe = "1d";
    elseif timeframe == "w" then
      timeframe = "1wk";
    else
      timeframe = "1mo";
    end
      
    local convertedFrom = os.time({year = from.year, month = from.month, day = from.day, hour = 0, min = 0, sec = 0});
    local convertedTo = os.time({year = to.year, month = to.month, day = to.day, hour = 0, min = 0, sec = 0});
      
    local url = string.format("https://query1.finance.yahoo.com/v7/finance/download/%s?period1=%s&period2=%s&interval=%s&events=history&crumb=%s",
                              index,
                              tostring(convertedFrom),
                              tostring(convertedTo),
                              timeframe,
                              token.crumb);
    
    local loadingRequest = http_lua.createRequest();                          
    loadingRequest:setRequestHeader("Cookie", token.cookie);
    loadingRequest:start(url);
	
	return loadingRequest, true;
end

local pattern_line = "([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)\n";
local pattern_date = "(%d+)-(%d+)-(%d+)";

function AsyncOperationFinished(cookie, success, message)
    if cookie == 2 then
        if loading == true then
            if  not(loadingRequest1:loading()) and not(loadingRequest2:loading())  then
                loading = false;
                if loadingRequest1:httpStatus() == 200 then
                     local body1 = loadingRequest1:response();					 
                     local pos;
                     local date, open, high, low, close, adjClose, volume, t, period;
                     local year, month, day;
                     local periods1 = {};
                     local count1 = 0;
                     while true do
                         date, open, high, low, close, adjClose, volume = string.match(body1, pattern_line, pos);
                         if date == nil then
                             break;
                         end
                         pos = string.find(body1, '\n', pos) + 3 
					     year, month, day = string.match(date, pattern_date);
                         if year ~= nil then
                             t = {};
                             t.month = tonumber(month);
                             t.day = tonumber(day);
                             t.year = tonumber(year);
                             t.year = (t.year < 70) and 2000 + t.year or 1900 + t.year;
                             t.hour = 0;
                             t.min = 0;
                             t.sec = 0;
                             period = {};
                             period.date = core.tableToDate(t);
                             period.open = tonumber(open);
                             period.high = tonumber(high);
                             period.low = tonumber(low);
                             period.close = tonumber(close);
                             period.volume = tonumber(volume);
                             count1 = count1 + 1;
                             periods1[count1] = period;
                         end
                     end
					
                    if loadingRequest2:httpStatus() == 200 then				

                     local body2 = loadingRequest2:response();					 
                     local pos;
                     local date, open, high, low, close, adjClose, volume, t, period;
                     local year, month, day;
					 local periods2 = {};
                     local count = 0;
					 
					while true do
                         date, open, high, low, close, adjClose, volume = string.match(body2, pattern_line, pos);
                         if date == nil then
                             break;
                         end
                         pos = string.find(body2, '\n', pos) + 3 
					     year, month, day = string.match(date, pattern_date);
                         if year ~= nil then
                             t = {};
                             t.month = tonumber(month);
                             t.day = tonumber(day);
                             t.year = tonumber(year);
                             t.year = (t.year < 70) and 2000 + t.year or 1900 + t.year;
                             t.hour = 0;
                             t.min = 0;
                             t.sec = 0;
                             period = {};
                             period.date = core.tableToDate(t);
                             period.open = tonumber(open);
                             period.high = tonumber(high);
                             period.low = tonumber(low);
                             period.close = tonumber(close);
                             period.volume = tonumber(volume);
                             count = count + 1;
                             periods2[count] = period;
                         end
                     end
					 
					 
					 
					 if loadingRequest1:httpStatus() == 200  and loadingRequest2:httpStatus() == 200  then		
					
                     local lastdate = nil, date1, date2, s;
							 for i = 1, count do
								date1 = periods1[i].date;
								date2 = periods2[i].date;
									if lastdate == nil or lastdate < date1 or  lastdate < date2 then
										instance:addViewBar(date1);
										s = O:size() - 1;
										if periods1[i].open~=nil and periods2[i].open~=nil then
										O[s] = periods1[i].open/periods2[i].open;
										H[s] = periods1[i].high/periods2[i].high;
										L[s] = periods1[i].low/periods2[i].low;
										C[s] = periods1[i].close/periods2[i].close;
										V[s] = periods1[i].volume/periods2[i].volume;
										end
										lastdate = date1;
									else
										core.host:trace(string.format("%i %s %s", i, core.formatDate(lastdate), core.formatDate(date1)));
									end
								
						end
					 
					end
					
					
                     end
                     errorLoad = false;
                     core.host:execute("setStatus", "");
                     return core.ASYNC_REDRAW;
                else
                     errorLoad = true;
                     core.host:execute("setStatus", "load failed");
                end
            end
        end
    end
    return 0;
end

function ReleaseInstance()
    if loading then
        while (loadingRequest1:loading()) or (loadingRequest2:loading())  do
        end
		
    end
    core.host:execute("killTimer", 1);
end


require("http_lua");    


