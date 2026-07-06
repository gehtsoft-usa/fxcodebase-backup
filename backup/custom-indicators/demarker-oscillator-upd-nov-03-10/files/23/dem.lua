-- Id: 2174
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 

-- initializes the indicator
function Init()
    indicator:name("DeMarker");
    indicator:description("")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("N", "Number of periods for smoothing", "", 14);
    indicator.parameters:addString("MA", "Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA", "Wilders*", "", "WMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("C", "Color", "", core.rgb(0, 127, 127));
    indicator.parameters:addInteger("W", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("S", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("S", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addDouble("Level1", "Low Risk Level", "", 0.6, 0, 1);
    indicator.parameters:addDouble("Level2", "High Risk Level", "", 0.4, 0, 1);
    indicator.parameters:addColor("LC", "Main level color", "", core.rgb(0, 127, 127));
    indicator.parameters:addInteger("LW", "Main level width", "", 2, 1, 5);
    indicator.parameters:addInteger("LS", "Main level style", "", core.LINE_DOT);
    indicator.parameters:setFlag("LS", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("LC1", "Aux level color", "", core.rgb(0, 127, 127));
    indicator.parameters:addInteger("LW1", "Aux level width", "", 1, 1, 5);
    indicator.parameters:addInteger("LS1", "Aux level style", "", core.LINE_DOT);
    indicator.parameters:setFlag("LS1", core.FLAG_LINE_STYLE);
end

local source;
local first;
local out;
local max;
local min;
local smax;
local smin;
local n;

-- process parameters and prepare for calculations
function Prepare(nameOnly) 

    n = instance.parameters.N;
    source = instance.source;
	
	
	 name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.MA  .. "," .. n .. ")";
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator(instance.parameters.MA) ~= nil, "Please download and install " ..  instance.parameters.MA .. ".lua");

   

    max = instance:addInternalStream(source:first() + 1);
    min = instance:addInternalStream(source:first() + 1);
    smax = core.indicators:create(instance.parameters.MA, max, n);
    smin = core.indicators:create(instance.parameters.MA, min, n);
    first = smax.DATA:first();
   
    out = instance:addStream("DeM", core.Line, name .. ".DeM", "DeM", instance.parameters.C, first);
    out:setWidth(instance.parameters.W);
    out:setStyle(instance.parameters.S);
    out:addLevel(0, instance.parameters.LS1, instance.parameters.LW1, instance.parameters.LC1);
    out:addLevel(instance.parameters.Level2, instance.parameters.LS, instance.parameters.LW, instance.parameters.LC);
    out:addLevel(0.5, instance.parameters.LS1, instance.parameters.LW1, instance.parameters.LC1);
    out:addLevel(instance.parameters.Level1, instance.parameters.LS, instance.parameters.LW, instance.parameters.LC);
    out:addLevel(1, instance.parameters.LS1, instance.parameters.LW1, instance.parameters.LC1);
	
	
	out:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
    if (period > source:first() + 1) then
        if (source.high[period] > source.high[period - 1]) then
            max[period] = source.high[period] - source.high[period - 1]
        else
            max[period] = 0;
        end
        if (source.low[period] < source.low[period - 1]) then
            min[period] = source.low[period - 1] - source.low[period];
        else
            min[period] = 0;
        end
    end
    smax:update(mode);
    smin:update(mode);
    if (period >= first) then
        local vmax;
        local vmin;
        vmax = smax.DATA[period];
        vmin = smin.DATA[period];
        if (vmax == 0 and vmin == 0) then
            out[period] = nil;
        else
            out[period] = vmax / (vmax + vmin);
        end
    end
end
