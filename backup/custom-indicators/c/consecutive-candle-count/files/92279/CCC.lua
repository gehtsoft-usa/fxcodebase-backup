-- Id: 11003


-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60243

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
    indicator:name("Consecutive Candle Count");
    indicator:description("Consecutive Candle Count");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");	 
	indicator.parameters:addString("Method", "Source", "Source" , "Chart");
    indicator.parameters:addStringAlternative("Method", "Heiken-Ashi", "Heiken-Ashi" , "Heiken-Ashi");
    indicator.parameters:addStringAlternative("Method", "Chart", "Chart" , "Chart");
	
    indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("Up", "Color of Up Count", "Color of Count", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down Count", "Color of Count", core.rgb(255, 0, 0));  
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 9);
    indicator.parameters:addDouble("oversold","Oversold Level","", -9);
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

local first;
local source, Source;
local Method;
-- Streams block
local Count = nil;

-- Routine
function Prepare(nameOnly)

    source = instance.source;		
	Method = instance.parameters.Method;
    
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Method.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	if Method~= "Chart" then
	Source=  core.indicators:create("HA", source);
	first = Source.DATA:first();
	else
	Source= source;
	first = source:first();	
	end
	


    

     
        Count = instance:addStream("Count", core.Bar, name, "Count", instance.parameters.Up, first);
		Count:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Count:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
		
		Count:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    if Method~= "Chart" then 
    Source:update(mode);	
	end
	
    if period < first or not Source.close:hasData(period) then
	return;
	end
	
	if Count[period-1] > 0 and Source.close[period]>= Source.open[period] then
	Count[period]=Count[period-1]+1;
	elseif Count[period-1] < 0 and Source.close[period]<= Source.open[period] then
	Count[period]=Count[period-1]-1;
	elseif  Source.close[period]> Source.open[period]  then
	Count[period]=1;
	elseif  Source.close[period]< Source.open[period]  then
	Count[period]=-1;
	end
	
	 
    if Count[period]> 0 then
	Count:setColor(period, instance.parameters.Up);
	else
	Count:setColor(period, instance.parameters.Down);
	end
end

