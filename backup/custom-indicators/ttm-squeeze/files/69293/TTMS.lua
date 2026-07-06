-- Id: 9459
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=42679

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
    indicator:name("TTM Squeeze");
    indicator:description("TTM Squeeze");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Bollinger Calculation");
    indicator.parameters:addDouble("Period", "Number of periods", "Number of periods", 20.0);	
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2.0);
	
	
	indicator.parameters:addGroup("Keltner Calculation");
	    indicator.parameters:addInteger("NM", "Number of the periods to smooth the center line", "", 20);
    indicator.parameters:addInteger("NB", "Number of periods to smooth deviation", "", 20);
    indicator.parameters:addDouble("F", "Factor which is used to apply the deviation", "", 2);
	
	indicator.parameters:addString("MS", "The center line smoothing method", "", "MVA");
    indicator.parameters:addStringAlternative("MS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MS", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MS", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MS", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MS", "Wilders", "", "WMA");
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Up", "Color of Up TTMS", "Color of TTMS", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down TTMS", "Color of TTMS", core.rgb( 255, 0 , 0));
	--indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    --indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    --indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Alert", "Trade Zone Color", "Trade Zone Color", core.rgb( 0, 0 , 255));
	indicator.parameters:addColor("Neutral", "No Trade Zone Color", "No Trade Zone Color", core.rgb( 128, 128, 128));
	--indicator.parameters:addInteger("AlertWidth", "Line width", "", 1, 1, 5);
   -- indicator.parameters:addInteger("AlertStyle", "Line style", "", core.LINE_SOLID);
    --indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local TL, BL  ;
local Dev;
local Alert;
local source = nil;
local Period;
-- Streams block
local TTMS = nil;
local NM, NB, F;
local H, L, MS;
local ATR, MA;
-- Routine
function Prepare(nameOnly)
    Dev = instance.parameters.Dev;
	Period = instance.parameters.Period;
    source = instance.source;
	NB = instance.parameters.NB;
	NM = instance.parameters.NM;
	F = instance.parameters.F;
	MS = instance.parameters.MS;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period.. ", " .. tostring(Dev)  .. ", " .. NM .. ", " .. NB.. ", " .. F.. ", " .. MS.. ")";
    instance:name(name);

    if (not (nameOnly)) then
		
        TL = instance:addInternalStream(0,0);
        BL = instance:addInternalStream(0,0);
        H = instance:addInternalStream(0,0);
        L = instance:addInternalStream(0,0);
        
        ATR = core.indicators:create("ATR", source, NB);
    assert(core.indicators:findIndicator(MS) ~= nil, MS .. " indicator must be installed");
        MA = core.indicators:create(MS, source.close, NM);
        TTMS = instance:addStream("TTMS", core.Bar, name, "TTMS", instance.parameters.Up, math.max(Period, NM, NB));
    TTMS:setPrecision(math.max(2, instance.source:getPrecision()));
		--TTMS:setWidth(instance.parameters.width);
       -- TTMS:setStyle(instance.parameters.style);
		
		Alert = instance:addStream("Alert", core.Dot, name, "Alert", instance.parameters.Alert, math.max(Period, NM, NB));
    Alert:setPrecision(math.max(2, instance.source:getPrecision()));
		Alert:setWidth(3);
      --  Alert:setStyle(instance.parameters.AlertStyle);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < Period  then
	return;
	end
	
	BB(period);
	
	if period < math.max(NM, NB)  then
	return;
	end
	
	MA:update(mode);
	ATR:update(mode);
	
	Keltner(period);
	
	
   TTMS[period] = (H[period]-L[period])/(TL[period]-BL[period])-1;
   
   if  TTMS[period] >  TTMS[period-1] then
   TTMS:setColor(period, instance.parameters.Up);
   else
   TTMS:setColor(period, instance.parameters.Down);
   end
   
   Alert[period]=0;
   
   if  TL[period] <  H[period] and  BL[period] >  L[period] then
   Alert:setColor(period, instance.parameters.Alert);
   else
   Alert:setColor(period, instance.parameters.Neutral);
   end
   
end

function BB(period)

        --local p = core.rangeTo(period, Period);
        local ml = mathex.avg(source.close, period-Period+1, period);
        local d = mathex.stdev(source.close, period-Period+1, period);

        TL[period] = ml + Dev * d;
        BL[period] = ml - Dev * d;				
     

end

function Keltner (period)


       H[period] = MA.DATA[period] + ATR.DATA[period] * F;
        L[period] =  MA.DATA[period] - ATR.DATA[period] * F;
end