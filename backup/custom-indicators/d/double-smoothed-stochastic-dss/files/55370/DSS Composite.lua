-- Id: 8590

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1855

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
    indicator:name("DSS Composite");
    indicator:description("DSS Composite");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);     
    	
    Add (1 ,200,50,50,100, true);
	Add (2 ,100,25,25,50, true);
	Add (3 ,50,12,12,25, true);
	Add (4 ,200,50,50,100, false);
	Add (5 ,200,50,50,100, false);	
	
	indicator.parameters:addGroup("Signal Calculation");	
	indicator.parameters:addInteger("SignalFrame", "Signal Period", "Signal Period", 8);	
	indicator.parameters:addString("Method", "Signal MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Stochastic_color", "Color of Stochastic", "Color of Stochastic", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addInteger("overbought", "Overbought Level","", 80);
    indicator.parameters:addInteger("oversold","Oversold Level","", 20);
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

function Add(id, L1, L2,L3,L4, Flag)   
   
    indicator.parameters:addGroup(id .. ". DSS");	
	indicator.parameters:addDouble("Coef"..id, "Percentage", " ", L4); 
	indicator.parameters:addBoolean("On"..id , "Use This DSS", "", Flag);	
	indicator.parameters:addInteger("Frame"..id, "Stochastic Period", "Stochastic Period", L1);	
    indicator.parameters:addInteger("EMAFrame1"..id, "1. Smooth Period", "Smooth Period", L2);
	indicator.parameters:addString("Method1"..id, "1. Smooth  MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1"..id, "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("EMAFrame2"..id, "2. Smooth Period", "Smooth Period", L3);
	indicator.parameters:addString("Method2"..id, "2. Smooth  MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2"..id, "WMA", "WMA" , "WMA");
		
end


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local On={};
local Frame={};
local EMAFrame1={};
local EMAFrame2={};
local SignalFrame;
local Method;
local Method1={};
local Method2={};
local first;
local source = nil;

-- Streams block
local DSS= {};
local dss; 
local Signal=nil;
local MA;
local Coef={};
-- Routine
function Prepare(nameOnly) 
    
	SignalFrame = instance.parameters.SignalFrame;
	Method = instance.parameters.Method;
	
	source = instance.source;
    first = source:first();
			
    local name = profile:id() .. "(" .. source:name() ..  ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
   		assert(core.indicators:findIndicator("DSS WITH AVERAGES") ~= nil, "Please, download and install DSS WITH AVERAGES.LUA indicator");
		
	local i;
	for i= 1, 5 ,1 do
	On[i] = instance.parameters:getBoolean("On" .. i);
	if On[i] then
	Method1[i] = instance.parameters:getString("Method1" .. i);
	Method2[i] = instance.parameters:getString("Method2" .. i);
	Coef[i] = instance.parameters:getDouble("Coef" .. i);
	Frame[i] = instance.parameters:getInteger("Frame" .. i);
    EMAFrame1[i] = instance.parameters:getInteger("EMAFrame1" .. i);
	EMAFrame2[i] = instance.parameters:getInteger("EMAFrame2" .. i);
	
	DSS[i]  = core.indicators:create("DSS WITH AVERAGES", source, Frame[i],EMAFrame1[i], Method1[i],EMAFrame2[i], Method1[i] );
	 first = math.max(DSS[i].DATA:first(), first);
	 end
	end
	
	dss = instance:addStream("DSS", core.Line, name .. ".DSS", "DSS", instance.parameters.Stochastic_color, first);	
    dss:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    dss:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	dss:setWidth(instance.parameters.width);
    dss:setStyle(instance.parameters.style);
	 
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, dss, SignalFrame );
    Signal = instance:addStream("SIGNAL", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, MA.DATA:first());
	Signal:setWidth(instance.parameters.width1);
    Signal:setStyle(instance.parameters.style1);
	
	dss:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    local i;
	
	local Sum=0;
	for i = 1, 5 , 1 do
		if On[i] then
		DSS[i]:update(mode);		
		Sum=Sum+(DSS[i].DATA[period]/100)*Coef[i];
		end
	end
	
	
	
	 if period < first then
	return;
	end
	
	dss[period]=Sum;	
 	MA:update(mode);
   
	 if period < MA.DATA:first()  then
	return;
	end
	
	Signal[period] = MA.DATA[period];
							
end
	


