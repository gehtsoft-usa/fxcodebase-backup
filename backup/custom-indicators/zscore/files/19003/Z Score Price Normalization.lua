-- Id: 5145
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=8619

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
    indicator:name("Z Score Price Normalization");
    indicator:description("Z Score Price Normalization");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 20);
	 indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2);
	
	
	indicator.parameters:addGroup("Levels");

    indicator.parameters:addDouble("overbought", "Overbought Level","", 100);
    indicator.parameters:addDouble("oversold", "Oversold Level", "", 0 );
    indicator.parameters:addInteger("level_overboughtsold_width", "Over Bought / Over Sold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Over Bought / Over Sold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Over Bought / Over Sold  Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local source = nil;

-- Streams block
local ZScore = nil;
local TL, BL, AL;
local D;

local open=nil;
local close=nil;
local high=nil;
local low=nil;


-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
	 D = instance.parameters.Dev;
	
	
    first =  source:first()+ PERIOD-1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ", " .. tostring(D).. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	TL = instance:addInternalStream(0,0);
    BL = instance:addInternalStream(0,0);
    AL = instance:addInternalStream(0,0);
	


    if (not (nameOnly)) then	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	open:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    open:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
       
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
    end	

      
        local ml = mathex.avg(source.close,  period -PERIOD+1, period);
        local d = mathex.stdev (source.close, period -PERIOD+1 , period);

        TL[period] = ml + D * d;
        BL[period] = ml - D * d;
        AL[period] = ml;
	 local Base=  (TL[period] - BL[period]) ;
	 
	
	
	 open[period]=(source.open[period]- BL[period]) / Base* 100;
	close[period]=(source.close[period]- BL[period]) / Base* 100;
	high[period]=(source.high[period]- BL[period]) / Base* 100;
	low[period]=(source.low[period]- BL[period]) / Base* 100;

    
	
end

