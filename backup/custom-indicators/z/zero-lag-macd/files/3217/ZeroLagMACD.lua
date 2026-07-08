-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1623
-- Id: 1119

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Zero Lag MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("FMA", "Fast EMA periods", "", 12, 1, 5000);
    indicator.parameters:addInteger("SMA", "Slow EMA Periods", "", 24, 1, 5000);
    indicator.parameters:addInteger("SigMA", "Signal EMA periods", "", 9, 1, 5000);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color", "Color of MACD", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIG_color", "Color of Signal", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HIS_color_Up", "Color of Historgram Up", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HIS_color_Down", "Color of Historgram Down", "", core.rgb(255,0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local FMA;
local SMA;
local SigMA;

local FMA_I;
local SMA_I;
local FMA_I2;
local SMA_I2;
local SigMA_I;
local SigMA_I2;

local firstMACD, firstSIG;
local source = nil;

-- Streams block
local MACD = nil;
local SIG = nil;
local HIS = nil;

-- Routine
function Prepare(nameOnly)
    FMA = instance.parameters.FMA;
    SMA = instance.parameters.SMA;
    SigMA = instance.parameters.SigMA;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. FMA .. ", " .. SMA .. ", " .. SigMA .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    FMA_I = core.indicators:create("EMA", source, FMA);
    SMA_I = core.indicators:create("EMA", source, SMA);
    FMA_I2 = core.indicators:create("EMA", FMA_I.DATA, FMA);
    SMA_I2 = core.indicators:create("EMA", SMA_I.DATA, SMA);

    firstMACD = math.max(FMA_I2.DATA:first(), SMA_I2.DATA:first());

    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstMACD);
	
    MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
    SigMA_I = core.indicators:create("EMA", MACD, SigMA);
    SigMA_I2 = core.indicators:create("EMA", SigMA_I.DATA, SigMA);

    firstSIG = SigMA_I2.DATA:first();
    SIG = instance:addStream("SIG", core.Line, name .. ".SIG", "SIG", instance.parameters.SIG_color, firstSIG);
	SIG:setWidth(instance.parameters.width2);
    SIG:setStyle(instance.parameters.style2);
    HIS = instance:addStream("HISTOGRAM", core.Bar, name .. ".HIS", "HIS", instance.parameters.HIS_color_Up, firstSIG);
	
	
	MACD:setPrecision(math.max(2, source:getPrecision()));
	SIG:setPrecision(math.max(2, source:getPrecision()));
	HIS:setPrecision(math.max(2, source:getPrecision()));

end

-- Indicator calculation routine
function Update(period, mode)
    FMA_I:update(mode);
    FMA_I2:update(mode);
    SMA_I:update(mode);
    SMA_I2:update(mode);

    if period < firstMACD then
	return;
	end
        MACD[period] = (2 * FMA_I.DATA[period] - FMA_I2.DATA[period]) -
                       (2 * SMA_I.DATA[period] - SMA_I2.DATA[period]);
   

    SigMA_I:update(mode);
    SigMA_I2:update(mode);

    if period < firstSIG then 
	return;
	end
	
        SIG[period] = 2 * SigMA_I.DATA[period] - SigMA_I2.DATA[period];
        HIS[period] = MACD[period] - SIG[period];
		
		if HIS[period] > 0 then
		HIS:setColor(period,  instance.parameters.HIS_color_Up);
		else		
		HIS:setColor(period,  instance.parameters.HIS_color_Down);
		end
    
end

