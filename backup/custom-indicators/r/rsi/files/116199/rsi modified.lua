-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65393

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

-- The indicator corresponds to the Relative Strength Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 133-134)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("RSI without 0 and 100 levels ");
    indicator:description("RSI without 0 and 100 levels ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "number of periods ","number of periods ", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrRSI", "line color","line color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthRSI", "line width","line width", 1, 1, 5);
    indicator.parameters:addInteger("styleRSI"," line style "," line style ", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRSI", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addDouble("overbought","overbought level", "overbought level  ", 70, 0, 100);
    indicator.parameters:addDouble("oversold", "oversold level ", "oversold level ", 30, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width","width of overboughtsold ", "width of overboughtsold ", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", " styl of overboughtsold","styl of overboughtsold",core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "color of overboughtsold ","color of overboughtsold", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;

local first;
local source = nil;
local pos = nil;
local neg = nil;

-- Streams block
local RSI = nil;

-- Routine
function Prepare(nameOnly)
    

    n = instance.parameters.N;
    source = instance.source;
    first = source:first() + n;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    pos = instance:addInternalStream(0, 0);
    neg = instance:addInternalStream(0, 0);

    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.clrRSI, first);
    RSI:setWidth(instance.parameters.widthRSI);
    RSI:setStyle(instance.parameters.styleRSI);
    RSI:setPrecision(2);
    
   
    RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RSI:addLevel(50);
    RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
   
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local i = 0;
        local sump = 0;
        local sumn = 0;
        local positive = 0;
        local negative = 0;
        local diff = 0;
        if (period == first) then
            for i = period - n + 1, period do
                diff = source[i] - source[i - 1];
                if (diff >= 0) then
                    sump = sump + diff;
                else
                    sumn = sumn - diff;
                end
            end
            positive = sump / n;
            negative = sumn / n;
        else
            diff = source[period] - source[period - 1];
            if (diff > 0) then 
                sump = diff;
            else
                sumn = -diff;
            end
           positive = (pos[period - 1] * (n - 1) + sump) / n;
            negative = (neg[period - 1] * (n - 1) + sumn) / n;
        end
        pos[period] = positive;
        neg[period] = negative;
        if (negative == 0) then
            RSI[period] = 0;
        else
            RSI[period] = 100 - (100 / (1 + positive / negative));
        end
    end
end