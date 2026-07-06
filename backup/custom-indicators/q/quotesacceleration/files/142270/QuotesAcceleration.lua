-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71227

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
    indicator:name("QuotesAcceleration");
    indicator:description("QuotesAcceleration");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("up", "Color of Acceleration", "Color of Acceleration", core.rgb(0, 255, 0));
    indicator.parameters:addColor("down", "Color of Acceleration", "Color of Acceleration", core.rgb(255, 0, 0)); 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first; 
local source = nil; 
local QuotesAcceleration ;
-- Routine
function Prepare(nameOnly)
 
    source = instance.source;
    first=source:first();
	
	
	local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
	
	   assert (source:barSize()=="t1", "The chosen time frame must be t1!");
 
	 
        QuotesAcceleration = instance:addStream("QuotesAcceleration", core.Line, name .. ".QuotesAcceleration", "QuotesAcceleration", instance.parameters.up, source:first()); 
		QuotesAcceleration:setPrecision (source:getPrecision());
		
 
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

     if period== first then	 
	 QuotesAcceleration[period]=0; 
	 end
	 
 
		 if (source:date(period)-source:date(period-1)) > (source:date(period-1)-source:date(period-2)) then
		 QuotesAcceleration[period]=QuotesAcceleration[period-1]+1;
		 else
		 QuotesAcceleration[period]=QuotesAcceleration[period-1]-1;
		 end
	 
 
end
 