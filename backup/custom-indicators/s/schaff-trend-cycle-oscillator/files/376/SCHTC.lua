-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=249

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 


-- initializes the indicator
function Init()
    indicator:name("Schaff Trend Cycle Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("C", "Schaff cycle periods", "", 10, 2, 10000);
    indicator.parameters:addInteger("S", "Short periods", "", 23, 2, 10000);
    indicator.parameters:addInteger("L", "Long periods", "", 50, 2, 10000);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("clrSCHTC", "Color of the line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 30);
    indicator.parameters:addDouble("oversold","Oversold Level","", 70);
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local firstmcd = 0;
local firstst = 0;
local first = 0;
local S = 0;
local L = 0;
local C = 0;
local source = nil;
local out = nil;
local wmas, wmal, wmast;
local st, mcd

-- initializes the instance of the indicator
function Prepare(nameOnly) 
    source = instance.source;
    S = instance.parameters.S;
    L = instance.parameters.L;
    C = instance.parameters.C;
	
	local name = profile:id() .. "(" .. source:name() .. "," .. C .. "," .. S .. "," .. L .. ")";
	    instance:name(name);

	if   (nameOnly) then
        return;
    end

    assert(S < L, "Short Period Length must be less than Long Period Length");
    assert(C < L, "Cycle Periods must be less than Long Period Length");

    wmas = core.indicators:create("WMA", source, S);
    wmal = core.indicators:create("WMA", source, L);

    firstmcd = wmal.DATA:first();
    mcd = instance:addInternalStream(firstmcd, 0);
    firstst = firstmcd + C;
    st = instance:addInternalStream(firstst, 0);

    wmast = core.indicators:create("WMA", st, C / 2);
    first = wmast.DATA:first();

    

    out = instance:addStream("SCHTC", core.Line, name, "SCHTC", instance.parameters.clrSCHTC,  first)
	out:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	out:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	out:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	out:addLevel(100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	out:setPrecision (2);	
	out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);   
end

-- calculate the value
function Update(period, mode)
    if (period >= firstmcd) then
        wmas:update(mode);
        wmal:update(mode);
        mcd[period] = wmas.DATA[period] - wmal.DATA[period];
    end
    if (period >= firstst) then
        local lookback = core.rangeTo(period, C);
        local max = core.max(mcd, lookback);
        local min = core.min(mcd, lookback);
        st[period] = (mcd[period] - min) / (max - min) * 100;
    end
    if (period > first) then
        wmast:update(mode);
        out[period] = wmast.DATA[period];
    end
end

