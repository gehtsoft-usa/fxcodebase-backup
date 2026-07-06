-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60063
-- Id: 10653

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
    indicator:name("Stochastic Momentum Indicator");
    indicator:description("Stochastic Momentum Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Period", "Period", 12);
    indicator.parameters:addInteger("Smooth1", "Smooth1", "Smooth1", 25);
	indicator.parameters:addInteger("Smooth2", "Smooth2", "Smooth2", 2);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SM_color", "Color of SM", "Color of SM", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 50);
    indicator.parameters:addDouble("oversold","Oversold Level","", -50);
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
local Length;
local Smooth1,Smooth2;

local first;
local source = nil;
local rawB,rawN;
-- Streams block
local SM = nil;
local Signal, signal;
local one, two;
local One, Two;
-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length;
    Smooth1 = instance.parameters.Smooth1;
    Smooth2 = instance.parameters.Smooth2;
    source = instance.source;
	
    first = source:first()+Length;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Length) .. ", " .. tostring(Smooth1) .. ", " .. tostring(Smooth2).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		rawB  = instance:addInternalStream(0, 0);
		one  = core.indicators:create("EMA", rawB, Smooth1);
		two  = core.indicators:create("EMA", one.DATA, Smooth2);
		
		rawN  = instance:addInternalStream(0, 0);
		One  = core.indicators:create("EMA", rawN, Smooth1);
		Two  = core.indicators:create("EMA", One.DATA, Smooth2);
        SM = instance:addStream("SM", core.Line, name .. ".SM", "SM", instance.parameters.SM_color, two.DATA:first());
    SM:setPrecision(math.max(2, instance.source:getPrecision()));
		SM:setWidth(instance.parameters.width1);
        SM:setStyle(instance.parameters.style1);
		
		SM:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		SM:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		SM:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
		signal  = core.indicators:create("MVA", SM, Smooth1);
        Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, signal.DATA:first());		
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first  or not  source:hasData(period) then
	return;
	end
	
	local min,max;
	min, max =mathex.minmax( source, period-Length+1, period );
	
	 rawB[period]=source.close[period] - (0.5 *( max + min ) );
	 rawN[period]=  (0.5 *( max - min ) );
	
	one:update(mode);
	two:update(mode);
	
	One:update(mode);
	Two:update(mode);
	
	    if period < two.DATA:first() then
		  return;
		  end
	
	    local B,N;
		B= two.DATA[period];		
		N=Two.DATA[period];
		
	    local X=B/N;
		
        SM[period] = 100 *X;
		
		signal:update(mode);
		  if period < signal.DATA:first() then
		  return;
		  end
        Signal[period] = signal.DATA[period];
   
end
 