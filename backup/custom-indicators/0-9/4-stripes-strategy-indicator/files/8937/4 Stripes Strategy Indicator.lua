-- Id: 3381
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3690

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
    indicator:name("4 Stripes Strategy Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("SC", "Slow MVA Period of Close", "Slow MVA Period of Close", 36);
    indicator.parameters:addInteger("SH", "Slow MVA Period of High", "Slow MVA Period of High", 36);
    indicator.parameters:addInteger("SL", "Slow MVA Period of Close", "Slow MVA Period of Close", 36);
    indicator.parameters:addInteger("FC", "Fast MVA Period of Close", "Fast MVA Period of Close", 12);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SlowClose_color", "Color of SlowClose Line", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("SlowClose_width", "Slow Close Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("SlowClose_style", "Slow Close Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SlowClose_style", core.FLAG_LEVEL_STYLE);
	
    indicator.parameters:addColor("SlowLow_color", "Color of SlowLow", "Color of SlowLow", core.rgb(255, 0, 0));
	
	 indicator.parameters:addInteger("SlowLow_width", "Slow Low Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("SlowLow_style", "Slow Low Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SlowLow_style", core.FLAG_LEVEL_STYLE);
	
    indicator.parameters:addColor("SlowHigh_color", "Color of SlowHigh", "Color of SlowHigh", core.rgb(0, 255, 0));
	
	 indicator.parameters:addInteger("SlowHigh_width", "Slow High Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("SlowHigh_style", "Slow High Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SlowHigh_style", core.FLAG_LEVEL_STYLE);
	
    indicator.parameters:addColor("FastClose_color", "Color of FastClose", "Color of FastClose", core.rgb(200, 200, 200));
	
	 indicator.parameters:addInteger("FastClose_width", "Fast Close Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("FastClose_style", "Fast Close Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("FastClose_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SC;
local SH;
local SL;
local FC;

local first;
local source = nil;

-- Streams block
local SlowClose = nil;
local SlowLow = nil;
local SlowHigh = nil;
local FastClose = nil;

local indicator={};

-- Routine
function Prepare(nameOnly)
    SC = instance.parameters.SC;
    SH = instance.parameters.SH;
    SL = instance.parameters.SL;
    FC = instance.parameters.FC;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(SC) .. ", " .. tostring(SH) .. ", " .. tostring(SL) .. ", " .. tostring(FC) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	indicator["SC"]  = core.indicators:create("MVA", source.close, SC);
	indicator["SL"]  = core.indicators:create("MVA", source.low, SL);
	indicator["SH"]  = core.indicators:create("MVA", source.high, SH);
	indicator["FC"]  = core.indicators:create("MVA", source.close, FC);

    if (not (nameOnly)) then
        SlowClose = instance:addStream("SlowClose", core.Line, name .. ".SlowClose", "SlowClose", instance.parameters.SlowClose_color, first+SC);
		 SlowClose:setWidth(instance.parameters.SlowClose_width);
         SlowClose:setStyle(instance.parameters.SlowClose_style);
		
        SlowLow = instance:addStream("SlowLow", core.Line, name .. ".SlowLow", "SlowLow", instance.parameters.SlowLow_color, first+SL);
		SlowLow:setWidth(instance.parameters.SlowLow_width);
        SlowLow:setStyle(instance.parameters.SlowLow_style);
		
        SlowHigh = instance:addStream("SlowHigh", core.Line, name .. ".SlowHigh", "SlowHigh", instance.parameters.SlowHigh_color, first+SH);
		SlowHigh:setWidth(instance.parameters.SlowHigh_width);		
        SlowHigh:setStyle(instance.parameters.SlowHigh_style);
		
		
		
        FastClose = instance:addStream("FastClose", core.Line, name .. ".FastClose", "FastClose", instance.parameters.FastClose_color, first+FC);		
		FastClose:setWidth(instance.parameters.FastClose_width);
        FastClose:setStyle(instance.parameters.FastClose_style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	    indicator["SC"]:update(mode);
	    indicator["SL"]:update(mode);
		indicator["SH"]:update(mode);
		indicator["FC"]:update(mode);
		
		
		if not indicator["SC"].DATA:hasData(period) or not indicator["SL"].DATA:hasData(period)  or not indicator["SH"].DATA:hasData(period) or not indicator["FC"].DATA:hasData(period) then 
		return;
		end
	
        SlowClose[period] = indicator["SC"].DATA[period];
        SlowLow[period] = indicator["SL"].DATA[period];
        SlowHigh[period] = indicator["SH"].DATA[period];
        FastClose[period] = indicator["FC"].DATA[period];
   
end

