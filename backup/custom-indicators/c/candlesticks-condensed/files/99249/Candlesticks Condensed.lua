
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61996

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
    indicator:name("Candlesticks Condensed");
    indicator:description("Candlesticks Condensed");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("SegmentCount", "Segment Count", "Segment Count", 5);
	indicator.parameters:addBoolean("OnlyLast", "Show Only Last Candle Values","", false);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color of Label", "Color of Label", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Color;
local font;
local Size;
local SegmentDivisor;
local SegmentCount;
local CandleRange
local OnlyLast;
local AverageCandleRange;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Color=instance.parameters.Color;
	OnlyLast=instance.parameters.OnlyLast;
	Size=instance.parameters.Size;
	SegmentCount=instance.parameters.SegmentCount;
	
    
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	font = core.host:execute("createFont", "Courier", Size, false, false);	

	
	SegmentDivisor=100/SegmentCount;
	
	CandleRange= instance:addInternalStream(0, 0);
	AverageCandleRange = core.indicators:create("MVA", CandleRange, SegmentCount);
	
	first = AverageCandleRange.DATA:first();

  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if OnlyLast and period~=source:size()-1 then
    return;
    end 	 

    CandleRange[period]= source.high[period] - source.low[period];
	
	AverageCandleRange:update(mode);
	
    if period < first or not source:hasData(period) then
	return;
	end 
	
	local RangeMultiplier = CandleRange[period] / AverageCandleRange.DATA[period];
	 
				if RangeMultiplier > 1 then
				RangeMultiplier = 1.0;
				end

				local  HO = (((source.high[period] - source.open[period]) /( CandleRange[period]/100)) * RangeMultiplier) / SegmentDivisor;
				local  HC = (((source.high[period] - source.close[period]) /( CandleRange[period]/100)) * RangeMultiplier) / SegmentDivisor;
				local  OL = (((source.open[period] - source.low[period]) / (CandleRange[period]/100)) * RangeMultiplier) / SegmentDivisor; 
				
	
				local Label=  string.format("HO:%i\n HC:%i\n OL:%i\n" , HO, HC, OL); 				
				core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, Color, Label);

end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
