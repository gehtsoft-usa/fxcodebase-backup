-- Id: 12700
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61316

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
    indicator:name("Larry's 2 day Signal");
    indicator:description("Larry's 2 day Signal");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "Method", "Both");
	indicator.parameters:addStringAlternative("Method", "Both", "Both" , "Both");
    indicator.parameters:addStringAlternative("Method", "Long", "Long" , "Long");
	indicator.parameters:addStringAlternative("Method", "Short", "Short" , "Short");
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addInteger("Size", "Font Size","Font Size", 15, 0, 1000);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;

local first;
local source = nil;

-- Streams block
local Up = nil;
local Down = nil;
local font;
local TrueLow, TrueHigh;
-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method;
	Size= instance.parameters.Size;
    source = instance.source;
    first = source:first()+1;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method) .. ")";
    instance:name(name);
    if nameOnly then
        font = core.host:execute("createFont", "Wingdings", Size, false, false);
        TrueLow = instance:addInternalStream(0, 0);
        TrueHigh = instance:addInternalStream(0, 0);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	TrueLow[period]= math.min(source.low[period],source.close[period-1]);
	TrueHigh[period]= math.max(source.high[period],source.close[period-1]);
	
	local Flag;
	
	
	if source.close[period]-TrueLow[period] > source.close[period-1]-TrueLow[period-1]
    and TrueHigh[period]-source.close[period]< TrueHigh[period-1] - source.close[period]
    and  source.close[period]<source.close[period-1] and source.close[period-1]<source.close[period-2]
	then
	Flag=1;
	elseif TrueHigh[period]-source.close[period] > TrueHigh[period-1]-source.close[period-1]
    and source.close[period] -TrueLow[period] < source.close[period-1] - TrueLow[period-1]
    and  source.close[period]>source.close[period-1] and source.close[period-1]>source.close[period-2]
	then
	Flag=-1
	else
	Flag=0
	
	end
 
     
    if Flag== 1 and Method ~= "Short" then	 
    core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, Up, "\225");
    elseif Flag== -1  and Method ~= "Long"  then	
    core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,  font, Down, "\226");
	else
	core.host:execute ("removeLabel", source:serial(period));
    end	

end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   
