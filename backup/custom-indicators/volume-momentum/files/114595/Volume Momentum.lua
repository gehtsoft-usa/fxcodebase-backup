-- Id: 18956

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65047

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
    indicator:name("Volume Momentum");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("MA_Period", "MA Period", "Period", 14);
	indicator.parameters:addString("MA_Method", "MA_MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Momentum_Period", "Momentum_Period", "Period", 14);
	
	indicator.parameters:addBoolean("Multiply", "Multiply the volume?", "", true);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(0, 0, 255));
	 
	
end
 
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Momentum_Period;
local MA_Period;
local MA_Method;
local MA;
local Multiply;

local first;
local source = nil;
-- Streams block
local Volume_Momentum = nil;

-- Routine
function Prepare(nameOnly)

	Momentum_Period= instance.parameters.Momentum_Period;
	MA_Period= instance.parameters.MA_Period;
	MA_Method= instance.parameters.MA_Method;
	Multiply= instance.parameters. Multiply;
	
    source = instance.source;
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Momentum_Period) .. ", " .. tostring(MA_Period) .. ", " .. tostring(MA_Method).. ")";
    instance:name(name);
    
	if   (nameOnly) then
        return;
    end
	
 
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
		MA= core.indicators:create(MA_Method, source.volume , MA_Period);
	    first=MA.DATA:first()+Momentum_Period;
		
        Volume_Momentum = instance:addStream("Volume_Momentum", core.Bar, name .. ".Volume_Momentum", "Volume_Momentum", instance.parameters.Neutral, first);		 
		Volume_Momentum:addLevel(0);
	 
		Volume_Momentum:setPrecision(math.max(2, instance.source:getPrecision()));
   
	
 
end


 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

 
		
		if period < MA.DATA:first()  then
		return;
		end
			
		MA:update(mode);
		
      	
		if period < first  then
		return;
		end
		
		if Multiply then
        Volume_Momentum[period] = (MA.DATA[period]- MA.DATA[period-Momentum_Period+1])*source.volume[period];
        else
		Volume_Momentum[period] = MA.DATA[period]- MA.DATA[period-Momentum_Period+1];
		end
		
		
		if Volume_Momentum[period] > Volume_Momentum[period-1] then
		Volume_Momentum:setColor(period, instance.parameters.Up);
        elseif Volume_Momentum[period] < Volume_Momentum[period-1] then
		Volume_Momentum:setColor(period, instance.parameters.Down);
		else
		Volume_Momentum:setColor(period, instance.parameters.Neutral);
        end
		
    
end 

 