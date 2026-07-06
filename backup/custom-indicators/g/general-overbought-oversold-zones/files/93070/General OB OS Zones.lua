-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60410
-- Id: 11310

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
    indicator:name("General Overbought Oversold Zones");
    indicator:description("Zone Helper Tool");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
   indicator.parameters:addGroup("OB/OS Levels");	
   indicator.parameters:addDouble("Top", "Top Level","", 100);
    indicator.parameters:addDouble("OB", "Overbought Level","", 80);
    indicator.parameters:addDouble("OS","Oversold Level","", 20);
     indicator.parameters:addDouble("Bottom", "Bottom Level","", 0);
  
 
 
     indicator.parameters:addGroup("Style");
     indicator.parameters:addString("Type", "Type", "", "Line");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
    indicator.parameters:addStringAlternative("Type", "Zone", "", "Zone");
    
    indicator.parameters:addColor("TopColor", "Top Line/Zone Color", "", core.rgb(0, 255, 0));
     indicator.parameters:addColor("BottomColor", "Bottom Line/Zone Color", "", core.rgb(255, 0, 0));     
     
       indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);
	   
	     indicator.parameters:addInteger("width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local Type;
local first;
local source = nil;
local OB,OS;

-- Streams block
local S1 = nil;
local S2 = nil;
 local S3 = nil;
local S4 = nil;
local Top, Bottom;
-- Routine
function Prepare(nameOnly) 
    Price = instance.parameters.Price;
    Top = instance.parameters.Top;
	Bottom = instance.parameters.Bottom;
 
    Type = instance.parameters.Type;	
    OB = instance.parameters.OB;
	OS = instance.parameters.OS;
    source = instance.source;
    first = source:first();
    
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. OB .. ", " .. OS .. ", " .. Type .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    if Type == "Zone" then
    S1  = instance:addStream("OB", core.Line, name .. ".OB", "OB", instance.parameters.TopColor, first);
    S1:setStyle(core.LINE_NONE);
    S2 = instance:addStream("OS", core.Line, name .. ".OS", "OS", instance.parameters.BottomColor, first);
    S2:setStyle(core.LINE_NONE);
	
	
	 S3  = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.TopColor, first);
     S3:setStyle(core.LINE_NONE);
    S4 = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.BottomColor, first);
    S4:setStyle(core.LINE_NONE);	
	
    instance:createChannelGroup ("Zone", "Zone", S1, S3, instance.parameters.TopColor, 100 - instance.parameters.transparency);
	instance:createChannelGroup ("Zone", "Zone", S2, S4, instance.parameters.BottomColor, 100 - instance.parameters.transparency);
    else
 
	 
	S1  = instance:addStream("OB", core.Line, name .. ".OB", "OB", instance.parameters.TopColor, first);
	S1:setWidth(instance.parameters.width);
    S1:setStyle(instance.parameters.style);
    S2 = instance:addStream("OS", core.Line, name .. ".OS", "OS", instance.parameters.BottomColor, first);
	S1:setWidth(instance.parameters.width);
    S1:setStyle(instance.parameters.style);
	
	
	S3  = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.TopColor, first);
	S3:setWidth(instance.parameters.width);
    S3:setStyle(instance.parameters.style);
    S4 = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.BottomColor, first);
	S4:setWidth(instance.parameters.width);
    S4:setStyle(instance.parameters.style);
    end
    S1:setPrecision(math.max(2, instance.source:getPrecision()));
     S2:setPrecision(math.max(2, instance.source:getPrecision()));
     S3:setPrecision(math.max(2, instance.source:getPrecision()));
	S4:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if not source:hasData(period) or  period < source:size()-1 then
    return;
    end
        
    
    core.drawLine(S1, core.range(first, period ), OB, first, OB,  source:size()-1);
	core.drawLine(S2, core.range(first, period), OS, first, OS,  source:size()-1);
   
   core.drawLine(S3, core.range(first, period ), Top, first, Top,  source:size()-1);
   core.drawLine(S4, core.range(first, period), Bottom, first, Bottom,  source:size()-1);
end

