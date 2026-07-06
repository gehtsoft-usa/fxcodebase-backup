-- Id: 14913
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62770

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
    indicator:name("Smoothed Momentum");
    indicator:description("Smoothed Momentum");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MP", "Momentum Period", "Momentum Period", 12);
    indicator.parameters:addString("MS", "Momentum smoothing method", "Momentum smoothing method", "MVA");
	indicator.parameters:addStringAlternative("MS", "No smoothing", "", "NO");
    indicator.parameters:addStringAlternative("MS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MS", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MS", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MS", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MS", "Wilders", "", "WMA");
    indicator.parameters:addInteger("MSP", "Momentum Smoothing Period", "Momentum Smoothing Period", 20);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Momentum_color", "Color of Momentum", "Color of Momentum", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MP;
local MS;
local MSP;

local first;
local source = nil;

-- Streams block
local Momentum;
local iMomentum;
local M;
-- Routine
function Prepare(nameOnly)
    MP = instance.parameters.MP;
    MS = instance.parameters.MS;
    MSP = instance.parameters.MSP;
    source = instance.source;
    first = source:first()+MP ;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(MP) .. ", " .. tostring(MS) .. ", " .. tostring(MSP) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        iMomentum=instance:addInternalStream (0, 0); 
        
         if MS ~= "NO" then	 
          M = core.indicators:create( MS, iMomentum, MSP);  
          ifirst=M.DATA:first()+MP;
         else
          ifirst=first;
         end
        Momentum = instance:addStream("Momentum", core.Line, name, "Momentum", instance.parameters.Momentum_color, ifirst);
    Momentum:setPrecision(math.max(2, instance.source:getPrecision()));
		Momentum:setWidth(instance.parameters.width);
        Momentum:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	iMomentum[period]=source[period]*100./source[period-MP];
	
	 if MS ~= "NO" then
	 M:update(mode);
	 Momentum[period]=  M.DATA[period];
	 else
	 Momentum[period]=  iMomentum[period];
	 end
	
 
    
end

