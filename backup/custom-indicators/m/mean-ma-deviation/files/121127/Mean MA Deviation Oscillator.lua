-- Id: 22281
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66644

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

function Init()
    indicator:name("Mean MA Deviation Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 14 );
    indicator.parameters:addDouble("Multiplier1", "Multiplier", "", 1 );
 
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1 , Period1,Multiplier1;
 
local first;
local source = nil;
 
local Top,Bottom;  
local Indicator;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1;
    Multiplier1= instance.parameters.Multiplier1;	
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    Indicator = core.indicators:create(Method1, source.close , Period1); 
    first= Indicator.DATA:first() ;
	
	 
   
 
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first+Period1);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first+Period1);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator:update(mode);
 
	
	
    if period < first+Period1 then
	return;
	end
	
	
	 local stdev= mathex.stdev(Indicator.DATA, period-Period1+1, period)
     Top[period]= Indicator.DATA[period]+Multiplier1*stdev-source.high[period];
	 Bottom[period]= source.low[period]-Indicator.DATA[period]-Multiplier1*stdev;
				  
end

--[[
HDev = average[MAPeriod](close)+1*STD[MAPeriod](average[MAPeriod](close))
LDev = average[MAPeriod](close)-1*STD[MAPeriod](average[MAPeriod](close))
 
Return HDev-high coloured(255,0,0) AS "Hdev", low-LDev coloured(0,255,0) AS "Ldev", 0 coloured(0,0,0) AS "0"
]]

