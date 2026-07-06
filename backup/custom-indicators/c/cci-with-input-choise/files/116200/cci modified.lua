-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65394


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


-- The indicator corresponds to the Commodity Channel Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 8 "Sycle Analisis" (page 209-210)

-- Indicator profile initialization routine
function Init()
    indicator:name("CCI modified ");
    indicator:description("cci can select type of calculation ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "number of periods ", "number of periods", 20, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI", "line color ", "line color", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthCCI", "line width ","line width",  1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "line style ","line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);
     indicator.parameters:addInteger("overbought", "overbought level ", "overbought level", 100, -1000, 1000);
    indicator.parameters:addInteger("oversold", " oversold level ","oversold level", -100, -1000, 1000);
    indicator.parameters:addColor("level_overboughtsold_color", "color of overboughtsold ", "color of overboughtsold ", core.rgb(255, 255, 0));

    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local first;
local source = nil;
local tp = nil;
local CCI = nil;

-- Routine
function Prepare(nameOnly)   
    n = instance.parameters.N;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    first = source:first() + n - 1;
    CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.clrCCI, first);
    CCI:setWidth(instance.parameters.widthCCI);
    CCI:setStyle(instance.parameters.styleCCI);
    CCI:setPrecision(2);

    CCI:addLevel(instance.parameters.oversold,1,1,instance.parameters.level_overboughtsold_color);
    CCI:addLevel(0);
    CCI:addLevel(instance.parameters.overbought,1,1,instance.parameters.level_overboughtsold_color);

   
end 



function Update(period)
    if period >= first then
        local from = period - n + 1;
        local to = period;
        local mean = mathex.avg(source, from, to);
        local meandev = mathex.meandev(source, from, to);
        		
        if (meandev == 0) then
            CCI[period] = 0;
        else
            CCI[period] = (source[period] - mean) / (meandev * 0.015);
        end
    end
end
