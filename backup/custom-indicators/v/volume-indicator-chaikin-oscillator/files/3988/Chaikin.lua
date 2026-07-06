-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1964

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


function Init()
    indicator:name("Chaikin Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastN", "Fast MA Periods", "", 3, 1, 1000);
    indicator.parameters:addInteger("SlowN", "Slow MA Periods", "", 10, 1, 1000);
    indicator.parameters:addString("Method", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "REGRESSION");
    indicator.parameters:addStringAlternative("Method", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("Method", "Wilders*", "", "WMA");
    indicator.parameters:addBoolean("Prev", "Incremental A/D", "If the parameter is true, then A/D's previous bar value is added to A/D's current bar value", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Display", "Display indicator as", "", "H");
    indicator.parameters:addStringAlternative("Display", "Line", "", "L");
    indicator.parameters:addStringAlternative("Display", "Histogram", "", "H");

    indicator.parameters:addColor("clrCHO", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthCHO", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCHO", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCHO", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrHU", "Up histogram color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrHD", "Down histogram color", "", core.rgb(255, 0, 0));
end

local first;
local AD;
local FMA, SMA;
local line;
local CHO;
local U, D;

 function Prepare(nameOnly)   
    source = instance.source;
	
	
	 local name;
    name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.Method .. "," .. instance.parameters.FastN .. "," .. instance.parameters.SlowN;
    if instance.parameters.Prev then
        name = name .. ",A/D(Incremental))";
    else
        name = name .. ",A/D(Simple))";
    end
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    assert(source:supportsVolume(), "The source must have volume");

    assert(core.indicators:findIndicator("AD") ~= nil, "The A/D indicator must be installed");
    assert(core.indicators:findIndicator(instance.parameters.Method) ~= nil, "The indicator for the chosen smoothing method must be installed");

   

    AD = core.indicators:create("AD", source, instance.parameters.Prev);
    FMA = core.indicators:create(instance.parameters.Method, AD.DATA, instance.parameters.FastN);
    SMA = core.indicators:create(instance.parameters.Method, AD.DATA, instance.parameters.SlowN);

    first = math.max(FMA.DATA:first(), SMA.DATA:first());

    if instance.parameters.Display == "L" then
        line = true;
        CHO = instance:addStream("CHO", core.Line, name, "CHO", instance.parameters.clrCHO, first);
        CHO:setPrecision(2);
        CHO:setWidth(instance.parameters.widthCHO);
        CHO:setStyle(instance.parameters.styleCHO);
        CHO:addLevel(0);
    else
        line = false;
        CHO = instance:addInternalStream(first, 0);
        U = instance:addStream("U", core.Bar, name .. ".U", "U", instance.parameters.clrHU, first);
        U:setPrecision(2);
        D = instance:addStream("D", core.Bar, name .. ".D", "D", instance.parameters.clrHD, first);
        D:setPrecision(2);
        U:addLevel(0);
    end
end

function Update(period, mode)
    AD:update(mode);
    FMA:update(mode);
    SMA:update(mode);

    if period >= first then
        CHO[period] = FMA.DATA[period] - SMA.DATA[period];
        if not(line) then
            if CHO[period] > 0 then
                U[period] = CHO[period];
            else
                D[period] = CHO[period];
            end
        end
    end
end
