-- Id: 7903
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=8619


--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Tick Z Score Price Normalization");
    indicator:description("Tick Z Score Price Normalization");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 20);
	 indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Color of ZScore", "Color of ZScore", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);		
	
	
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
	
	TL = instance:addInternalStream(0,0);
    BL = instance:addInternalStream(0,0);
    AL = instance:addInternalStream(0,0);
	


    if (not (nameOnly)) then	
	open = instance:addStream("PN", core.Line, name, "Z Score Price Normalization", instance.parameters.color, first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    open:setWidth(instance.parameters.Width);
    open:setStyle(instance.parameters.Style);
	
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

      
        local ml = mathex.avg(source,  period -PERIOD+1, period);
        local d = mathex.stdev (source, period -PERIOD+1 , period);

        TL[period] = ml + D * d;
        BL[period] = ml - D * d;
        AL[period] = ml;
		
		
	 local Base=  (TL[period] - BL[period]) ;
	 
	
	
	 open[period]=(source[period]- BL[period]) / Base* 100;


    
	
end

