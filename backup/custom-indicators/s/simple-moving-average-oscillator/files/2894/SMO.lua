-- Id: 1022

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1479

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Simple Moving Average Oscillator");
    indicator:description("Simple Moving Average Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
--////////////////////////////////////////////////////////////////////
    indicator.parameters:addInteger("Frame", "Period", "Period", 20,2,2000);
--/////////////////////////////////////////////////////////////////////	
       indicator.parameters:addColor("UP", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
	    indicator.parameters:addColor("DOWN", "Color of  DOWN", "Color of DOWN", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
--////////////
local Frame;
--////////////

local first;
local source = nil;

-- Streams block
local  S1 = nil;
local  S2 = nil;
--/////////////
local MVA=nil;
--/////////////

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
    source = instance.source;
  

	--//////////////////////////////////////////////////////
	MVA= core.indicators:create("MVA", source, Frame);
	 first = MVA.DATA:first();
	--/////////////////////////////////////////////////////
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    S1 = instance:addStream("S1", core.Bar, name, "Up", instance.parameters.UP, first);
	S2 = instance:addStream("S2", core.Bar, name, "Down", instance.parameters.DOWN, first);
	S1:setPrecision(math.max(2, instance.source:getPrecision())); 
	S2:setPrecision(math.max(2, instance.source:getPrecision())); 
	S1:addLevel(0);   
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
  -- make sure you add mode i (period)  like in this line above
    if period < first or not source:hasData(period) then
	return;
	end
	
	--///////////////////////
	 MVA:update(mode);
	 --//////////////////////
	
	if source[period] > MVA.DATA[period] then
	 S1[period] = 1;	
	end
	
	if source[period] < MVA.DATA[period]  then
	  S2[period] = 1;	 
	end
      
     
end