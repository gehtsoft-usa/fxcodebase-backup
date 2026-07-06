-- Id: 2900
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3176

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
    indicator:name("Smoothie");
    indicator:description("Smoothie");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addInteger("F", "Averege Period", "Averege  Period", 20);
	indicator.parameters:addInteger("Number", "Number of repetitions", "", 1, 1 , 1000);
	indicator.parameters:addInteger("Shift", "Shift Backwards", "", 0 , 0 , 1000);
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addBoolean("Show", "Show only Last", "" , true); 
   
    indicator.parameters:addColor("S1_color", "Color of S1", "Color of S1", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame=nil;
local Method=nil;
local Number
local Count;

local first;
local source = nil;

-- Streams block
local DATA = {};
local indicator;
local Smoothie= {};
local Output={};
local Show;
local Shift=nil;

-- Routine
function Prepare(nameOnly)
    Shift= instance.parameters.Shift;
    Show = instance.parameters.Show;
    Number = instance.parameters.Number;
	Frame = instance.parameters.F;
	Method = instance.parameters.Method;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " ..Method ..", " .. Frame..", " .. Number .. ", ".. Shift.. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	local i=1;
	

	if Number == 1 then
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	                Smoothie[i]= core.indicators:create(Method, source , Frame);
					Output[i] = instance:addStream("OUT"..i, core.Line, name, Method .. i , instance.parameters.S1_color, Smoothie[i].DATA:first());
	
	else
			        for i = 1, Number, 1 do						
					   if i == 1 then
					      Smoothie[i]= core.indicators:create(Method, source , Frame);
						  if not Show  then 
					      Output[i] = instance:addStream("OUT"..i, core.Line, name, Method .. i , instance.parameters.S1_color, Smoothie[i].DATA:first()); 
						  end
                       else	
					    Smoothie[i]= core.indicators:create(Method, Smoothie[i-1].DATA , Frame);
						if not Show or i == Number  then
						Output[i] = instance:addStream("OUT"..i, core.Line, name, Method .. i, instance.parameters.S1_color, Smoothie[i].DATA:first());
						end
					   end 
					end
	end
	
	
	        
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)	
	local i;
	
	for i = 1, Number, 1 do
	Smoothie[i]:update(mode);
	end
	
	
			
			for i = 1, Number, 1 do
			
					if not Show or i == Number  then
					
					
							  if Shift ~= 0 then
									if period < Shift then
									return;
									end
								end
								
					
							if Smoothie[i].DATA:hasData(period)  then
							Output[i][period-Shift] =  Smoothie[i].DATA[period];
							else
							Output[i][period-Shift]= nil;
							end
					end
			
			end
	
end

