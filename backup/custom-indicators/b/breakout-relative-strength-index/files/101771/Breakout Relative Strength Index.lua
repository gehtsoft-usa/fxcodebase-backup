-- Id: 14657
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62528

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
    indicator:name("Breakout Relative Strength Index");
    indicator:description("Breakout Relative Strength Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BRSI_color", "Color of BRSI", "Color of BRSI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local Indicator;
-- Streams block
local BRSI = nil;
local p,n;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
 
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	    Breakout_Power = instance:addInternalStream(0, 0);
		n = instance:addInternalStream(0, 0);
		p = instance:addInternalStream(0, 0);

    if (not (nameOnly)) then	  
        BRSI = instance:addStream("BRSI", core.Line, name, "BRSI", instance.parameters.BRSI_color, first+Period);
    BRSI:setPrecision(math.max(2, instance.source:getPrecision()));
        BRSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		BRSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		BRSI:setWidth(instance.parameters.width);
        BRSI:setStyle(instance.parameters.style);  
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
   
 
	
    if period < first or not  source:hasData(period) then
	return;
	end
	
	local min,max=mathex.minmax(source,period-1, period);
 
	
	local Breakout_Price = (source.open[period-1] + max + min + source.close[period]) / 4; 
    local Breakout_Strength = (source.close[period]-source.open[period-1])/(max-min);
	local Breakout_Volume=source.volume[period]+source.volume[period-1];
	
    Breakout_Power[period] = Breakout_Price * Breakout_Strength * Breakout_Volume;
 
 
	if  Breakout_Power[period] > Breakout_Power[period-1] then
	p[period]=math.abs(Breakout_Power[period]);
	n[period]=0;
	else
	n[period]=math.abs(Breakout_Power[period]);
	p[period]=0;
    end
	
   if period < first+Period then
   return;
   end
   
local P= mathex.sum(p, period-Period+1, period );
local N= mathex.sum(n, period-Period+1, period );

local Breakout_Ratio;

if N== 0 then
BRSI[period]=0;
else
BRSI[period] = 100 - (100 / (1 + P/N))
end
 
    
end

