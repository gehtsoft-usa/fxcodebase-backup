-- Id: 3406
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

	indicator.parameters:addGroup("Slow MA of Close Calculation"); 
    indicator.parameters:addInteger("SC", "Slow MA Period of Close", "", 36);
    indicator.parameters:addString("Method_SC", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method_SC", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method_SC", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method_SC", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method_SC", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method_SC", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method_SC", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method_SC", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method_SC", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method_SC", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method_SC", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method_SC", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method_SC", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method_SC", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method_SC", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method_SC", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method_SC", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method_SC", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method_SC", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method_SC", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method_SC", "JSmooth", "", "JSmooth");	
	
	indicator.parameters:addGroup("Slow MA of High Calculation"); 
    indicator.parameters:addInteger("SH", "Slow MVA Period of High", "Slow MVA Period of High", 36);
	   indicator.parameters:addString("Method_SH", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method_SH", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method_SH", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method_SH", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method_SH", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method_SH", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method_SH", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method_SH", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method_SH", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method_SH", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method_SH", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method_SH", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method_SH", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method_SH", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method_SH", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method_SH", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method_SH", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method_SH", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method_SH", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method_SH", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method_SH", "JSmooth", "", "JSmooth");	
	
	indicator.parameters:addGroup("Slow MA of Low Calculation"); 
    indicator.parameters:addInteger("SL", "Slow MVA Period of Close", "Slow MVA Period of Close", 36);
		   indicator.parameters:addString("Method_SL", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method_SL", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method_SL", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method_SL", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method_SL", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method_SL", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method_SL", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method_SL", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method_SL", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method_SL", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method_SL", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method_SL", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method_SL", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method_SL", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method_SL", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method_SL", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method_SL", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method_SL", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method_SL", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method_SL", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method_SL", "JSmooth", "", "JSmooth");
	
	
	indicator.parameters:addGroup("Fast MA of Close Calculation"); 
    indicator.parameters:addInteger("FC", "Fast MVA Period of Close", "Fast MVA Period of Close", 12);
		   indicator.parameters:addString("Method_FC", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method_FC", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method_FC", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method_FC", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method_FC", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method_FC", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method_FC", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method_FC", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method_FC", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method_FC", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method_FC", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method_FC", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method_FC", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method_FC", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method_FC", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method_FC", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method_FC", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method_FC", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method_FC", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method_FC", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method_FC", "JSmooth", "", "JSmooth");
	 
	
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

local Method;

local first;
local source = nil;

-- Streams block
local SlowClose = nil;
local SlowLow = nil;
local SlowHigh = nil;
local FastClose = nil;

local   Method_SC;
local	Method_SH;
local	Method_SL;
local	Method_FC;

local indicator={};

-- Routine
function Prepare(nameOnly)
    Method_SC= instance.parameters.Method_SC;
	Method_SH= instance.parameters.Method_SH;
	Method_SL= instance.parameters.Method_SL;
	Method_FC= instance.parameters.Method_FC;
    SC = instance.parameters.SC;
    SH = instance.parameters.SH;
    SL = instance.parameters.SL;
    FC = instance.parameters.FC;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(SC) .. ", " .. tostring(Method_SC).. ", " .. tostring(SH).. ", " .. tostring(Method_SH) .. ", " .. tostring(SL) .. ", " .. tostring(Method_SL).. ", " .. tostring(FC) .. ", " .. tostring(Method_FC) ..  ", " .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	
	indicator["SC"]  = core.indicators:create("AVERAGES", source.close, Method_SC, SC, false);
	 first = math.max(first,indicator["SC"].DATA:first());
	 
	indicator["SL"]  = core.indicators:create("AVERAGES", source.low, Method_SL, SL, false);
	 first = math.max(first,indicator["SL"].DATA:first());
	 
	indicator["SH"]  = core.indicators:create("AVERAGES", source.high, Method_SH, SH, false);
	 first = math.max(first,indicator["SH"].DATA:first());
	 
	indicator["FC"]  = core.indicators:create("AVERAGES", source.close, Method_FC, FC, false);
	 first = math.max(first,indicator["FC"].DATA:first());

    if (not (nameOnly)) then
        SlowClose = instance:addStream("SlowClose", core.Line, name .. ".SlowClose", "SlowClose", instance.parameters.SlowClose_color, first);
		 SlowClose:setWidth(instance.parameters.SlowClose_width);
         SlowClose:setStyle(instance.parameters.SlowClose_style);
		
        SlowLow = instance:addStream("SlowLow", core.Line, name .. ".SlowLow", "SlowLow", instance.parameters.SlowLow_color, first);
		SlowLow:setWidth(instance.parameters.SlowLow_width);
        SlowLow:setStyle(instance.parameters.SlowLow_style);
		
        SlowHigh = instance:addStream("SlowHigh", core.Line, name .. ".SlowHigh", "SlowHigh", instance.parameters.SlowHigh_color, first);
		SlowHigh:setWidth(instance.parameters.SlowHigh_width);		
        SlowHigh:setStyle(instance.parameters.SlowHigh_style);
		
		
		
        FastClose = instance:addStream("FastClose", core.Line, name .. ".FastClose", "FastClose", instance.parameters.FastClose_color, first);		
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

