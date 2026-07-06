
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65432

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
function Init()
    indicator:name("Timed Tick Commodity Channel Index");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period Duration in seconds","Duration in seconds", 500,0, 100000000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI", "Line Color","", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthCCI","Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "OB Level","", 100, -1000, 1000);
    indicator.parameters:addInteger("oversold", "OS Level","", -100, -1000, 1000);
    indicator.parameters:addInteger("level_overboughtsold_width","Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style","Line Style","", core.LINE_SOLID);
	  indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(255, 255, 0));
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period;

local first;
local source = nil;
local tp = nil;
 
-- Streams block
local CCI = nil;
local Second; 
-- Routine
function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
     
   
    Period = instance.parameters.Period;	
	
    source = instance.source;
    first = source:first();

    
	
    CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.clrCCI, first);
    CCI:setWidth(instance.parameters.widthCCI);
    CCI:setStyle(instance.parameters.styleCCI);
    CCI:setPrecision(2);

    CCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCI:addLevel(0);
    CCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);

 
    Second=1/86400 ; 
end
 
function Update(period)
    if period < first then
	return;
	end
	
	local PERIOD= core.findDate (source, source:date(period)- Second * Period, false);
	
	if PERIOD==-1
	or PERIOD< first+1 
	or PERIOD>= period
    then
    return;
    end 
	
	
	
         
        local mean = mathex.avg(source, PERIOD, period);
        local meandev = mathex.meandev(source, PERIOD, period);
        		
        if (meandev == 0) then
            CCI[period] = 0;
        else
            CCI[period] = (source[period] - mean) / (meandev * 0.015);
        end
 
end
 