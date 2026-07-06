-- Id: 16269

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63612

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
    indicator:name("RSI Rendiment");
    indicator:description("RSI Rendiment");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("RSI Calculation");
	indicator.parameters:addInteger("RPeriod", "Period", "Period",14 );
	
	indicator.parameters:addGroup("Quantitative Return Oscillator Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 5);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 1);
	indicator.parameters:addBoolean("Normalized", "Normalized", "", true);
	---Normalized volume
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
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

local Normalized;
local first;
local source = nil;
local RR;
local Period;
local Multiplier;
local RPeriod;
local RSI;
local Raw;
-- Routine
function Prepare(nameOnly)   
   
    source = instance.source;
    Normalized=instance.parameters.Normalized;
	Period=instance.parameters.Period;
	Multiplier=instance.parameters.Multiplier;
	RPeriod=instance.parameters.RPeriod;
	
	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end
	
	RSI = core.indicators:create("RSI", source, RPeriod);
	first = math.max( source:first()+Period, RSI.DATA:first());
	Raw= instance:addInternalStream(0, 0);
	
	
			RR= instance:addStream("RR", core.Line, name .. ".RR", "RR",  instance.parameters.Up_color, source:first());	 
            RR:setWidth(instance.parameters.width);
            RR:setStyle(instance.parameters.style); 	
            RR:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		    RR:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);     			
            RR:setPrecision(math.max(2, instance.source:getPrecision()));
end
 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    RSI:update(mode);

    if period < first or not source:hasData(period) then
	return;
	end  
	 	
   Raw[period]= Multiplier * math.log (source[period]/source[period-Period+1]); 
   
   local Rendiment;
   local min, max;
   if Normalized then
		min,max=mathex.minmax(Raw, period-Period+1, period);
		Rendiment =( ((Raw[period] - min)/ (max-min))*100); 	 
   else
   Rendiment=Raw[period];
   end
   
   RR[period]= ( RSI.DATA[period] +   Rendiment  ) / 2 
    
   if RR[period] > RR[period-1] then
   RR:setColor(period,  instance.parameters.Up_color);   
   else
   RR:setColor(period,  instance.parameters.Down_color);
   end
   
    
end 