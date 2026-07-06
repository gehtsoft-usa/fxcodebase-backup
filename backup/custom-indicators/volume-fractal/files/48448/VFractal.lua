-- Id: 8096
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27687

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
    indicator:name("Volume Fractal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addBoolean("Filter", "Use Volume Filter", "", true);
	indicator.parameters:addInteger("LookBackPeriod", "Look Back Period", "", 0);
	
	indicator.parameters:addGroup("Style");	

    indicator.parameters:addString("Method", "Line Method", "Method" , "Dot");
    indicator.parameters:addStringAlternative("Method", "Dot", "Dot" , "Dot");
    indicator.parameters:addStringAlternative("Method", "Line", "Line" , "Line");
	
    indicator.parameters:addColor("R_color", "Color of R", "Color of R", core.rgb(255, 192, 0));
    indicator.parameters:addColor("S_color", "Color of S", "Color of S", core.rgb(0, 192, 255));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local Filter;
local LookBackPeriod;
-- Streams block
local R = nil;
local S = nil;
local Method;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Filter=instance.parameters.Filter;
	LookBackPeriod=instance.parameters.LookBackPeriod;
	Method=instance.parameters.Method;
    first = source:first() + 4;
	
	 
	 assert(source:supportsVolume(), "The source must have volume");

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	local iMethod;
	if Method== "Line" then
	iMethod=core.Line;
	else
	iMethod=core.Dot;
	end
    R = instance:addStream("R", iMethod , name .. ".R", "R", instance.parameters.R_color, first);
	R:setWidth(instance.parameters.width);
    R:setStyle(instance.parameters.style);
    S = instance:addStream("S", iMethod , name .. ".S", "S", instance.parameters.S_color, first);
	S:setWidth(instance.parameters.width);
    S:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period)
    if period < first 
    or ( LookBackPeriod~= 0 and period < source:size()-1 -LookBackPeriod)
	then
	return;
	end
	
	local UP = false;
	local DN = false;
	
	if Filter then	
	
		 if (source.volume[period-2]>(source.volume[period-3]+source.volume[period-4]+source.volume[period-5])/3) then
		 UP= true;
		 end
		 if (source.volume[period-2]>(source.volume[period-3]+source.volume[period-4]+source.volume[period-5])/3) then
		 DN= true;
		 end
		
	end
	
	
        -- defect fractals on two periods ago
        local up, down, curr;
        up = false;
        down = false;
        curr = source.high[period - 2];
        if (curr >= source.high[period - 4] and curr >= source.high[period - 3] and
            curr >= source.high[period - 1] and curr >= source.high[period]) then
            up = true;
        end
        if (up and UP)  or  (not Filter and up) then
            R[period - 2] = curr;
            R[period - 1] = curr;
            R[period] = curr;
        else
            if R:hasData(period - 1) then
                R[period] = R[period - 1];
            end
        end
        curr = source.low[period - 2];
        if (curr <= source.low[period - 4] and curr <= source.low[period - 3] and
            curr <= source.low[period - 1] and curr <= source.low[period]) then
            down = true;
        end
        if (down and DN)  or  (not Filter and down) then
            S[period - 2] = curr;
            S[period - 1] = curr;
            S[period] = curr;
        else
            if S:hasData(period - 1) then
                S[period] = S[period - 1];
            end
        end
   
end

