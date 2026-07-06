-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=884

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("ChandelierExit");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	   indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Range", "Range", "", 7);
    indicator.parameters:addInteger("Shift", "Shift", "", 0);
    indicator.parameters:addInteger("ATRPeriod", "ATR Period", "", 9);
    indicator.parameters:addDouble("ATRMultipl", "ATRMultipl", "", 2.5);
	
		indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(255, 0, 255));
    indicator.parameters:addColor("Dn_color", "Color of Dn", "Color of Dn", core.rgb(255, 128, 64));
	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Range;
local Shift;
local ATRPeriod;
local ATRMultipl;

local first;
local ATR;
local source = nil;

-- Streams block
local Up = nil;
local Dn = nil;
local B1, B2, D;

-- Routine
 function Prepare(nameOnly) 
    Range = instance.parameters.Range;
    Shift = instance.parameters.Shift;
    ATRPeriod = instance.parameters.ATRPeriod;
    ATRMultipl = instance.parameters.ATRMultipl;
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Range .. ", " .. Shift .. ", " .. ATRPeriod .. ", " .. ATRMultipl .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    ATR = core.indicators:create("ATR", source, ATRPeriod);
    first = math.max(ATR.DATA:first(), source:first() + Range) + Shift;

    
    Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.Up_color, first);
	Up:setWidth(instance.parameters.width);
    Up:setStyle(instance.parameters.style);
	
    Dn = instance:addStream("Dn", core.Line, name .. ".Dn", "Dn", instance.parameters.Dn_color, first);
	Dn:setWidth(instance.parameters.width);
    Dn:setStyle(instance.parameters.style);
	
    B1 = instance:addInternalStream(0, 0);
    B2 = instance:addInternalStream(0, 0);
    D = instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
function Update(period, mode)
    ATR:update(mode);
    if period < first then
	return;
	end
	
        local atr, hh, ll;

        atr = ATR.DATA[period - Shift] * ATRMultipl;
        ll, hh = core.minmax(source, core.rangeTo(period - Shift, Range));
        B1[period] = hh - atr;
        B2[period] = ll + atr;

        D[period] = D[period - 1];

        if source.close[period] > B2[period - 1] then
            D[period] = 1;
        elseif source.close[period] < B1[period - 1] then
            D[period] = -1;
        end

        if D[period] == 1 then
            if B1[period] < B1[period - 1] then
                B1[period] = B1[period - 1];
            end
            Dn[period] = B1[period];
        elseif D[period] == -1 then
            if B2[period] > B2[period - 1] then
                B2[period] = B2[period - 1];
            end
            Up[period] = B2[period];
        end
    
end

