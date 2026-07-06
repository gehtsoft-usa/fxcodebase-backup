-- Id: 6809
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=280

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
    indicator:name("Keltner Band");
    indicator:description("Keltner");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 35);
    indicator.parameters:addDouble("Percentage", "Percentage", "Percentage", 0.015);
	  indicator.parameters:addString("Type", "The center line smoothing method", "", "MVA");
    indicator.parameters:addStringAlternative("Type", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Type", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Type", "LWMA", "", "LWMA");
	indicator.parameters:addStringAlternative("Type", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Type", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Type", "Wilders", "", "WMA");
	indicator.parameters:addStringAlternative("Type", "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("Type", "VIDYA", "", "VIDYA");
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addBoolean("Show", "Show the center line", "", true);
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("SC", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SC", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("WC", "Line Width", "", 1, 1, 5);
	
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("ST", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("ST", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("WT", "Line Width", "", 1, 1, 5);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("SB", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SB", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("WB", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addGroup("Cloud"); 
	
	indicator.parameters:addBoolean("Cloud", "Show Cloude","", false);
	 indicator.parameters:addColor("UpperCloudClr", "Upper cloud color", "Upper cloud color", core.rgb(128, 255, 255));
    indicator.parameters:addColor("LowerCloudClr", "Lower cloud color", "Lower cloud color", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Percentage;
local Type;
local Cloud;
local first;
local source = nil;
local Show;
-- Streams block
local Central = nil;
local Top = nil;
local Bottom = nil;
local MA;
local CENTRAL;
-- Routine
function Prepare(nameOnly)
     Type = instance.parameters.Type;
	 Show = instance.parameters.Show;
    Period = instance.parameters.Period;
	Cloud = instance.parameters.Cloud;
    Percentage = instance.parameters.Percentage;
    source = instance.source;


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ", " .. tostring(Type) .. ", " .. tostring(Percentage) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator(Type) ~= nil, Type .. " indicator must be installed");
	 MA = core.indicators:create(Type, source, Period);
	 first = MA.DATA:first();

 
	
	    if Cloud then
		Central=instance:addInternalStream (0, 0);
		Top=instance:addInternalStream (0, 0);
		CENTRAL=instance:addInternalStream (0, 0);
		Bottom=instance:addInternalStream (0, 0);	
		
		      if Show then
			 instance:createChannelGroup("UpperGroup","Upper" , Central, Top, instance.parameters.UpperCloudClr, 100-instance.parameters.Transparency);
			 instance:createChannelGroup("LowerGroup","Lower" , CENTRAL, Bottom, instance.parameters.LowerCloudClr, 100-instance.parameters.Transparency);
			else
			 instance:createChannelGroup("Band","Band" , Top, Bottom, instance.parameters.UpperCloudClr, 100-instance.parameters.Transparency);
			end 
		else	     
				if Show then		
				Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first);
				Central:setStyle(instance.parameters.SC);
				Central:setWidth(instance.parameters.WC);
				else
				Central=instance:addInternalStream (0, 0);
				end
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
		Top:setStyle(instance.parameters.ST);
        Top:setWidth(instance.parameters.WT);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setStyle(instance.parameters.SB);
        Bottom:setWidth(instance.parameters.WB);
		end
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first  or not source:hasData(period) then
	return;
	end
	
	 MA:update(mode);
	
	    if Cloud then
		CENTRAL[period] = MA.DATA[period];
        end
		Central[period] = MA.DATA[period];
		
		
        Top[period]  = MA.DATA[period]+  MA.DATA[period]*Percentage;
        Bottom[period] = MA.DATA[period]-  MA.DATA[period]*Percentage;
   
end

