-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26614
-- Id: 7948

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
    indicator:name("FRACTAL DIMENSION INDICATOR");
    indicator:description("FRACTAL DIMENSION INDICATOR");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("N", "Period", "Period", 30);	
    indicator.parameters:addInteger("P", "Average Period", "Average Period", 20);
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addColor("FDI_color", "Color of FDI", "Color of FDI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Levels Style");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 1.6);
    indicator.parameters:addDouble("oversold","Oversold Level","", 1.4);
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
local N;
local P;

local first;
local Price = nil;

-- Streams block
local Dimen = nil;
local Smooth,Ratio,MA;
-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    P = instance.parameters.P;
    Price = instance.source;
 

    local name = profile:id() .. "(" .. Price:name() .. ", " .. tostring(N) .. ", " .. tostring(P) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	    Smooth = instance:addInternalStream(0, 0);
		Ratio  = instance:addInternalStream(0, 0);
		MA = core.indicators:create("MVA", Ratio, P);		
        Dimen = instance:addStream("FDI", core.Line, name, "FDI", instance.parameters.FDI_color, MA.DATA:first());
    Dimen:setPrecision(math.max(2, instance.source:getPrecision()));
		Dimen:setWidth(instance.parameters.width);
        Dimen:setStyle(instance.parameters.style);
		Dimen:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Dimen:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	
	if period <   Price:first() +3 then
	return;
	end
		
	Smooth[period] = (Price[period] + 2*Price[period-1] + 2*Price[period-2] + Price[period-3]) / 6;
	
	if period <  Price:first() +3  +N then
	return;
	end
	
	local min,max;	
	min,max = mathex.minmax(Smooth, period-N+1, period);
	
	N3 = (max - min ) / N;

	min,max = mathex.minmax(Smooth, period-N/2+1, period);
	
	N1 = (max - min) / (N / 2);
	
	min,max = mathex.minmax(Smooth, period-N+1 , period-N/2+1);

	N2 = (max - min)/(N / 2);
  
  
    Ratio[period] = 0.5*((math.log(N1 + N2) - math.log(N3)) / math.log(2) + Dimen[period-1])
	
	
	if period < MA.DATA:first() then
	return;	
	end
	
	MA:update(mode);
	
	Dimen[period] = MA.DATA[period];
	
end
