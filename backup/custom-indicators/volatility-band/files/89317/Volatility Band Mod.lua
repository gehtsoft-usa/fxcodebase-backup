-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59444
-- Id: 9954

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Volatility Band");
    indicator:description("Volatility Band");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period_VolaBands", "Period_VolaBands", "Period_VolaBands", 8);
    indicator.parameters:addInteger("Period_Vola", "Period_Vola", "Period_Vola", 13);
    indicator.parameters:addDouble("Dev_Factor", "Dev_Factor", "Dev_Factor", 3.55);
    indicator.parameters:addDouble("Band_Adjust", "Band_Adjust", "Low_Band_Adjust", 0.9);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("midLine_color", "Color of midLine", "Color of midLine", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("lowerBand_color", "Color of lowerBand", "Color of lowerBand", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("upperBAnd_color", "Color of upperBAnd", "Color of upperBAnd", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period_VolaBands;
local Period_Vola;
local Dev_Factor;
local Band_Adjust;

local first;
local source = nil;

-- Streams block
local midLine = nil;
local lowerBand = nil;
local upperBAnd = nil;
local tpSeries;
local   AVG2, AVG1,volaValue;
-- Routine
function Prepare(nameOnly)
    Period_VolaBands = instance.parameters.Period_VolaBands;
    Period_Vola = instance.parameters.Period_Vola;
    Dev_Factor = instance.parameters.Dev_Factor;
    Band_Adjust = instance.parameters.Band_Adjust;
    source = instance.source;
    first = source:first()+1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period_VolaBands) .. ", " .. tostring(Period_Vola) .. ", " .. tostring(Dev_Factor) .. ", " .. tostring(Low_Band_Adjust) .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
        tpSeries = instance:addInternalStream(0, 0);
        volaValue= instance:addInternalStream(0, 0);
        AVG1 = core.indicators:create("EMA", volaValue, Period_VolaBands);
        AVG2 = core.indicators:create("EMA", source.typical, Period_VolaBands);
        midLine = instance:addStream("midLine", core.Line, name .. ".midLine", "midLine", instance.parameters.midLine_color, AVG1.DATA:first());
		midLine:setWidth(instance.parameters.width1);
        midLine:setStyle(instance.parameters.style1);
        lowerBand = instance:addStream("lowerBand", core.Line, name .. ".lowerBand", "lowerBand", instance.parameters.lowerBand_color, AVG1.DATA:first());
		lowerBand:setWidth(instance.parameters.width2);
        lowerBand:setStyle(instance.parameters.style2);
        upperBAnd = instance:addStream("upperBAnd", core.Line, name .. ".upperBAnd", "upperBAnd", instance.parameters.upperBAnd_color, AVG1.DATA:first());
		upperBAnd:setWidth(instance.parameters.width3);
        upperBAnd:setStyle(instance.parameters.style3);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	if source.typical[period] >= source.typical[period-1]  then		
	tpSeries[period] = source.typical[period] - source.low[period-1]
	else
	tpSeries[period] =source.typical[period-1] - source.low[period] ;
	end
	
	
	if  period < first + Period_Vola then
	return;
    end
	volaValue[period] = mathex.sum( tpSeries, period-Period_Vola+1, period ) / ( Period_Vola * Dev_Factor );
	
 
       AVG1:update(mode);	 
       AVG2:update(mode);
	   
	   

	   local dev = AVG1.DATA[period] * Band_Adjust;
	   
	   if AVG2.DATA:first()> period then
	   return;
	   end
	
        midLine[period] = AVG2.DATA[period];
        lowerBand[period] =  midLine[period] -dev;
        upperBAnd[period] = midLine[period] + dev;
    
end

