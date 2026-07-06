-- Id: 14187
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62217

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Slow RSI ");
    indicator:description("Slow RSI ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addInteger("Smoothing", "Smoothing Period", "Smoothing Period", 6);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RSI_color", "Color of RSI", "Color of RSI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
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
local Period;
local Smoothing;

local first;
local source = nil;
local EMA;
-- Streams block
local RSI = nil;
local pos, neg;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Smoothing = instance.parameters.Smoothing;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Smoothing) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        EMA = core.indicators:create("EMA", source, Smoothing)
         
        first = source:first()+Period+Smoothing;
        pos = instance:addInternalStream(0, 0);
        neg = instance:addInternalStream(0, 0);
        RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.RSI_color, first);		
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
		RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	    RSI:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    		
		RSI:setWidth(instance.parameters.width);
        RSI:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
 

    EMA:update(mode);

    if period < first or not source:hasData(period) then
	return;
	end
 
	
	    local i = 0;
        local sump = 0;
        local sumn = 0;
        local positive = 0;
        local negative = 0;
   
            if  source[period] > EMA.DATA[period]  then 
                sump = source[period]- EMA.DATA[period];
            elseif source[period] < EMA.DATA[period]  then
                sumn = EMA.DATA[period]- source[period];
			else
			    sumn = 0;
            end
            positive = (pos[period - 1] * (Period - 1) + sump) / Period;
            negative = (neg[period - 1] * (Period - 1) + sumn) / Period;
       
        pos[period] = positive;
        neg[period] = negative;
        if (negative == 0) then
            RSI[period] = 100;
        else
            RSI[period] = 100 - (100 / (1 + positive / negative));
        end
		
		
      
end

