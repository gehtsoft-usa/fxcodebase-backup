-- Id: 19206
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65140

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
function Init()
    indicator:name("Smoothed True Range Indecision");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volatility");

	indicator.parameters:addGroup("Selector"); 
	indicator.parameters:addBoolean("S1", "Show ATR Line", "", true);
	indicator.parameters:addBoolean("S2", "Show Open Close Line", "", true);
	indicator.parameters:addBoolean("S3", "Show High Low Line", "", true);
	
 
	
    indicator.parameters:addGroup("Smoothing"); 
	indicator.parameters:addBoolean("Use", "Use Smoothing", "", true);
	indicator.parameters:addInteger("Period1", "True Range Period","", 14, 2, 1000);
	indicator.parameters:addInteger("Period2", "Open/Close Range Period","", 14, 2, 1000);
	indicator.parameters:addInteger("Period3", "High/Low Range Period","", 14, 2, 1000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrATR", "ATR Line Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrOC", "Open Close Line Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("clrHL", "High Low Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthATR","Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleATR", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleATR", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local S1, S2, S3;
local first;
local source = nil;


local tAbs = math.abs;
-- Streams block
local TR_Raw, TR;
local HL;
local OC;

local HL_Raw,OC_Raw;
local Method, Period1,Period2, Period3, Use, HL_MA, OC_MA,MA;

-- Routine
function Prepare(nameOnly)
   
	S1 = instance.parameters.S1;
	S2 = instance.parameters.S2;
	S3 = instance.parameters.S3;
	Method= instance.parameters.Method;
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Use= instance.parameters.Use;
	
    source = instance.source;
	local name="";
	
    if Use then
	name = profile:id() .. "(" .. source:name() .. ", " .. Period1.. ", " .. Period2.. ", " .. Period3 .. ", " .. Method .. ")";
	else
    name = profile:id() .. "(" .. source:name() .. ")";
	end
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    TR_Raw = instance:addInternalStream(source:first() + 1, 0);
   
	
	if Use then
	HL_Raw = instance:addInternalStream(0, 0);
	OC_Raw = instance:addInternalStream(0, 0);
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	HL_MA= core.indicators:create(Method, HL_Raw, Period3);
	OC_MA= core.indicators:create(Method, OC_Raw, Period2);
	MA= core.indicators:create(Method, TR_Raw, Period1);
	
	first=HL_MA.DATA:first();
	else
	first=source:first();
	end
	
	
	if S1 then
    TR = instance:addStream("TR", core.Line, name, "TR", instance.parameters.clrATR, first)
    TR:setWidth(instance.parameters.widthATR);
    TR:setStyle(instance.parameters.styleATR);
	else
	TR = instance:addInternalStream(0, 0);
	end
	
	if S2 then
	OC = instance:addStream("OC", core.Line, name, "OC", instance.parameters.clrOC, first)
    OC:setWidth(instance.parameters.widthATR);
    OC:setStyle(instance.parameters.styleATR);
	else
	OC = instance:addInternalStream(0, 0);
	end
	
	if S3 then
	HL = instance:addStream("HL", core.Line, name, "HL", instance.parameters.clrHL, first)
    HL:setWidth(instance.parameters.widthATR);
    HL:setStyle(instance.parameters.styleATR);
	else
	HL = instance:addInternalStream(0, 0);
	end
	
	
    local precision = math.max(2, source:getPrecision());
    TR:setPrecision(precision);
	OC:setPrecision(precision);
	HL:setPrecision(precision);

 
end

function getTrueRange(period)
    local hl = tAbs(source.high[period] - source.low[period]);
    local hc = tAbs(source.high[period] - source.close[period - 1]);
    local lc = tAbs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

-- Indicator calculation routine

function Update(period, mode)
     
    
	if Use then
	HL_Raw[period]= source.high[period]-source.low[period];
	OC_Raw[period]= math.abs(source.open[period]-source.close[period]);	
	TR_Raw[period] = getTrueRange(period);
	
	HL_MA:update(mode);
	OC_MA:update(mode);
	MA:update(mode);
	  
		if period < HL_MA.DATA:first() then
		return;
		end
	  
	HL[period]= HL_MA.DATA[period];
	OC[period]= OC_MA.DATA[period];  
	TR[period]= MA.DATA[period];  
	
	else
	HL[period]= source.high[period]-source.low[period];
	OC[period]= math.abs(source.open[period]-source.close[period]);	
	TR[period] = getTrueRange(period);
	end
end