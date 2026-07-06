-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64810
-- Id: 18483

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Moving Average Stochastic");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MASml", "Fast Period", "Period", 12);
	indicator.parameters:addInteger("MALrg", "Slow Period", "Period", 26);
    indicator.parameters:addInteger("Periods", "Periods", "Periods", 19);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of MAS", "Color of MAS", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	    indicator.parameters:addColor("color2", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MASml,MALrg,Periods;

local first;
local source = nil;

-- Streams block
local EMA1, EMA2,MAS,Signal;
-- Routine
function Prepare(nameOnly)
    
    MASml = instance.parameters.MASml;
	MALrg = instance.parameters.MALrg;
	Periods = instance.parameters.Periods;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(MASml) .. ", " .. tostring(MALrg) .. ", " .. tostring(Periods) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	EMA1= core.indicators:create("EMA", source, MASml);
	EMA2= core.indicators:create("EMA", source, MALrg);
	first = math.max( EMA1.DATA:first(), EMA2.DATA:first())+Periods;
	
	 
	--SM  = instance:addInternalStream(0, 0);

    if (not (nameOnly)) then
        MAS = instance:addStream("MAS", core.Line, name, "MAS", instance.parameters.color1, first);
    MAS:setPrecision(math.max(2, instance.source:getPrecision()));
		MAS:setWidth(instance.parameters.width1);
        MAS:setStyle(instance.parameters.style1);
		
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

     
    EMA1:update(mode); 
	EMA2:update(mode);
	
    if period <first then
    return;
    end
	
	local min,max=mathex.minmax(EMA2.DATA, period-Periods+1, period)
  
   MAS[period] = ((EMA2.DATA[period]-min)/(max-min))*100;
  Signal[period] = ((EMA1.DATA[period]-min)/(max-min))*100;
	 
	 
    
end


--[[ 
 
((Mov(C,MALrg,E)-LLV(Mov(C,MALrg,E),Periods))/(HHV(Mov(C,MALrg,E),Periods)-LLV(Mov(C,MALrg,E),Periods)))*100;
 
((Mov(C,MASml,E)-LLV(Mov(C,MALrg,E),Periods))/(HHV(Mov(C,MALrg,E),Periods)-LLV(Mov(C,MALrg,E),Periods)))*100;
]]
