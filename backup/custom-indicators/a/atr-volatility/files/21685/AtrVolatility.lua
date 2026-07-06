-- Id: 5414
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10451

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
    indicator:name("AtrVolatility");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATRP", "ATR Period", "ATR Period", 12);  
	
	indicator.parameters:addGroup("Levels");
	indicator.parameters:addDouble("Up", "High Volatility Level (Pip/%)", "", 20);
	indicator.parameters:addDouble("Down", "Low Volatility Level (Pip/%)", "", 20);
	
	 indicator.parameters:addString("Type", "Pip/%", "", "Pip");
    indicator.parameters:addStringAlternative("Type", "Pip", "", "Pip");
    indicator.parameters:addStringAlternative("Type", "%", "", "%");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color for High Volatility", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DOWN", "Color for Low Volatility", "", core.rgb(255, 0, 0));
	  indicator.parameters:addColor("NO", "Color for Moderate Volatility", "", core.rgb(255, 128, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ATRP;
local Up, Down;

local ATR;
local Type;
local first;
local source = nil;

-- Streams block
local OUT=nil;

-- Routine
function Prepare(nameOnly)
    Type = instance.parameters.Type;
    ATRP = instance.parameters.ATRP;
    Up = instance.parameters.Up;	
	Down = instance.parameters.Down;
    source = instance.source;
	
	UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;
	NO = instance.parameters.NO;    
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. ATRP .. ", " .. Up.. ", " .. Down ..")";
	instance:name(name);
	if nameOnly then
		return;
	end
	ATR=core.indicators:create("ATR", source, ATRP );
	
	first =  ATR.DATA:first() ;
    OUT = instance:addStream("TREND", core.Bar, name, "TREND", NO, first);
	 OUT:addLevel(1, core.LINE_NONE, 1, core.rgb(0, 0 , 0));
    OUT:addLevel(0, core.LINE_NONE, 1, core.rgb(0, 0 , 0));
	
	OUT:setPrecision(math.max(2, instance.source:getPrecision()));
	

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first  then
	OUT[period]= 0;	
	return;
	end
	
	if period < source:size()-1 then
	return;
	end
	
	 ATR:update(mode);
	
	local min, max;	
	min, max = mathex.minmax (ATR.DATA, first, source:size()-1)
	 
	local i;
    
    for i = first , source:size()-1, 1 do	
	period =i; 
	 
    OUT[period]= 1;

	local Top, Bottom;
	
	if Type== "Pip" then
	Top= Up* source:pipSize();
	Bottom= Down* source:pipSize();
	else
	local Percentage = (max-min) /100;
	Top= min +  Percentage * Up  ;
	Bottom= min +  Percentage * Down;
	
	end
		
		
		 if ATR.DATA[period] > Top then
		 OUT:setColor(period, UP);	
		 elseif ATR.DATA[period] <   Bottom then
		 OUT:setColor(period, DOWN);
		 else
		 OUT:setColor(period, NO);
		 end
		
	end	 
   
end

