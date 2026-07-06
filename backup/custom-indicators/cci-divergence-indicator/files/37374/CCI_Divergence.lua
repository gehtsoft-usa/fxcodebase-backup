-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 7108

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

function Init()
    indicator:name("CCI Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCI_Period", "Period of CCI", "", 14);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("I", "Indicator mode", "Keep true value to display labels and lines. Set this parameter to false when the indicator is used in another indicator.", true);
	
    indicator.parameters:addColor("D_color", "Color of Divergence line", "", core.rgb(0, 155, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
	
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local I;
local DD;
local UP_color;
local DN_color;
local style, width;
local first;
local source = nil;

-- Streams block
local D = nil;
local UP = nil;
local DN = nil;
local CCI = nil;
local lineid = nil;

-- Routine
function Prepare(nameOnly)
    I = instance.parameters.I;
    DD = instance.parameters.DD;
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
	
	style= instance.parameters.style;
	width= instance.parameters.width;
	
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CCI_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    CCI = core.indicators:create("CCI", source, instance.parameters.CCI_Period);
    first = CCI.DATA:first();

    D = instance:addStream("CCI", core.Line, name .. ".CCI", "CCI", instance.parameters.D_color, first, -1);
    D:setWidth(instance.parameters.widthLinReg);
    D:setStyle(instance.parameters.styleLinReg);
	
	D:setPrecision(math.max(2, instance.source:getPrecision()));
    if I then
        UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
        DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
    else
        UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.D_color, first, -1);
        DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.D_color, first, -1);
		
		UP:setPrecision(math.max(2, instance.source:getPrecision()));
		DN:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)


    
	 
    -- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    
     period = period - 1;
	pperiod1 = source:serial(period);

    CCI:update(mode);
    if period >= first then
        D[period] = CCI.DATA[period];
        if period >= first + 2 then
            processBullish(period - 2);
            processBearish(period - 2);
        end
    end
end

function processBullish(period)
    if isTrough(period) then
        local curr, prev;
        curr = period;
        prev = prevTrough(period);
        if prev ~= nil then
            if CCI.DATA[curr] > CCI.DATA[prev] and source.low[curr] < source.low[prev] then
                if I then
                    DN:set(curr, CCI.DATA[curr], "\225", "Classic bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), CCI.DATA[prev], source:date(curr), CCI.DATA[curr], DN_color, style, width);
                else
                    DN[period] = curr - prev;
                end
            elseif CCI.DATA[curr] < CCI.DATA[prev] and source.low[curr] > source.low[prev] then
                if I then
                    DN:set(curr, CCI.DATA[curr], "\225", "Reversal bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), CCI.DATA[prev], source:date(curr), CCI.DATA[curr], DN_color, style, width);
                else
                    DN[period] = -(curr - prev);
                end
            end
        end

    end
end

function isTrough(period)
    local i;
    if CCI.DATA[period] < 0 and CCI.DATA[period] < CCI.DATA[period - 1] and CCI.DATA[period] < CCI.DATA[period + 1] then
        for i = period - 1, first, -1 do
            if CCI.DATA[i] > 0 then
                return true;
            elseif CCI.DATA[period] > CCI.DATA[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if CCI.DATA[i] <= CCI.DATA[i - 1] and CCI.DATA[i] < CCI.DATA[i - 2] and
           CCI.DATA[i] <= CCI.DATA[i + 1] and CCI.DATA[i] < CCI.DATA[i + 2] then
           return i;
        end
    end
    return nil;
end

function processBearish(period)
    if isPeak(period) then
        local curr, prev;
        curr = period;
        prev = prevPeak(period);
        if prev ~= nil then
            if CCI.DATA[curr] < CCI.DATA[prev] and source.high[curr] > source.high[prev] then
                if I then
                    UP:set(curr, CCI.DATA[curr], "\226", "Classic bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), CCI.DATA[prev], source:date(curr), CCI.DATA[curr], UP_color, style, width);
                else
                    UP[period] = curr - prev;
                end
            elseif CCI.DATA[curr] > CCI.DATA[prev] and source.high[curr] < source.high[prev] then
                if I then
                    UP:set(curr, CCI.DATA[curr], "\226", "Reversal bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), CCI.DATA[prev], source:date(curr), CCI.DATA[curr], UP_color, style, width);
                else
                    UP[period] = -(curr - prev);
                end
            end
        end

    end
end

function isPeak(period)
    local i;
    if CCI.DATA[period] > 0 and CCI.DATA[period] > CCI.DATA[period - 1] and CCI.DATA[period] > CCI.DATA[period + 1] then
        for i = period - 1, first, -1 do
            if CCI.DATA[i] < 0 then
                return true;
            elseif CCI.DATA[period] < CCI.DATA[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if CCI.DATA[i] >= CCI.DATA[i - 1] and CCI.DATA[i] > CCI.DATA[i - 2] and
           CCI.DATA[i] >= CCI.DATA[i + 1] and CCI.DATA[i] > CCI.DATA[i + 2] then
           return i;
        end
    end
    return nil;
end
