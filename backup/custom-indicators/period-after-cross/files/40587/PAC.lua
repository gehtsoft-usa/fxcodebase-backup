-- Id: 7446
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23585

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
    indicator:name("Period After Cross");
    indicator:description("Period After Cross");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_PAC", "Color of Pozitiv PAC", "Color of PAC", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn_PAC", "Color of Negativ PAC", "Color of PAC", core.rgb(255, 0, 0));
	--indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
   -- indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
   -- indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local first;
local source = nil;
local MA;
-- Streams block
local PAC = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        MA= core.indicators:create(Method, source, Period);
        first = MA.DATA:first();
        PAC = instance:addStream("PAC", core.Bar, name, "PAC", core.rgb(128, 128, 128), first);
    PAC:setPrecision(math.max(2, instance.source:getPrecision()));
		--PAC:setWidth(instance.parameters.width);
       -- PAC:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    MA:update(mode);
	
	PAC[period]=0;
	
    if period < first or not  source:hasData(period) then
	return;
	end
	
	
	if source[period] >  MA.DATA[period] and  source[period-1] >  MA.DATA[period-1] then
	PAC[period]=PAC[period-1]+1;
    elseif source[period] <  MA.DATA[period] and  source[period-1] <  MA.DATA[period-1] then
	PAC[period]=PAC[period-1]-1;
    elseif  source[period] >  MA.DATA[period] then
   	PAC[period]=1;
	elseif  source[period] <  MA.DATA[period] then
	PAC[period]=-1;
	end
	
	if PAC[period]> 0 then
	PAC:setColor(period, instance.parameters.Up_PAC);
	else
	PAC:setColor(period, instance.parameters.Dn_PAC);
	end    
    
end

