-- Id: 13296
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61619

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("LBR Pivot Point");
    indicator:description("LBR Pivot Point");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "Method", "Method" , "Historical");
    indicator.parameters:addStringAlternative("Method", "Historical", "Historical" , "Historical");
    indicator.parameters:addStringAlternative("Method", "Current", "Current" , "Current");
	indicator.parameters:addString("TF", "Time Frame", "Time Frame" , "D1");
	indicator.parameters:setFlag ("TF", core.FLAG_PERIODS)
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of LBRPP", "Color of LBRPP", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local loading, Source;
-- Streams block
local LBRPP = nil;
local ROC;
local Method;
local dayoffset, weekoffset;
local TF;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Method=instance.parameters.Method;
	TF=instance.parameters.TF;
	
	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");

    if (not (nameOnly)) and  Method == "Historical" then
        ROC = instance:addInternalStream(0, 0);
        LBRPP = instance:addStream("LBRPP", core.Line, name, "LBRPP", instance.parameters.color, first);
		LBRPP:setWidth(instance.parameters.width);
        LBRPP:setStyle(instance.parameters.style);
    end
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	 local p =  Initialization(period) 
     
	    if not p then
		return;
		end
	
	if   Method == "Historical" then 
	ROC[period]= Source.close[p]-Source.close[p-2];     
	LBRPP[period] = Source.close[p-1]+ROC[period];
	else
	local ROC = Source.close[p]-Source.close[p-2];     
	local toLevel = Source.close[p-1]+ROC;
	local fromDate, toDate = core.getcandle(TF, source:date(source:size()-1),dayoffset, weekoffset); 
	core.host:execute ("drawLine", 1, fromDate, toLevel, toDate, toLevel, instance.parameters.color, instance.parameters.style, instance.parameters.width, string.format("%." .. source:getPrecision() .. "f", toLevel))
	end
     
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


