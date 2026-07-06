-- Id: 12425
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61114

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
    indicator:name("Period Above");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
   
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("PA_Up", "Color of PA Up", "Color of PA", core.rgb(0, 255, 0));
	indicator.parameters:addColor("PA_Down", "Color of PA Down", "Color of PA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 10);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period,Method;
local MA;
local first;
local source = nil;
local font;
 

-- Streams block
local PA = nil;
function ReleaseInstance()
       core.host:execute("deleteFont", font);

end
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		font = core.host:execute("createFont", "Courier", instance.parameters.Size,  true, false);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method, source.close,Period);
		first = MA.DATA:first();
        PA = instance:addInternalStream(0, 0);
		 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    MA:update(mode);
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	    if source.close[period]> MA.DATA[period] then
		 PA[period] = PA[period-1]+1;
		elseif source.close[period]< MA.DATA[period] then
		 PA[period] = PA[period-1]-1;
		end
	
	
	if (source.close[period]> MA.DATA[period] and source.close[period-1]< MA.DATA[period-1])	
	then
	PA[period]=1;
	elseif (source.close[period]< MA.DATA[period] and source.close[period-1]> MA.DATA[period-1])
	then
	PA[period]=-1;
	end
	
	
	
	if    PA[period] >0 then 
	core.host:execute ("drawLabel1", source:serial(period),source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, instance.parameters.PA_Up, tostring(PA[period]));
	elseif    PA[period]<0 then  
	core.host:execute ("drawLabel1", source:serial(period),source:date(period), core.CR_CHART,  source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, instance.parameters.PA_Down, tostring(math.abs(PA[period])));
	else
	core.host:execute ("removeLabel", source:date(period));
	end
    
end

