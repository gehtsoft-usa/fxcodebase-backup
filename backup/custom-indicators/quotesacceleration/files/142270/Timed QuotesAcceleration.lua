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
    indicator:name("Timed QuotesAcceleration");
    indicator:description("QuotesAcceleration");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger(  "Time", "Time In Seconds", "Time", 10);
	
	indicator.parameters:addBoolean("Filter", "Filter", "Filter", true);
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
local QuotesAcceleration,QuotesSlowdown ;
local Time;
local Second;
local Filter;
-- Routine
function Prepare(nameOnly)
 
    source = instance.source;
    first=source:first();
	
	Time=instance.parameters.Time;
	Filter=instance.parameters.Filter;
	
	local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
	Second =(1/86400);	
	   assert (source:barSize()=="t1", "The chosen time frame must be t1!");
 
	 
        QuotesAcceleration = instance:addStream("QuotesAcceleration", core.Bar, name .. ".QuotesAcceleration", "QuotesAcceleration", instance.parameters.up, source:first()); 
		QuotesAcceleration:setPrecision (source:getPrecision());
		
        QuotesSlowdown = instance:addStream("QuotesSlowdown", core.Bar, name .. ".QuotesSlowdown", "QuotesSlowdown", instance.parameters.down, source:first()); 
		QuotesSlowdown:setPrecision (source:getPrecision()); 
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

   
	 QuotesAcceleration[period]=0; 
	 
	local P1= core.findDate (source, source:date(period)-Second*Time , false);
 
	
	if P1==-1 
	or P1< first 
    then
    return;
    end
 
 
    for i= P1, period, 1 do
		 if (source:date(i)-source:date(i-1)) > (source:date(i-1)-source:date(i-2)) then
		 QuotesAcceleration[period]=QuotesAcceleration[period]+1; 
		 else
		  QuotesSlowdown[period]=QuotesSlowdown[period]-1; 
		 end
	 end
	 
	 
	 if Filter then
	 
	 if QuotesAcceleration[period] > math.abs( QuotesSlowdown[period]) then
	 QuotesSlowdown[period] =0;
	 end
	 
	  
	 if math.abs( QuotesSlowdown[period])  >QuotesAcceleration[period]  then
	 QuotesAcceleration[period] =0;
	 end
	 
	 end
 
end
 