-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3870

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
    indicator:name("Printout Indicator");
    indicator:description("The indicator shows the current value of chosen indicator for all subscribed currencies");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Indicator Parameters");
    indicator.parameters:addString("Indicator", "Indicator", "", "MVA");
    indicator.parameters:setFlag("Indicator", core.FLAG_INDICATOR);
    indicator.parameters:addInteger("Stream", "The index of the indicator output", "", 0, 0, 10);
    indicator.parameters:addString("Source", "The source for tick indicators", "", "close");
    indicator.parameters:addStringAlternative("Source", "Open", "", "open");
    indicator.parameters:addStringAlternative("Source", "High", "", "high");
    indicator.parameters:addStringAlternative("Source", "Low", "", "low");
    indicator.parameters:addStringAlternative("Source", "Close", "", "close");
    indicator.parameters:addStringAlternative("Source", "Median", "", "median");
    indicator.parameters:addStringAlternative("Source", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("Source", "Weighted", "", "weighted");

    indicator.parameters:addGroup("Update Parameters");
    indicator.parameters:addInteger("Timeout", "The update timeout in seconds", "", 1, 1, 3600);
    indicator.parameters:addInteger("Bar", "Bar to show", "", 1, 0, 1);
    indicator.parameters:addIntegerAlternative("Bar", "Recent", "", 0);
    indicator.parameters:addIntegerAlternative("Bar", "Current", "", 1);

    indicator.parameters:addGroup("Display Parameters");
    indicator.parameters:addInteger("Sort", "Sort the list", "", 0, 0, 2);
    indicator.parameters:addIntegerAlternative("Sort", "As Instruments", "", 0);
    indicator.parameters:addIntegerAlternative("Sort", "Low to High", "", 1);
    indicator.parameters:addIntegerAlternative("Sort", "High to Low", "", 2);

    indicator.parameters:addInteger("FontSize", "Size of font in points", "", 8, 6, 12);
    indicator.parameters:addColor("Color", "Default Color", "", core.COLOR_LABEL);
    indicator.parameters:addColor("UpColor", "Up Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("DnColor", "Dn Color", "", core.COLOR_DOWNCANDLE);
    indicator.parameters:addInteger("Rows", "Number of instrument per column", "", 10, 6, 20);
    indicator.parameters:addDouble("Width", "Width factor (% of height)", "Use this parameter is columns overlaps or too loose", 0.7, 0.1, 100);
end


local instruments = {};
local timer, font;
local color, upcolor, dncolor, rows, width, live, height;
local sort;

function Prepare(onlyName)
    local name;

    local iprofile = core.indicators:findIndicator(instance.parameters.Indicator);
    local inst;
    local ext = "";

    assert(iprofile ~= nil, "Please download and install " .. instance.parameters.Indicator .. ".lua indicator");

    if iprofile:requiredSource() ~= core.Bar then
        ext = "," .. instance.parameters.Source;
    end
    live = (instance.parameters.Bar == 1);
    if live then
        ext = ext .. ",current";
    else
        ext = ext .. ",recent";
    end

    name = profile:id() .. "(" .. instance.parameters.Indicator .. "," .. instance.source:barSize() .. ext .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
    
    local params = instance.parameters:getCustomParameters("Indicator");
    if params == nil then
        params = iprofile:parameters();
    end

    if iprofile:requiredSource() == core.Bar then
        inst = iprofile:createInstance(instance.source, params);
    else
        inst = iprofile:createInstance(instance.source[instance.parameters.Source], params);
    end

    assert(instance.parameters.Stream < inst:getStreamCount(), "The index of the indicator output must be between 0 and " .. inst:getStreamCount());

    if not instance.source:isAlive() then
        assert(false, "The indicator must be applied on live market data only");
    end

    -- apply indicator(s) and subscribe
    local i, list, count, instr;
    list, count = getInstrumentList();

    for i = 1, count, 1 do
        instr = {};
        instr.name = list[i];
        if list[i] == instance.source:instrument() then
            instr.source = instance.source;
            instr.loaded = true;
        else
            instr.source = core.host:execute("getHistory", i, list[i], instance.source:barSize(), 0, 0, instance.source:isBid());
            instr.loaded = true;
        end


        if iprofile:requiredSource() == core.Bar then
            instr.indi_source = instr.source;
        else
            instr.indi_source = instr.source[instance.parameters.Source];
        end

        params = instance.parameters:getCustomParameters("Indicator");
        if params == nil then
            params = iprofile:parameters();
        end

        instr.indi = iprofile:createInstance(instr.indi_source, params);
        instr.data = instr.indi:getStream(instance.parameters.Stream);
        instr.first = instr.data:first();
        instr.format = "%." .. instr.data:getPrecision() .. "f";
        instr.precision = math.floor(math.pow(10, instr.data:getPrecision()) + 0.5);
        instr.last = nil;

        instruments[i] = instr;
    end
    instruments.count = count;

    height = instance.parameters.FontSize;
    timer = core.host:execute("setTimer", 1000, instance.parameters.Timeout);
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, false, false);
    color = instance.parameters.Color;
    upcolor = instance.parameters.UpColor;
    dncolor = instance.parameters.DnColor;
    rows = instance.parameters.Rows;
    width = instance.parameters.Width;
    sort = instance.parameters.Sort;
end


function getInstrumentList()
    local list = {};
    local count = 0;

    local enum, row;
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1000 then
        UpdateIndicator();
        return core.ASYNC_REDRAW;
    else
        if instruments[cookie] ~= nil then
            instruments[cookie].loaded = true;
            UpdateIndicator();
            return core.ASYNC_REDRAW;
        end
    end
    return nil;
end

function Update(period, mode)
end

function UpdateIndicator()
    local i, c, instr, row, col, dat, clr, p, v;
    c = instruments.count;
    for i = 1, c, 1 do
        instr = instruments[i];
        if not instr.loaded then
            dat = "n/a";
            clr = color;
            v = nil;
        else
            instr.indi:update(core.UpdateLast);
            if live then
                p = instr.data:size() - 1;
            else
                p = instr.data:size() - 2;
            end

            if p > instr.first and instr.data:hasData(p) then
                v = round(instr.data[p], instr.precision);
                dat = string.format(instr.format, v);
                if instr.last == nil or instr.last == v then
                    clr = color;
                elseif instr.last > v then
                    clr = dncolor;
                elseif instr.last < v then
                    clr = upcolor;
                end

                if live then
                    instr.last = v;
                else
                    if instr.lastSerial == nil or instr.lastSerial ~= instr.source:serial(p) then
                        instr.lastSerial = instr.source:serial(p);
                        instr.last = v;
                    end
                end
            else
                dat = "n/a";
                clr = color;
                v = nil;
            end
        end
        instr.dat = dat;
        instr.clr = clr;
        instr.v = v;
    end

    if sort == 1 then
        table.sort(instruments, lowToHigh);
    elseif sort == 2 then
        table.sort(instruments, highToLow);
    end

    for i = 1, c, 1 do
        instr = instruments[i];
        col = math.floor((i - 1) / rows);
        row = (i - 1) - col * rows;
        row = row + 1;
        core.host:execute("drawLabel1", i * 2,
                          col * height * 15 * width, core.CR_LEFT,
                          row * height * 1.2, core.CR_TOP,
                          core.H_Right, core.V_Bottom,
                          font, color,
                          instr.name);
        core.host:execute("drawLabel1", i * 2 + 1,
                          (col + 1) * height * 15 * width - height * width, core.CR_LEFT,
                          row * height * 1.2, core.CR_TOP,
                          core.H_Left, core.V_Bottom,
                          font, instr.clr,
                          instr.dat);
    end

end

function lowToHigh(a, b)
    if a.v == nil and b.v ~= nil then
        return true;
    elseif a.v ~= nil and b.v ~= nil then
        return a.v < b.v;
    else
        return false;
    end
end

function highToLow(a, b)
    if a.v ~= nil and b.v == nil then
        return true;
    elseif a.v ~= nil and b.v ~= nil then
        return a.v > b.v;
    else
        return false;
    end
end

function round(value, precision)
    return math.floor(value * precision + 0.5) / precision;
end

function ReleaseInstance()
    core.host:execute("deleteFont", font);
    core.host:execute("killTimer", timer);
end
