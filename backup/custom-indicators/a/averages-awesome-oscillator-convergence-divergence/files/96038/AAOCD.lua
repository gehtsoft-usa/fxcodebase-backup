-- Id: 12545
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61196

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
    indicator:name("Averages Awesome Oscillator Convergence divergence");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation"); 
	

    indicator.parameters:addInteger("FM", "Fast Moving Average", "The number of periods to calculate the fast moving average of Price", 5, 2, 10000);
    indicator.parameters:addInteger("SM", "Slow Moving Average", "The number of periods to calculate the slow moving average of Price", 35, 2, 10000);
    
   	indicator.parameters:addString("Method1", "Fast/Slow Moving Average Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    
    indicator.parameters:addInteger("Period", "Signal Line Moving Average Period", "The number of periods to calculate the fast moving average of the Awesome Oscillator", 5, 2, 10000);
	 indicator.parameters:addString("Method2", "Signal Line Moving Average Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
	indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
	
	
	 indicator.parameters:addString("Type", "Histogram Source Selector", "", "Histogram");
    indicator.parameters:addStringAlternative("Type", "Awesome", "", "Awesome");
    indicator.parameters:addStringAlternative("Type", "Signal", "", "Signal");
    indicator.parameters:addStringAlternative("Type", "Histogram", "", "Histogram");
	
	
	indicator.parameters:addGroup("Style");

	 indicator.parameters:addColor("AOColor", "Awesome Line Color", "Awesome Line Color", core.rgb(128, 128,128));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("SignalColor", "Signal Line Color", "Signal Line Color", core.rgb(0, 128,255));
	 indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("HistogramColor", "Histogram Line Color", "Histogram Line Color", core.rgb(128, 0,255));
	 indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	    
    indicator.parameters:addColor("Up", "Color for higher Histogram bars", "Color for higher bars", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color for lower Histogram bars", "Color for lower bars", core.rgb(255, 0, 0));
end
local Method1;
local Method2;
local Period;
local FM;
local SM;
local Up,Down; 
local first;
local source = nil;
local Signal, signal;
local Type;
 
local AO = nil;
 
local FMVA = nil;
local SMVA = nil;
local SignalColor;
local HistogramColor;
local AOColor;
local Histogram;
function Prepare(nameOnly)
    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    SC = instance.parameters.SC;
	Type = instance.parameters.Type;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Period = instance.parameters.Period;
	SignalColor = instance.parameters.SignalColor;
	HistogramColor = instance.parameters.HistogramColor;
	AOColor= instance.parameters.AOColor;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
    source = instance.source; 
    local name = profile:id() .. "(" .. source:name() .. ", " .. FM .. ", " .. SM .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
    assert(FM < SM, "Fast moving average parameter must be less than slow moving average");

    FMVA = core.indicators:create("AVERAGES", source,Method1, FM, false);
    SMVA = core.indicators:create("AVERAGES", source,Method1, SM, false);
	
	first = math.max(FMVA.DATA:first(),SMVA.DATA:first());

    if Type == "Awesome" then
    AO = instance:addStream("AO", core.Bar, name .. ".AO", "AO", AOColor, first);
    else
	AO = instance:addStream("AO", core.Line, name .. ".AO", "AO", AOColor, first);
	AO:setWidth(instance.parameters.width1);
    AO:setStyle(instance.parameters.style1);
	end
	AO:setPrecision(math.max(2, instance.source:getPrecision()));
	
	signal = core.indicators:create("AVERAGES", AO,Method2, Period, false);
	
	
	if Type == "Signal" then
	Signal = instance:addStream("Signal", core.Bar, name .. ".Signal", "Signal", SignalColor, signal.DATA:first());
    else  
	Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", SignalColor, signal.DATA:first());
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
	end
	Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	
	if Type == "Histogram" then
	Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", HistogramColor, signal.DATA:first());
    else
	 Histogram = instance:addStream("Histogram", core.Line, name .. ".Histogram", "Histogram", HistogramColor, signal.DATA:first());
	Histogram:setWidth(instance.parameters.width3);
    Histogram:setStyle(instance.parameters.style3);
    end
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
 
    FMVA:update(mode);
    SMVA:update(mode);

    if (period  < first) then
	return;
	end
   
    AO[period] = FMVA.DATA[period] - SMVA.DATA[period];
 
    if Type == "Awesome" then
		 if AO[period] > AO[period-1] then
		AO:setColor(period, Up);
		else
		AO:setColor(period, Down);
		end
	end
	
	 signal:update(mode);
	
	if (period  < signal.DATA:first()) then
	return;
	end
	
	Signal[period]=signal.DATA[period];
	
	Histogram[period]=AO[period]- Signal[period];
	
	if Type == "Signal" then
		 if Signal[period] > Signal[period-1] then
		Signal:setColor(period, Up);
		else
		Signal:setColor(period, Down);
		end
	end
	
	
		if Type == "Histogram" then
		 if Histogram[period] > Histogram[period-1] then
		Histogram:setColor(period, Up);
		else
		Histogram:setColor(period, Down);
		end
	end
end

