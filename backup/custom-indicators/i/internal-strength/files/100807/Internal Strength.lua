-- Id: 14274

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62295

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
    indicator:name("Internal Strength");
    indicator:description("Internal Strength");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 

	
    indicator.parameters:addInteger("Period", "RSI Period", "Period", 14);
	
		
	indicator.parameters:addString("Method", "Method", "Method" , "RSI");
    indicator.parameters:addStringAlternative("Method", "Raw", "Raw" , "Raw");
	indicator.parameters:addStringAlternative("Method", "RSI", "RSI" , "RSI");
	
    indicator.parameters:addString("Type", "Type", "Type" , "Line");
    indicator.parameters:addStringAlternative("Type", "Line", "Line" , "Line");
	indicator.parameters:addStringAlternative("Type", "Bar", "Bar" , "Bar");	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of Raw Line", "Color of Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Color of RSI Line", "Color of Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 55);
    indicator.parameters:addDouble("oversold","Oversold Level","", 45);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period; 
local first;
local source = nil;
 -- Streams block
local Raw;
local Method;
local rsi;
local Type;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period; 
	Method= instance.parameters.Method;
	Type= instance.parameters.Type;
    source = instance.source;
    first = source:first();
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	 
		
		if Method ~= "RSI" then	
		    if Type == "Line" then
			Raw = instance:addStream("Raw", core.Line, name .. ".Raw", "Raw", instance.parameters.color1, first);
    		Raw:setWidth(instance.parameters.width1);
			Raw:setStyle(instance.parameters.style1);
			else
			Raw = instance:addStream("Raw", core.Bar, name .. ".Raw", "Raw", instance.parameters.color1, first);
			end
			
			Raw:setPrecision(math.max(2, instance.source:getPrecision()));
			Raw:addLevel(instance.parameters.oversold/100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		    Raw:addLevel(instance.parameters.overbought/100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
			
			
		else
		    Raw = instance:addInternalStream(first, 0);
		end
		
		rsi = core.indicators:create("RSI", Raw, Period);
		
		if Method ~= "Raw" then			
			 if Type == "Line" then
			RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.color2, rsi.DATA:first());
			RSI:setWidth(instance.parameters.width2);
			RSI:setStyle(instance.parameters.style2);
			else
			RSI = instance:addStream("RSI", core.Bar, name .. ".RSI", "RSI", instance.parameters.color2, rsi.DATA:first());
			end
		else		
		RSI = instance:addInternalStream(rsi.DATA:first(), 0);
		end
		
		RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
        RSI:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
  
   
	
	
	Raw[period]=(source.close[period]-source.low[period]) / (source.high[period] -source.low[period]);
	
	rsi:update(mode);
	
	
	if period < first or not source:hasData(period) then
	return;
	end

    RSI[period]= rsi.DATA[period];
end

