-- Id: 2464
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=294

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Gann Swing");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color of the line", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first = 0;
local source = nil;
local high = nil;
local low = nil;
local out = nil;

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;
    high = source.high;
    low = source.low;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    out = instance:addStream("GSW", core.Line, name, "GSW", instance.parameters.clr,  first);
	out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);
end

local swingNone = 0;
local swingUp = 1;
local swingDown = -1;
local swingDir = nil;
local _previousPeak = nil;
local _previousDrawn = nil;

-- calculate the value
function Update(period)
    local i, us, ds;

    if (period <= 3) then
        swingDir = swingNone;
        _previousPeak = nil;
        _previousDrawn = nil;
    end

    local previousPeak = nil;
    local previousDrawn = nil;

    if _previousPeak ~= nil then
        for i = period, 0, -1 do
            if (source:date(i) == _previousDrawn) then
                previousDrawn = i;
            end
            if (source:date(i) == _previousPeak) then
                previousPeak = i;
                break;
            end
        end
    end

    if (previousPeak == nil) then
        swingDir = swingNone;
        previousDrawn = nil;
    end

    period = period - 1;        -- calculate for the previous period
    if previousPeak ~= nil and previousPeak == period then
        return ;
    end

    if (period > 3) then
        -- check for swing high and swing low conditions
        us = false;
        ds = false;

        -- 1.Two consecutive Higher High candles indicate Upswing.
        if high[period] > high[period - 1] and high[period - 1] > high[period - 2] then
            us = true;
        end

        -- 2.Two consecutive Lower Low candles indicate Downswing.
        if low[period] < low[period - 1] and low[period - 1] < low[period - 2] then
            ds = true;
        end

        -- 4.If the next bar has a higher high and a higher low (or the same low) when
        -- compared to the previous bar, then the swing line goes up connecting the high of the next bar.
        if not(us) and high[period] > high[period - 1] and low[period] >= low[period -1] then
            us = true;
        end
        
        -- 5. If the next bar has a lower high (or same high) and a
        -- lower low when compared to the previous bar, then the swing line goes down connecting the low of the next bar.
        if not(ds) and high[period] <= high[period - 1] and low[period] < low[period -1] then
            ds = true;
        end

        if us then
            if swingDir == swingUp then
                core.drawLine(out, core.range(previousPeak, period), out[previousPeak], previousPeak, high[period], period);
                previousDrawn = period;
            elseif swingDir == swingDown then
                -- direction was changed
                core.drawLine(out, core.range(previousDrawn, period), out[previousDrawn], previousDrawn, high[period], period);
                swingDir = swingUp;
                previousPeak = previousDrawn;
                previousDrawn = period;
            else
                -- no direction yet
                swingDir = swingUp;
                previousPeak = period;
                previousDrawn = period;
                out[period] = high[period];
            end
        elseif ds then
            if swingDir == swingDown then
                -- continue the gann line from the last peak
                core.drawLine(out, core.range(previousPeak, period), out[previousPeak], previousPeak, low[period], period);
                previousDrawn = period;
            elseif swingDir == swingUp then
                -- direction was changed
                core.drawLine(out, core.range(previousDrawn, period), out[previousDrawn], previousDrawn, low[period], period);
                swingDir = swingDown;
                previousPeak = previousDrawn;
                previousDrawn = period;
            else
                -- no direction yet
                swingDir = swingDown;
                previousPeak = period;
                previousDrawn = period;
                out[period] = low[period];
            end
        else
            -- 7.If the next br is an outside bar (higher high and
            -- lower low), plot a swing line on the high of an outside bar if the
            -- following bar (one after the outside bar) is lower, OR plot a swing
            -- line on the low of an outside bar if the following bar (one after the
            -- outside bar) is higher.
            if (high[period - 1] > high[period - 2] and low[period - 1] < low[period - 2]) then
                -- outside bar was before the current bar
                if (high[period] > high[period - 1] and low[period] >= low[period - 1]) then
                    -- plot to low
                    if swingDir == swingDown then
                        -- continue the gann line from the last peak
                        core.drawLine(out, core.range(previousPeak, period), out[previousPeak], previousPeak, low[period], period);
                        previousDrawn = period;
                    elseif swingDir == swingUp then
                        -- direction was changed
                        core.drawLine(out, core.range(previousDrawn, period), out[previousDrawn], previousDrawn, low[period], period);
                        swingDir = swingDown;
                        previousPeak = previousDrawn;
                        previousDrawn = period;
                    end
                elseif (high[period] <= high[period - 1] and low[period] < low[period - 1]) then
                    -- plot to high
                    if swingDir == swingUp then
                        core.drawLine(out, core.range(previousPeak, period), out[previousPeak], previousPeak, high[period], period);
                        previousDrawn = period;
                    elseif swingDir == swingDown then
                        -- direction was changed
                        core.drawLine(out, core.range(previousDrawn, period), out[previousDrawn], previousDrawn, high[period], period);
                        swingDir = swingUp;
                        previousPeak = previousDrawn;
                        previousDrawn = period;
                    end
                end
            end
        end
        if (previousPeak ~= nil) then
            _previousPeak = source:date(previousPeak);
        end
        if (previousDrawn ~= nil) then
            _previousDrawn = source:date(previousDrawn);
        end
    end
end

