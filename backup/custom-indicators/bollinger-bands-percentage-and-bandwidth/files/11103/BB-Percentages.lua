-- Id: 4012
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=226
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



-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bollinger Band - Percentage Oscillator");
    indicator:description("Provides a percentage display between two Bollinger Bands.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addInteger("N", "Number of periods", "Number of periods", 20);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2);
    indicator.parameters:addColor("clrBBP", "Percentage line color", "The color of the average line of the band.", core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addString("Type", "Line Type", "", "Histogram");
    indicator.parameters:addStringAlternative("Type", "Histogram", "", "Histogram");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
	
	
    indicator.parameters:addGroup("Channel Limit Line Style");
	indicator.parameters:addColor("CLLcolor", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("CLLwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("CLLstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("CLLstyle", core.FLAG_LINE_STYLE);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;

local firstPeriod;
local source = nil;

-- Streams block
local TL = nil;
local AL = nil;
local BL = nil;

local PL = nil;
local Type= nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = "Bollinger Bands - Percentage Oscillator";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    -- TOP LINE AND BOTTOM LINE INTERNAL STREAMS
    TL = instance:addInternalStream(firstPeriod)
    BL = instance:addInternalStream(firstPeriod)
    AL = instance:addInternalStream(firstPeriod)
	Type= instance.parameters.Type;
    
    -- PERCENTAGE LINE
	if Type == "Line" then
    PL = instance:addStream("Percentage", core.Line, name .. ".PERCENTAGE", "BBPL", instance.parameters.clrBBP, firstPeriod);
    else
	PL = instance:addStream("Percentage", core.Bar, name .. ".PERCENTAGE", "BBPL", instance.parameters.clrBBP, firstPeriod);
	end
	PL:setPrecision(math.max(2, instance.source:getPrecision()));
    
	PL:setWidth(instance.parameters.width);
    PL:setStyle(instance.parameters.style);
	
	
	
	PL:addLevel (0, instance.parameters.CLLstyle, instance.parameters.CLLwidth, instance.parameters.CLLcolor) ;
	PL:addLevel (100, instance.parameters.CLLstyle, instance.parameters.CLLwidth, instance.parameters.CLLcolor); 
	
end

-- Indicator calculation routine
function Update(period)

    -- CALCULATE "Bollinger Bands" INTERNAL STREAMS 
    if(period >= firstPeriod) then
        local p = core.rangeTo(period, N);
        local ml = core.avg(source, p);
        local d = core.stdev(source, p);

        TL[period] = ml + D * d;
        BL[period] = ml - D * d;
        AL[period] = ml;
    end
    
    -- CALCULATE "Bollinger Bands" PERCENTAGE STREAM
    if(period >= firstPeriod) then
    	PL[period] = ((source[period] - BL[period]) / (TL[period] - BL[period])) * 100
    end
end





