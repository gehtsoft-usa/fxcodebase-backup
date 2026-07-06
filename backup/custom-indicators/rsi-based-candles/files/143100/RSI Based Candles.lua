-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71398

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
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RSI Based Candles");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI", "RSI Period", "", 14); 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addDouble("Overbought", "Overbought Level", "", 70);
	indicator.parameters:addDouble("Oversold", " Oversold Level", "",  30);
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
local RSI; 
local first;
local source = nil;
local Indicator={}; 

local open=nil;
local close=nil;
local high=nil;
local low=nil;

-- Routine
function Prepare(nameOnly)
    Overbought = instance.parameters.Overbought;
	Oversold = instance.parameters.Oversold;
	Color= instance.parameters.Color;
	RSI = instance.parameters.RSI; 
    source = instance.source;
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(RSI) .. ", " .. tostring(Overbought).. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end	
	
	
	 Indicator["Close"] = core.indicators:create("RSI", source.close, RSI); 
	 Indicator["Open"] = core.indicators:create("RSI", source.open, RSI);
	 Indicator["High"] = core.indicators:create("RSI", source.high, RSI);
	 Indicator["Low"] = core.indicators:create("RSI", source.low, RSI);
	 
	 first = Indicator["Close"].DATA:first() 
	 
	 
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)  
    instance:createCandleGroup("ZONE", "ZONE", open, high, low, close );
 
    
	open:addLevel(Overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	open:addLevel(Oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    open:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
	 Indicator["Close"]:update(mode);
	 Indicator["Open"]:update(mode);
	 Indicator["High"]:update(mode);
	 Indicator["Low"]:update(mode);


    high[period]= Indicator["High"].DATA[period];
	low[period]= Indicator["Low"].DATA[period];		   
	close[period] = Indicator["Close"].DATA[period];
	open[period]  = Indicator["Open"].DATA[period];	 
	
	 
end

 

 