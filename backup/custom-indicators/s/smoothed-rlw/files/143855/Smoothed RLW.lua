-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71545

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

-- The indicator corresponds to the Larry Williams' Percent Range indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 143)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Smoothed %R Larry Williams");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period","", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRLW", "Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRLW", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleRLW", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRLW", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought Level","", -20, -100, 0);
    indicator.parameters:addInteger("oversold","Oversold Level","", -80, -100, 0);
    indicator.parameters:addInteger("level_overboughtsold_width", "Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style","Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
 

-- Streams block
local RLW = nil;
local Close, Low, High;
 
-- Routine
function Prepare()
    assert(instance.parameters.oversold < instance.parameters.overbought, "Uses Stochastics to determine overbought and oversold levels.");

    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first() + Period *2;
	
	
	Close = instance:addInternalStream(0, 0);
	Low = instance:addInternalStream(0, 0);
	High = instance:addInternalStream(0, 0); 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
    RLW = instance:addStream("RLW", core.Line, name, "%R", instance.parameters.clrRLW, first)
    RLW:setWidth(instance.parameters.widthRLW);
    RLW:setStyle(instance.parameters.styleRLW);
    RLW:setPrecision(2);
	
 

    RLW:addLevel(0);
    RLW:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(-100);
 
end

 

 

function Update(period)

    if period < source:first()+Period then
	return;
	end    
	
	Close[period]=mathex.avg(source.close, period-Period+1, period);
	High[period]=mathex.avg(source.high, period-Period+1, period);
	Low[period]=mathex.avg(source.low, period-Period+1, period);
	
	
	
    if period < first then
	return;
	end
	
 
        local low =  mathex.min(Low, period-Period+1, period);
        local high =  mathex.max(High, period-Period+1, period);	
		
        local diff = high - low;
        if (diff == 0) then
            RLW[period] = 0;
        else
            RLW[period] = (-100) * (high - Close[period]) / diff;
        end
    
end

 