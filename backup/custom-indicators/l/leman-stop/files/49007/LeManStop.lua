-- Id: 8215
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27929

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("LeMan Stop");
    indicator:description("LeMan Stop");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("per", "Period", "Period", 24);
    indicator.parameters:addInteger("coef", "Coefficient", "Coefficient", 4);	
    indicator.parameters:addInteger("fastP", "Fast MA Period", "Fast MA Period", 9);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("slowP", "Slow MA Period", "Slow MA Period", 18);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
   indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("R", "Color of Resistance", "Color of LMS", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("S", "Color of Support", "Color of Support", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local per;
local coef;
local fastP;
local slowP;
local fast, slow;
local Method2, Method1;
local first;
local source = nil;
local MA;
-- Streams block
local ExtBuffer = nil;
local HO, OL;
-- Routine
function Prepare(nameOnly)
    Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1;
    per = instance.parameters.per;
    coef = instance.parameters.coef;
    fastP = instance.parameters.fastP;
    slowP = instance.parameters.slowP;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(per) .. ", " .. tostring(coef) .. ", " .. tostring(fastP) .. ", " .. tostring(Method1) .. ", " .. tostring(slowP)  .. ", " .. tostring(Method2).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        fast = core.indicators:create( Method1,source.close, fastP);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
        slow = core.indicators:create(Method2, source.close, slowP);
        first = math.max(slow.DATA:first(), fast.DATA:first(), per);
        
        HO = instance:addInternalStream(0, 0);
        OL = instance:addInternalStream(0, 0);
        ExtBuffer= instance:addStream("LMS", core.Line, name, "LMS", instance.parameters.R, first);
		ExtBuffer:setWidth(instance.parameters.width);
        ExtBuffer:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    fast:update(mode);
	slow:update(mode);
	
	HO[period]= source.high[period]-source.open[period];
	OL[period]= source.open[period]-source.low[period];
	
	if period < first  then
       return;
    end
	
	local  EMA0 = fast.DATA[period]- slow.DATA[period];
    local  EMA1 = fast.DATA[period-1]- slow.DATA[period-1];
    local  PreStop = ExtBuffer[period-1];
	
	local x,Stop;
	
	if EMA0 > 0 then
		x = mathex.avg (HO, period -per+1, period);
		
		
		Stop = source.open[period]-(coef*x);
		
		  if (Stop < PreStop and (EMA1 > 0))   then
				Stop = PreStop;
				
		  end
		
	end
	if EMA0 < 0 then
	x = mathex.avg (OL, period -per+1, period);
		
	Stop = source.open[period-1]+(coef*x);
	
	  if ((Stop > PreStop) and (EMA1 < 0)) then
            Stop = PreStop;
			
       end
	
	end
	
	ExtBuffer[period] = Stop;
	
	if ExtBuffer[period] > source.close[period] 
	--and Stop < PreStop
	then
    ExtBuffer:setColor(period,  instance.parameters.R);
	elseif ExtBuffer[period] < source.close[period] 
	--and Stop > PreStop
	then
	ExtBuffer:setColor(period,  instance.parameters.S);
	end
	
	 
end

