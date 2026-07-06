-- Id: 16359

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63669

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

-- Local variables
local source;
local host;
local lastSerial;
local length;
local length1;
local length2;
local out1;
local out2;
local out3;
local out4;
local top;
local bottom;
local centre;
local buy;
local sell;
local text;
local obos1;
local obos2;
local leftStrength;
local rightStrength;
local window;
local canAlert;
local showAlert;
local playSound;
local soundFile;
local sendEmail;
local email;
local lineId;
local displacement1;
local displacement2;
local trades = {};

-- Create the indicator's profile
function Init()
    indicator:name("OBOS Divergence Indicator");
    indicator:description("OBOS Divergence Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    --indicator:type(core.Indicator);
    --indicator:setTag("group", "TBD");
    --indicator:setTag("replaceSource", "t");

    local colour = core.colors();

    -- Calculation parameters
    indicator.parameters:addGroup("Calculation parameters");
    indicator.parameters:addInteger("period1", "Primary OBOS period", "", 10,1,9999);
    indicator.parameters:addInteger("period2", "Secondary OBOS period", "", 15,1,9999);
    indicator.parameters:addInteger("obLevel", "Over-bought level", "", 100);
    indicator.parameters:addInteger("osLevel", "Over-sold level", "", -100);

    indicator.parameters:addInteger("window", "Window", "", 10, 1, 1000);
    indicator.parameters:addInteger("leftStrength", "Left strength", "", 1);
    indicator.parameters:addInteger("rightStrength", "Right strength", "", 1);

    indicator.parameters:addBoolean("zeroFilter", "Zero filter", "", true);
    indicator.parameters:addBoolean("redFilter", "Red-line filter", "", true);
    indicator.parameters:addBoolean("blueFilter", "Blue-line filter", "", true);

    indicator.parameters:addInteger("duration", "Trade duration", "", 10, 1, 1000);

    -- Display options
    indicator.parameters:addGroup("Display options");
	indicator.parameters:addBoolean("SignalMode", "Signal Mode", "", false);
    indicator.parameters:addBoolean("showText", "Show P/L text", "", true);
    indicator.parameters:addBoolean("showVerticals", "Show vertical lines", "", true);
    indicator.parameters:addBoolean("showExitArrow", "Show exit arrow", "", true);
    
    -- Colours and effects
    indicator.parameters:addGroup("Colours and effects");
    indicator.parameters:addColor("colour1", "Primary OBOS colour", "", colour.Magenta);
    indicator.parameters:addColor("colour2", "Secondary OBOS colour", "", colour.Orange);
    indicator.parameters:addColor("zeroColour", "Zero line colour", "", colour.Gray);
    indicator.parameters:addColor("obColor", "Over-bought line colour", "", colour.Gray);
    indicator.parameters:addColor("osColor", "Over-sold line colour", "", colour.Gray);
    indicator.parameters:addColor("topColour", "Top fractal colour", "", colour.Red);
    indicator.parameters:addColor("bottomColour", "Bottom fractal colour", "", colour.Blue);
    indicator.parameters:addColor("bellColour", "Bell colour", "", colour.Black);
    indicator.parameters:addColor("redColour", "Red-line colour", "", colour.Red);
    indicator.parameters:addColor("blueColour", "Blue-line colour", "", colour.Cyan);
    indicator.parameters:addColor("buyColour", "Buy colour", "", colour.Lime);
    indicator.parameters:addColor("sellColour", "Sell colour", "", colour.Red);
    indicator.parameters:addColor("textColour", "P/L text colour", "", colour.Black);
    indicator.parameters:addInteger("width1", "Line width 1", "", 2);
    indicator.parameters:addInteger("width2", "Line width 2", "", 1);
    indicator.parameters:addInteger("fontSize1", "Font size (fractals)", "", 10);
    indicator.parameters:addInteger("fontSize2", "Font size (buy/sell/bell)", "", 10);
    indicator.parameters:addInteger("fontSize3", "Font size (P/L text)", "", 10);
    indicator.parameters:addInteger("displacement1", "Displacement (fractals)", "", 0);
    indicator.parameters:addInteger("displacement2", "Displacement (text)", "", 0);

    -- Notification options
    indicator.parameters:addGroup("Notification options");
    indicator.parameters:addBoolean("showAlert", "Show alert", "", false);
    indicator.parameters:addBoolean("playSound", "Play sound", "", false);
    indicator.parameters:addFile("soundFile", "Sound file", "", "");
    indicator.parameters:setFlag("soundFile", core.FLAG_SOUND);
    indicator.parameters:addBoolean("sendEmail", "Send email", "", true);
    indicator.parameters:addString("email", "E-mail address", "", "");
    indicator.parameters:setFlag("email", core.FLAG_EMAIL);
end

local SignalMode,Signal;

-- Create a new instance of the indicator
function Prepare(nameOnly)
    -- Create locals for these commonly used variables
    source = instance.source;
    host = core.host;
    length1 = instance.parameters.period1;
    length2 = instance.parameters.period2;
	SignalMode = instance.parameters.SignalMode;

	-- Set the indicator name
    local name = string.format("%s(%s, %d, %d)", profile:id(), instance.source:name(), length1, length2);
    instance:name(name);

    if nameOnly then
        return
    end

    -- Initialize variables
    lastSerial = nil;
    length = math.max(length1, length2);
    host = core.host;
    leftStrength = instance.parameters.leftStrength;
    rightStrength = instance.parameters.rightStrength;
    window = instance.parameters.window;
    lineId = 1;
    displacement1 = instance.parameters.displacement1;
    displacement2 = instance.parameters.displacement2 * source:pipSize();
    trades = {};

    assert(core.indicators:findIndicator("OBOS_INDICATOR") ~= nil, "Please, download and install OBOS_INDICATOR.LUA indicator");
	
	if SignalMode then
	Signal = instance:addStream("Signal", core.Bar, name..".Signal", "Signal",  core.rgb(0, 0, 0), source:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	Signal = instance:addInternalStream( source:first(),  0);
	end
	
    out1 = instance:addStream("OBOS1", core.Line, name..".OBOS1", "OBOS1", instance.parameters.colour1, source:first());
    out1:setPrecision(2);
    out1:setWidth(instance.parameters.width1);
    out2 = instance:addStream("OBOS2", core.Line, name..".OBOS2", "OBOS2", instance.parameters.colour2, source:first());
    out2:setPrecision(2);
    out2:setWidth(instance.parameters.width1);
    
    out3 = instance:addStream("RED", core.Line, name.."RED", "RED", instance.parameters.redColour, source:first());
    out3:setPrecision(math.max(2, instance.source:getPrecision()));
    out3:setWidth(instance.parameters.width2);
    
    out4 = instance:addStream("BLUE", core.Line, name.."BLUE", "BLUE", instance.parameters.blueColour, source:first());
    out4:setPrecision(math.max(2, instance.source:getPrecision()));
    out4:setWidth(instance.parameters.width2);

    top = instance:createTextOutput("TF", "TF", "Wingdings 3", instance.parameters.fontSize1, core.H_Center, core.V_Top, instance.parameters.topColour);
    bottom = instance:createTextOutput("BF", "BF", "Wingdings 3", instance.parameters.fontSize1, core.H_Center, core.V_Bottom, instance.parameters.bottomColour);
    centre = instance:createTextOutput("ALERT", "ALERT", "Wingdings", instance.parameters.fontSize2, core.H_Center, core.V_Center, instance.parameters.bellColour);

    sell = instance:createTextOutput("SELL", "SELL", "Wingdings", instance.parameters.fontSize2, core.H_Center, core.V_Top, instance.parameters.sellColour);
    host:execute ("attachTextToChart", "SELL");
    buy = instance:createTextOutput("BUY", "BUY", "Wingdings", instance.parameters.fontSize2, core.H_Center, core.V_Bottom, instance.parameters.buyColour);
    host:execute ("attachTextToChart", "BUY");
    text = instance:createTextOutput("TEXT", "TEXT", "Verdana", instance.parameters.fontSize3, core.H_Right, core.V_Center, instance.parameters.textColour);
    host:execute ("attachTextToChart", "TEXT");
    
    -- Add levels
    out1:addLevel(0, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.zeroColour);
    out1:addLevel(instance.parameters.obLevel, core.LINE_DOT, 1, instance.parameters.obColor);
    out1:addLevel(instance.parameters.osLevel, core.LINE_DOT, 1, instance.parameters.osColor);

    -- Indicators
    obos1 = core.indicators:create("OBOS_INDICATOR", source, length1);
    obos2 = core.indicators:create("OBOS_INDICATOR", source, length2);

    -- Alerts
    canAlert = false;
    showAlert = instance.parameters.showAlert;
    playSound = instance.parameters.playSound;
    sendEmail = instance.parameters.sendEmail;
    
    if instance.parameters.playSound then
        soundFile = instance.parameters.soundFile;
        assert(soundFile ~= "", "Sound file not specified");
    else
        soundFile = nil;
    end
    
    if instance.parameters.sendEmail then
        email = instance.parameters.email;
        assert(email ~= "", "Email name must be specified");
    else
        email = nil;
    end
end

-- Update the indicator
function Update(period, mode)
    if period < source:first() then
        return;
    elseif period == source:first() then
        -- Initialize variables
        lastSerial = nil;
        canAlert = false;
        lineId = 1;
        trades = {};

        -- Clear all previous graphics
        host:execute("removeAll");
    end

    -- Update indicators
    obos1:update(mode);
    obos2:update(mode);

    -- Outputs
    out1[period] = obos1.MID[period];
    out2[period] = obos2.MID[period];
    
    -- Wait for enough data
    if period < source:first() + length + leftStrength + rightStrength then
        return;
    end

    -- Wait for a new bar
    if source:serial(period) == lastSerial then
        return;
    end
    lastSerial = source:serial(period);

    if period == source:size() - 1 then
        canAlert = true;
    end
    
    -- Always checking last bar
    period = period - 1;

    -- Check trades
    for i = #trades,1,-1 do
        local t = trades[i];

        -- Increment counter
        t[1] = t[1] + 1;
        trades[i] = t;

        -- Check for end of trade
        if t[1] == instance.parameters.duration then
            local profit;
            if t[2] == "Buy" then
                local profit = (source.close[period] - t[3]) / source:pipSize();
                local s = string.format("%0.1f", profit);
                if profit > 0 then
                    s = "+"..s;
                end
                if instance.parameters.showExitArrow then
                    sell:set(period, source.close[period], "\234", s);
                end
                if instance.parameters.showText then
                    text:set(period, source.close[period] + displacement2, s);
                end
                if instance.parameters.showVerticals then
                    local colour;
                    if profit >= 0 then
                        colour = instance.parameters.buyColour;
                    else
                        colour = instance.parameters.sellColour;
                    end
                    host:execute("drawLine", lineId, source:date(period), -200, source:date(period), 200, colour, core.LINE_SOLID, instance.parameters.width2);
                    lineId = lineId + 1;
                end
            elseif t[2] == "Sell" then
                local profit = (t[3] - source.close[period]) / source:pipSize();
                local s = string.format("%0.1f", profit);
                if profit > 0 then
                    s = "+"..s;
                end
                if instance.parameters.showExitArrow then
                    buy:set(period, source.close[period], "\233", s);
                end
                if instance.parameters.showText then
                    text:set(period, source.close[period] - displacement2, s);
                end
                if instance.parameters.showVerticals then
                    local colour;
                    if profit >= 0 then
                        colour = instance.parameters.buyColour;
                    else
                        colour = instance.parameters.sellColour;
                    end
                    host:execute("drawLine", lineId, source:date(period), -200, source:date(period), 200, colour, core.LINE_SOLID, instance.parameters.width2);
                    lineId = lineId + 1;
                end
            end
            table.remove(trades, i);
        end
    end

    local alert = false;
    local message = "test";

    if checkPivotHigh(obos1.MID, period, leftStrength, rightStrength) then
        local p2 = period - rightStrength;
        top:set(p2, obos1.MID[p2] + instance.parameters.displacement1, "\112");

        -- Bearish divergence logic
        -- 1: Look for up-down-up fractal pattern
        -- 2: Let 1st up be point A, 2nd up be point B
        -- 3: OBOS1[A] > OBOS2[A] and OBOS1[B] < OBOS2[B]
        local state = 1;
        local a2 = obos1.MID[p2];
        local b2 = obos2.MID[p2];
        for i = 1,window do
            if state == 1 then
                if checkPivotLow(obos1.MID, period - i, leftStrength, rightStrength) then
                    state = 2;
                elseif checkPivotHigh(obos1.MID, period - i, leftStrength, rightStrength) then
                    break;
                end
            elseif state == 2 then
                if checkPivotHigh(obos1.MID, period - i, leftStrength, rightStrength) then
                    state = 1;
                    local p1 = period - i - rightStrength;
                    a1 = obos1.MID[p1];
                    b1 = obos2.MID[p1];

                    if a1 > b1 and a2 < b2 then
                        --host:trace(string.format("a1 = %0.1f, b1 = %0.1f, a2 = %0.1f, b2 = %0.1f", a1, b1, a2, b2));
                        if instance.parameters.zeroFilter and not (a1 > 0 and b1 > 0 and a2 > 0 and b2 > 0) then
                            break;
                        end
                        if instance.parameters.blueFilter and not (b2 > a1) then
                            break;
                        end
                        if instance.parameters.redFilter and not (a2 < a1) then
                            break;
                        end
                        alert = true;
                        message = "Bearish alert";
                        centre:set(period, obos1.MID[period] + instance.parameters.displacement1, "\37", message);

                        local range = core.range(p1, p2);
                        core.drawLine(out3, range, a1, p1, a2, p2);
                        core.drawLine(out4, range, a1, p1, b2, p2);
                   
                        lineId = lineId + 4;

                        local t = { 0, "Sell", source.close[period], source:date(period) };
                        table.insert(trades, 1, t);

                        sell:set(period, source.close[period], "\234", "Sell");
						
						Signal[period]=-1;
                    end
                    break;
                elseif checkPivotLow(obos1.MID, period - i, leftStrength, rightStrength) then
                    break;
                end
            end
        end
    end

    if checkPivotLow(obos1.MID, period, leftStrength, rightStrength ) then
        local p2 = period - rightStrength;
        bottom:set(p2, obos1.MID[p2] - instance.parameters.displacement1, "\113");

        -- Bullish divergence logic
        -- 1: Look for down-up-down fractal pattern
        -- 2: Let 1st up be point A, 2nd up be point B
        -- 3: OBOS1[A] < OBOS2[A] and OBOS1[B] > OBOS2[B]
        local state = 1;
        local a2 = obos1.MID[p2];
        local b2 = obos2.MID[p2];
        for i = 1,window do
            if state == 1 then
                if checkPivotHigh(obos1.MID, period - i, leftStrength, rightStrength) then
                    state = 2;
                elseif checkPivotLow(obos1.MID, period - i, leftStrength, rightStrength) then
                    break;
                end
            elseif state == 2 then
                if checkPivotLow(obos1.MID, period - i, leftStrength, rightStrength) then
                    state = 1;
                    local p1 = period - i - rightStrength;
                    a1 = obos1.MID[p1];
                    b1 = obos2.MID[p1];

                    if a1 < b1 and a2 > b2 then
                        --host:trace(string.format("a1 = %0.1f, b1 = %0.1f, a2 = %0.1f, b2 = %0.1f", a1, b1, a2, b2));
                        if instance.parameters.zeroFilter and not (a1 < 0 and b1 < 0 and a2 < 0 and b2 < 0) then
                            break;
                        end
                        if instance.parameters.blueFilter and not (b2 < a1) then
                            break;
                        end
                        if instance.parameters.redFilter and not (a2 > a1) then
                            break;
                        end
                        alert = true;
                        message = "Bullish alert";
                        centre:set(period, obos1.MID[period] - instance.parameters.displacement1, "\37", message);

                        local range = core.range(p1, p2);
                        core.drawLine(out3, range, a1, p1, a2, p2);
                        core.drawLine(out4, range, a1, p1, b2, p2); 
                        lineId = lineId + 4;

                        local t = { 0, "Buy", source.close[period], source:date(period) };
                        table.insert(trades, 1, t);

                        buy:set(period, source.close[period], "\233", "Buy");
						Signal[period]=1;
                    end
                    break;
                elseif checkPivotHigh(obos1.MID, period - i, leftStrength, rightStrength) then
                    break;
                end
            end
        end
    end

    if canAlert and alert then
        local price;
        if source:isBar() then
            price = source.close[period];
        else
            price = source[period];
        end
        local date = source:date(period);
        if showAlert then
            terminal:alertMessage(source:instrument(), price, message, date);
        end
        if playSound then
            terminal:alertSound(soundFile, false);
        end
        if sendEmail then
            local subject = string.format("OBOS Divergence (%s, %s)", source:instrument(), source:barSize());
            local body = string.format("%s, %g, %s", message, price, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_LOCAL, date)));
            --host:trace(string.format("e(%s), s(%s), b(%s)", email, subject, body));
            terminal:alertEmail(email, subject, body);
        end
    end
end

-- Release the indicator
function ReleaseInstance()
    -- Nothing to do yet
end

-- Handle asynchronous events
function AsyncOperationFinished(cookie, success, message)
    -- Nothing to do yet
end

-- Check for high pivot
function checkPivotHigh(source, period, leftStrength, rightStrength)
    local p = period - rightStrength;

    -- Check for new pivot
    local value = source[p];
    for i = 1, leftStrength do
        if not (value >= source[p - i]) then
            return false;
        end
    end
    for i = 1, rightStrength do
        if not (value > source[p + i]) then
            return false;
        end
    end

    return true;
end

 -- Check for low pivot
function checkPivotLow(source, period, leftStrength, rightStrength)
    local p = period - rightStrength;

    -- Check for new pivot
    local value = source[p];
    for i = 1, leftStrength do
        if not (value <= source[p - i]) then
            return false;
        end
    end
    for i = 1, rightStrength do
        if not (value < source[p + i]) then
            return false;
        end
    end

    return true;
end