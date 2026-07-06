-- Id: 24884
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68405

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("OnChart MFI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("MFI_Period", "MFI Period", "", 14, 2, 2000);
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 2);

	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
 
    indicator.parameters:addDouble("OverBought", "OverBought", "", 80);
	indicator.parameters:addDouble("OverSold", "OverSold", "", 20);
 
 
	
	indicator.parameters:addGroup("Central Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Top Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("Bottom Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("MFI Line Style"); 	
    indicator.parameters:addColor("color4", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Period,MFI_Period;
local Multiplier;
local first;
local source = nil;
 
local Top,Bottom, Central,Value;  
local MA,ATR,MFI;

local OverBought, OverSold;

-- Routine
 function Prepare(nameOnly)   
 
 
    OverBought= instance.parameters.OverBought;
	OverSold= instance.parameters.OverSold;
 
    Multiplier= instance.parameters.Multiplier;
 
    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
	
	MFI_Period= instance.parameters.MFI_Period;

	
	
	local Parameters= Period ..  ", " .. Method ..  ", " .. MFI_Period..  ", " .. Multiplier;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 
   

    if   (nameOnly) then
        return;
    end

   assert(core.indicators:findIndicator("MFI") ~= nil, "Please, download and install MFI.LUA indicator"); 
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, source.close, Period);
	ATR = core.indicators:create("ATR", source, Period);
    MFI = core.indicators:create("MFI", source, Period);
    first=math.max(MA.DATA:first(),MFI.DATA:first());
	
	 
   
 
	Central = instance:addStream("Central" , core.Line, "Central","Central",instance.parameters.color1, first);
	Central:setWidth(instance.parameters.width1);
    Central:setStyle(instance.parameters.style1);
    Central:setPrecision(math.max(2, source:getPrecision()));
	
	Top = instance:addStream("Top" , core.Line, "Top","Top",instance.parameters.color2, first);
	Top:setWidth(instance.parameters.width2);
    Top:setStyle(instance.parameters.style2);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	
	Bottom = instance:addStream("Bottom" , core.Line, "Bottom","Bottom",instance.parameters.color3, first);
	Bottom:setWidth(instance.parameters.width3);
    Bottom:setStyle(instance.parameters.style3);
    Bottom:setPrecision(math.max(2, source:getPrecision()));
	
	Value = instance:addStream("Value" , core.Line, "Value","Value",instance.parameters.color4, first);
	Value:setWidth(instance.parameters.width4);
    Value:setStyle(instance.parameters.style4);
    Value:setPrecision(math.max(2, source:getPrecision()));
	
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA:update(mode);
	ATR:update(mode);
	MFI:update(mode);
	
	
    if period < first then
	return;
	end
	
		
     Central[period]=MA.DATA[period];
	 Top[period]=MA.DATA[period]+(ATR.DATA[period]*Multiplier*(OverBought-50)/100);
	 Bottom[period]=MA.DATA[period]-(ATR.DATA[period]*Multiplier*(50-OverSold)/100);
	 Value[period]= MA.DATA[period]+(ATR.DATA[period]*Multiplier*(MFI.DATA[period]-50)/100);
 
       
end

