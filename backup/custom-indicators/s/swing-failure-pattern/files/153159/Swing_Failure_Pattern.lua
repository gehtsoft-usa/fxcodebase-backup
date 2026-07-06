-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74312

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Swing Failure Pattern");
    indicator:description("Swing Failure Pattern");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("param1", "Bars to look back", "", 100);
    indicator.parameters:addInteger("param2", "Ignore last ... bars", "", 10);
	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addInteger("Size", "Size", "", 20);
    indicator.parameters:addString("param3", "Character to show (only 1 is allowed)", "", "X");
 	indicator.parameters:addColor("param4", "Label color", "", core.COLOR_LABEL );
end

local source;
local params = {};
local last_high;
local ignored_high;
local plot1;
local last_low;
local ignored_low;
local plot2;
local vars = {};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Size = instance.parameters.Size;
	
    vars["lookback"] = instance.parameters.param1;
    vars["ignore"] = instance.parameters.param2;
    vars["char"] = instance.parameters.param3;
    vars["char_color"] = instance.parameters.param4;
    last_high = instance:addInternalStream(0, 0);
    ignored_high = instance:addInternalStream(0, 0);
    plot1 = instance:createTextOutput("plot1", "plot1", "Verdana", Size, core.H_Center, core.V_Top, vars["char_color"], 0);
    last_low = instance:addInternalStream(0, 0);
    ignored_low = instance:addInternalStream(0, 0);
    plot2 = instance:createTextOutput("plot2", "plot2", "Verdana", Size, core.H_Center, core.V_Top, vars["char_color"], 0);
end

function Update(period, mode)
    if source:first() > period - vars["lookback"] then return; end
    last_high[period] = mathex.max(source, core.rangeTo(period, vars["lookback"]));
    if source:first() > period - vars["lookback"] then return; end
    last_low[period] = mathex.min(source, core.rangeTo(period, vars["lookback"]));
    if source:first() > period - vars["ignore"] then return; end
    ignored_high[period] = mathex.max(source, core.rangeTo(period, vars["ignore"]));
    if source:first() > period - vars["ignore"] then return; end
    ignored_low[period] = mathex.min(source, core.rangeTo(period, vars["ignore"]));
    if last_high:first() > period - 1 then return; end
    if last_high:first() > period - 1 then return; end
    if last_high:first() > period - 1 then return; end
    if ignored_high:first() > period - 1 then return; end
    if ((source.high[period] > last_high[period - 1]) and (source.close[period] < last_high[period - 1]) and (last_high[period - 1] ~= ignored_high[period - 1]) and source.close[period] or nil) then
        plot1:set(period, source.close[period], vars["char"], "");
    end
    if last_low:first() > period - 1 then return; end
    if last_low:first() > period - 1 then return; end
    if last_low:first() > period - 1 then return; end
    if ignored_low:first() > period - 1 then return; end
    if ((source.low[period] < last_low[period - 1]) and (source.close[period] > last_low[period - 1]) and (last_low[period - 1] ~= ignored_low[period - 1]) and source.close[period] or nil) then
        plot2:set(period, source.close[period], vars["char"], "");
    end
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+