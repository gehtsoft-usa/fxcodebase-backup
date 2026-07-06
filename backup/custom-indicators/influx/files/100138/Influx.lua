-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62160

--+------------------------------------------------------------------------+
--|                                    Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                 http://fxcodebase.com  |
--+------------------------------------------------------------------------+
--|                                      Support our efforts by donating   | 
--|                                         Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------+
--|                                           Developed by : Mario Jemic   |                    
--|                                               mario.jemic@gmail.com    |
--|                                https://AppliedMachineLearning.systems  |
--|                                     Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------+

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
    indicator:name("Influx");
    indicator:description("Influx");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

    indicator.parameters:addInteger("DurationOfFast", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 60);
    indicator.parameters:addInteger("DurationOfSlow", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 2500);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color of MACD", "Color of MACD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
local RawFast = nil;
local RawSlow = nil;
local Fast = nil;
local Slow = nil;
local DurationOfFast;
local DurationOfSlow;

 
local MACD; 
local Price;
local Second;
-- Routine
function Prepare(nameOnly)
    DurationOfFast = instance.parameters.DurationOfFast;
    DurationOfSlow = instance.parameters.DurationOfSlow;
	Price= instance.parameters.Price;
    source = instance.source;
    first=source:first();
	
	
	local name = profile:id() .. "(" .. source:name().. ", " .. tostring(Price) .. ", " .. tostring(DurationOfFast) .. ", " .. tostring(DurationOfSlow) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Second =(1/86400);
	 
        RawFast= instance:addInternalStream(0, 0);
        RawSlow= instance:addInternalStream(0, 0);
		Fast= instance:addInternalStream(0, 0);
        Slow= instance:addInternalStream(0, 0);
        MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.Color, source:first());
		MACD:setWidth(instance.parameters.Width);
        MACD:setStyle(instance.parameters.Style);
		MACD:setPrecision (source:getPrecision());
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


 
	 
	local P1= core.findDate (source, source:date(period)-Second*DurationOfFast , false);
	local P2= core.findDate (source, source:date(period)-Second*DurationOfSlow, false);
	
	if P1==-1 or P2==-1 
	or P1< first or P2< first
    then
    return;
    end
	
        RawFast[period] = mathex.avg(source[Price],P1, period);
        RawSlow[period]  = mathex.avg(source[Price],P2, period);
		
 
	local FastMA,SlowMA;
		
		FastMA= mathex.avg(RawFast,P1, period);
		SlowMA=  mathex.avg( RawSlow, P2, period);
		
        Fast[period]= RawFast[period] + RawFast[period] - FastMA;
        Slow[period]= RawSlow[period] + RawSlow[period] - SlowMA;
	 	MACD[period]= Fast[period]-Slow[period];
 
		
		
	 
end
 