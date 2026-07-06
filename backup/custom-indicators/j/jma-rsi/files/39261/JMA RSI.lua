-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22753
-- Id: 7206

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("JMA smoothed RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("RSI Calculation");	
    indicator.parameters:addInteger("RP", "Period", "Period", 14);

	
	indicator.parameters:addGroup("JMA Calculation");
    indicator.parameters:addInteger("N", "Number of periods to smooth", "", 8, 1, 10000);
    indicator.parameters:addInteger("P", "Phase", "", 100, -1000, 1000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSI_color", "Line C0lor", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought Level","", 70, 0, 100);
    indicator.parameters:addInteger("oversold","Oversold Level","", 30, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RP;

local first;
local source = nil;
local N,P;
-- Streams block
local RSI = nil;
	local AverageGain;
	local AverageLoss;
    local Loss;
	local Gain;
-- Routine
function Prepare(nameOnly)
    RP = instance.parameters.RP;
	N = instance.parameters.N;
	P = instance.parameters.P;
	Method = instance.parameters.Method;
    source = instance.source;
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(RP) .. ", " .. tostring(N) .. ", " .. tostring(P).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Loss= instance:addInternalStream (0, 0);
		Gain= instance:addInternalStream (0, 0);
	
	   assert(core.indicators:findIndicator("JMA") ~= nil, "Please, download and install JMA.LUA indicator");
		
		AverageGain = core.indicators:create("JMA", Gain, N,P );
		AverageLoss = core.indicators:create("JMA", Loss, N,P );
		
		first = AverageLoss.DATA:first();
        RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.RSI_color, first+RP);
		RSI:setWidth(instance.parameters.width);
        RSI:setStyle(instance.parameters.style);
		
		RSI:setPrecision(2);
    
		RSI:addLevel(0);
		RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSI:addLevel(50);
		RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		RSI:addLevel(100);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

   if period < source:first()+1 then
   return;
   end
   
   local diff = source[period] - source[period - 1];
    if  diff > 0 then
	Loss[period] = 0;
	Gain[period] = diff;
	else
	Loss[period] = -diff;
	Gain[period] = 0;
	end    	

	
	if period < first  then
	return;
	end	
	
	 AverageGain:update(mode);
	 AverageLoss:update(mode);
	
	local RS;	
	
	    
		
		if (AverageLoss.DATA[period] == 0)
		or  (AverageGain.DATA[period] / AverageLoss.DATA[period])==-1
		then
		RSI[period]=0;
		else  
		RS = AverageGain.DATA[period] / AverageLoss.DATA[period];	
        RSI[period] = 100- (100 / (1+RS));
		end
   
end

