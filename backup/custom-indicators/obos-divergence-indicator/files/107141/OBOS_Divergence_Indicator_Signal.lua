-- Id: 19248

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

local length;
local length1;
local length2;

local obos1;
local obos2;
local leftStrength;
local rightStrength;
local window;

-- Create the indicator's profile
function Init()
    indicator:name("OBOS Divergence Indicator");
    indicator:description("OBOS Divergence Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


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


end

local Signal;

-- Create a new instance of the indicator
function Prepare(nameOnly)
    -- Create locals for these commonly used variables
    source = instance.source;
    host = core.host;
    length1 = instance.parameters.period1;
    length2 = instance.parameters.period2;
	

	-- Set the indicator name
    local name = string.format("%s(%s, %d, %d)", profile:id(), instance.source:name(), length1, length2);
    instance:name(name);

    if nameOnly then
        return
    end

    -- Initialize variables
    
    length = math.max(length1, length2);
    host = core.host;
    leftStrength = instance.parameters.leftStrength;
    rightStrength = instance.parameters.rightStrength;
    window = instance.parameters.window;
    


    assert(core.indicators:findIndicator("OBOS_INDICATOR") ~= nil, "Please, download and install OBOS_INDICATOR.LUA indicator");
	

	Signal = instance:addStream("Signal", core.Bar, name..".Signal", "Signal",  core.rgb(0, 0, 0), source:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
 


    -- Indicators
    obos1 = core.indicators:create("OBOS_INDICATOR", source, length1);
    obos2 = core.indicators:create("OBOS_INDICATOR", source, length2);

    
end

-- Update the indicator
function Update(period, mode)
    if period < source:first() then
        return;
    
    end

    -- Update indicators
    obos1:update(mode);
    obos2:update(mode);

    
    -- Always checking last bar
    period = period - 1;



    if checkPivotHigh(obos1.MID, period, leftStrength, rightStrength) then
        local p2 = period - rightStrength;
      

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
                      
						Signal[period]=1;
                    end
                    break;
                elseif checkPivotHigh(obos1.MID, period - i, leftStrength, rightStrength) then
                    break;
                end
            end
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
    if p - leftStrength < 0 then
        return false;
    end

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
    if p - leftStrength < 0 then
        return false;
    end

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