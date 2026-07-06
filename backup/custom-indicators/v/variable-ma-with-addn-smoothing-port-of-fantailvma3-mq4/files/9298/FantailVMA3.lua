-- Id: 3506
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3812

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
    indicator:name("Fantail VMA");
    indicator:description("A port of FantailVMA3.mq4 by IgorAD, igorad2003@yahoo.co.uk");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("AdxN", "Number of periods for ADX", "The value must be between 2 and 8, 2 for fast, 8 for slow", 2, 2, 8);
    indicator.parameters:addDouble("Weight", "Weigting factor", "The value must be between 1 and 8, 1 for fast, 8 for slow", 2, 1, 8);
    indicator.parameters:addString("Smooth", "Smooth VMA", "", "NO");
    indicator.parameters:addStringAlternative("Smooth", "Don't Smooth", "", "NO");
    indicator.parameters:addStringAlternative("Smooth", "(SMA) Simple Moving Average", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth", "(EMA) Exponential Moving Average", "", "EMA");
    indicator.parameters:addStringAlternative("Smooth", "(LWMA) Linear-weighted Moving Average", "", "LWMA");
    indicator.parameters:addStringAlternative("Smooth", "(LSMA) Least Square Moving Average (Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("Smooth", "(SMMA) Smoothed Moving Average", "", "SMMA");
    indicator.parameters:addStringAlternative("Smooth", "(WMA) Wilders Smooth", "", "WMA");
    indicator.parameters:addInteger("MaN", "Number of periods for smoothing", "", 2, 2, 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local source;
local firstsrc, firstdi, firstvma;
local str, spdi, smdi, adx, vma;
local indi, out, firstindi;
local adxn, weight;

function Prepare(onlyName)
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.AdxN .. "," .. instance.parameters.Weight;
    if instance.parameters.Smooth ~= "NO" then
        name = name .. "," .. instance.parameters.Smooth .. "(" .. instance.parameters.MaN .. ")";
    end
    name = name .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    weight = instance.parameters.Weight;
    adxn = instance.parameters.AdxN;

    source = instance.source;
    firstdi = source:first() + 1;
    firstvma = firstdi + adxn + 64;
    str = instance:addInternalStream(firstdi, 0);
    spdi = instance:addInternalStream(firstdi, 0);
    smdi = instance:addInternalStream(firstdi, 0);
    adx = instance:addInternalStream(firstdi, 0);
    if instance.parameters.Smooth == "NO" then
        indi = nil;
        vma = instance:addStream("VMA", core.Line, name .. ".VMA", "VMA", instance.parameters.MainClr, firstvma);
        vma:setWidth(instance.parameters.widthLinReg);
        vma:setStyle(instance.parameters.styleLinReg);
    else
        vma = instance:addInternalStream(firstvma, 0);
    assert(core.indicators:findIndicator(instance.parameters.Smooth) ~= nil, instance.parameters.Smooth .. " indicator must be installed");
        indi = core.indicators:create(instance.parameters.Smooth, vma, instance.parameters.MaN);
        firstindi = indi.DATA:first();
        out = instance:addStream("VMA", core.Line, name .. ".VMA", "VMA", instance.parameters.MainClr, firstindi);
        out:setWidth(instance.parameters.widthLinReg);
        out:setStyle(instance.parameters.styleLinReg);
    end

end

function Update(period, mode)
    local bulls, bears, tr, pdi, mdi, dx, adxmin, adxmax, diff, c;

    if period >= firstdi then
        local hi, low, hi1, lo1, c1;
        hi = source.high[period];
        hi1 = source.high[period - 1];
        lo = source.low[period];
        lo1 = source.low[period - 1];
        c1 = source.close[period - 1];
        tr = math.max(hi - lo, hi - c1);
        bulls = 0.5 * (math.abs(hi - hi1) + (hi- hi1));
        bears = 0.5 * (math.abs(lo1 - lo) + (lo1 - lo));
        if bulls > bears then
            bears = 0;
        elseif bulls < bears then
            bulls = 0;
        elseif bulls == bears then
            bulls = 0;
            bears = 0;
        end

        if period == firstdi then
            spdi[period] = bulls;
            smdi[period] = bears;
            str[period] = tr;
        else
            str[period] = (weight * str[period - 1] + tr) / (weight + 1);
            spdi[period] = (weight * spdi[period - 1] + bulls) / (weight + 1);
            smdi[period] = (weight * smdi[period - 1] + bears) / (weight + 1);
        end

        if str[period] > 0 then
            pdi = spdi[period];
            mdi = smdi[period];
        else
            pdi = spdi[period - 1];
            mdi = smdi[period - 1];
        end
        if pdi + mdi > 0 then
            dx = math.abs(pdi - mdi) / (pdi + mdi);
        else
            dx = 0;
        end

        if period == firstdi then
            adx[period] = dx;
        else
            adx[period] = (weight * adx[period - 1] + dx) / (weight + 1);
        end

        if period >= firstvma then
            adxmin, adxmax = mathex.minmax(adx, period - adxn + 1, period);
            diff = adxmax - adxmin;
            if diff > 0 then
                c = (adx[period] - adxmin) / diff;
            else
                c = 0;
            end

            if period == firstvma then
                vma[period] = source.close[period];
            else
                vma[period] = ((2 - c) * vma[period - 1] + c * source.close[period]) / 2;
            end
        end

        if indi ~= nil and period >= firstindi then
            indi:update(core.UpdateLast);
            out[period] = indi.DATA[period];
        end
    end
end
