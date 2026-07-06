-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1022
-- Id: 678

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("TRIX Index");
    indicator:description("The indicator eliminates cycles shorter than the selected indicator period. ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("P_N", "TRIX Periods", "", 14);
    indicator.parameters:addString("MA_1", "First Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    indicator.parameters:addStringAlternative("MA_1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_1", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_1", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_1", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_1", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_1", "Wilders*", "", "WMA");
    indicator.parameters:addString("MA_2", "Second Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    indicator.parameters:addStringAlternative("MA_2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_2", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_2", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_2", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_2", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_2", "Wilders*", "", "WMA");
    indicator.parameters:addString("MA_3", "Third Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    indicator.parameters:addStringAlternative("MA_3", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_3", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_3", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_3", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_3", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_3", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_3", "Wilders*", "", "WMA");
    indicator.parameters:addInteger("S_N", "Signal Periods", "", 9);
    indicator.parameters:addString("MA_S", "Signal Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA_S", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_S", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_S", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_S", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_S", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_S", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_S", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_S", "Wilders*", "", "WMA");

    indicator.parameters:addColor("TRIX_color", "Color of trix line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Color of signal line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	
	indicator.parameters:addColor("UP", "Up Histogram  in Up Trend", "The color of Up Histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UPDOWN", "Down Histogram in Up Trend", "The color of Up Histogram.", core.rgb(0, 200, 0));
	
	indicator.parameters:addColor("DOWNUP", "Up Histogram in Down Trend", "The color of Down Histogram.", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DOWN", "Down Histogram in Down Trend", "The color of Down Histogram.", core.rgb(200, 0, 0));
end

local source;
local MA1, MA2, MA3, MA4;
local TRIX, SIGNAL, HISTOGRAM;

function Prepare(nameOnly)
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.P_N .. "," .. instance.parameters.S_N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator(instance.parameters.MA_1) ~= nil, "Please, download and install ".. instance.parameters.MA_1.. " indicator");  
	assert(core.indicators:findIndicator(instance.parameters.MA_2) ~= nil, "Please, download and install ".. instance.parameters.MA_2.. " AVERAGES.LUA indicator");  
	assert(core.indicators:findIndicator(instance.parameters.MA_2) ~= nil, "Please, download and install  ".. instance.parameters.MA_3.. "AVERAGES.LUA indicator");  

    MA1 = core.indicators:create(instance.parameters.MA_1, instance.source, instance.parameters.P_N);
    MA2 = core.indicators:create(instance.parameters.MA_2, MA1.DATA, instance.parameters.P_N);
    assert(core.indicators:findIndicator(instance.parameters.MA_3) ~= nil, instance.parameters.MA_3 .. " indicator must be installed");
    MA3 = core.indicators:create(instance.parameters.MA_3, MA2.DATA, instance.parameters.P_N);

    TRIX = instance:addStream("T", core.Line, name .. ".T", "T", instance.parameters.TRIX_color, MA3.DATA:first() + 1);
    TRIX:setPrecision(math.max(2, instance.source:getPrecision()));
    TRIX:setWidth(instance.parameters.width1);
    TRIX:setStyle(instance.parameters.style1);
    TRIX:addLevel(0);

    assert(core.indicators:findIndicator(instance.parameters.MA_S) ~= nil, instance.parameters.MA_S .. " indicator must be installed");
    MA4 = core.indicators:create(instance.parameters.MA_S, TRIX, instance.parameters.S_N);

    SIGNAL = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.SIGNAL_color, MA4.DATA:first());
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
    SIGNAL:setWidth(instance.parameters.width2);
    SIGNAL:setStyle(instance.parameters.style2);
	
	HISTOGRAM = instance:addStream("H", core.Bar, name .. ".H", "H", instance.parameters.UP, MA4.DATA:first());
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    MA1:update(mode);
    MA2:update(mode);
    MA3:update(mode);

    if period >= TRIX:first() then
        TRIX[period] = (MA3.DATA[period] - MA3.DATA[period - 1]) / MA3.DATA[period - 1] * 100;
    end
    MA4:update(mode);
    if period >= SIGNAL:first() then
        SIGNAL[period] = MA4.DATA[period];
		HISTOGRAM[period] =TRIX[period] - MA4.DATA[period];
    end
	
	
	
	                     if HISTOGRAM[period] > 0 then
							  if HISTOGRAM[period] > HISTOGRAM[period-1] then
							  HISTOGRAM:setColor(period, instance.parameters.UP);
							  else
							   HISTOGRAM:setColor(period, instance.parameters.UPDOWN);
							  end
						 else
						     if HISTOGRAM[period] < HISTOGRAM[period-1] then
							  HISTOGRAM:setColor(period, instance.parameters.DOWN);
							  else
							   HISTOGRAM:setColor(period, instance.parameters.DOWNUP);
							  end
						 end
	
end

