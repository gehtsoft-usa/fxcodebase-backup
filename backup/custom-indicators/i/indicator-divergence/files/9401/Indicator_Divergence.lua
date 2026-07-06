-- Id: 3540
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3846

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
    indicator:name("Indicator Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("IN", "Indicator", "", "");
    indicator.parameters:setFlag("IN",core.FLAG_INDICATOR);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
    indicator.parameters:addInteger("Frames", "Frames", "Frames", 5);
    indicator.parameters:addBoolean("I", "Indicator mode", "Keep true value to display labels and lines. Set this parameter to false when the indicator is used in another indicator.", true);
    indicator.parameters:addColor("D_color", "Color of Divergence line", "", core.rgb(0, 155, 255));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
	
	 indicator.parameters:addBoolean("Simple", "Simple Fractal", "", false);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local I;
local DD;
local UP_color;
local DN_color;
local Price;
local Frames;
local Simple;
local first;
local source = nil;

-- Streams block
local D = nil;
local UP = nil;
local DN = nil;
local Ind = nil;
local lineid = nil;

-- Routine
function Prepare(nameOnly)
    I = instance.parameters.I;
    DD = instance.parameters.DD;
    Price = instance.parameters.Price;
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
	Simple = instance.parameters.Simple;
    Frames = instance.parameters.Frames;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.IN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    local ind_ = core.indicators:findIndicator(instance.parameters:getString("IN"));
    local params = instance.parameters:getCustomParameters("IN");
    if  ind_:requiredSource() == core.Tick then
     if Price=="close" then
      Ind = ind_:createInstance(source.close, params);
     elseif Price=="open" then
      Ind = ind_:createInstance(source.open, params);
     elseif Price=="high" then
      Ind = ind_:createInstance(source.high, params);
     elseif Price=="low" then
      Ind = ind_:createInstance(source.low, params);
     elseif Price=="median" then
      Ind = ind_:createInstance(source.median, params);
     elseif Price=="typical" then
      Ind = ind_:createInstance(source.typical, params);
     else
      Ind = ind_:createInstance(source.weighted, params);
     end
    else
     Ind = ind_:createInstance(source, params);
    end 
    first = Ind.DATA:first();

    D = instance:addStream(instance.parameters.IN, core.Line, name .. "." .. instance.parameters.IN, instance.parameters.IN, instance.parameters.D_color, first, -1);
    D:setPrecision(math.max(2, instance.source:getPrecision()));
    if I then
        UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
        DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
    else
        UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.D_color, first, -1);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
        DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.D_color, first, -1);
    DN:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)


   period = period - 1;
    --size
	
	-- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
	
    pperiod1 = source:serial(period)
  

    Ind:update(mode);
    if period >= first then
        D[period] = Ind.DATA[period];
		
		 if Simple then
		            if period >= first + 2 then
						processBullish(period-1);
						processBearish(period-1);
					end
		 else
					if period >= first + 2 then
						processBullish(period - 2);
						processBearish(period - 2);
					end
	     end
    end
end

function processBullish(period)
    if isTrough(period) then
        local curr, prev;
        curr = period;
        prev = prevTrough(period);
        if prev ~= nil then
            if Ind.DATA[curr] > Ind.DATA[prev] and source.low[curr] < source.low[prev] then
                if I then
                    DN:set(curr, Ind.DATA[curr], "\225", "Classic bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Ind.DATA[prev], source:date(curr), Ind.DATA[curr], DN_color);
                else
                    DN[period] = curr - prev;
                end
            elseif Ind.DATA[curr] < Ind.DATA[prev] and source.low[curr] > source.low[prev] then
                if I then
                    DN:set(curr, Ind.DATA[curr], "\225", "Reversal bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Ind.DATA[prev], source:date(curr), Ind.DATA[curr], DN_color);
                else
                    DN[period] = -(curr - prev);
                end
            end
        end

    end
end

function isTrough(period)
    local i;
    if Ind.DATA[period] < Ind.DATA[period - 1] and Ind.DATA[period] < Ind.DATA[period + 1] then
        for i = period - 1, period-Frames, -1 do
            if i<=first then
             return true;
            end
            if Ind.DATA[period]>Ind.DATA[i] then
             return false;
            end
        end
        return true;
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if Ind.DATA[i] <= Ind.DATA[i - 1] 
		and (Ind.DATA[i] < Ind.DATA[i - 2] or Simple)
		and Ind.DATA[i] <= Ind.DATA[i + 1]
		and (Ind.DATA[i] < Ind.DATA[i + 2] or Simple)
		then
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
            if Ind.DATA[curr] < Ind.DATA[prev] and source.high[curr] > source.high[prev] then
                if I then
                    UP:set(curr, Ind.DATA[curr], "\226", "Classic bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Ind.DATA[prev], source:date(curr), Ind.DATA[curr], UP_color);
                else
                    UP[period] = curr - prev;
                end
            elseif Ind.DATA[curr] > Ind.DATA[prev] and source.high[curr] < source.high[prev] then
                if I then
                    UP:set(curr, Ind.DATA[curr], "\226", "Reversal bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Ind.DATA[prev], source:date(curr), Ind.DATA[curr], UP_color);
                else
                    UP[period] = -(curr - prev);
                end
            end
        end

    end
end

function isPeak(period)
    local i;
    if Ind.DATA[period] > Ind.DATA[period - 1]
	and Ind.DATA[period] > Ind.DATA[period + 1] 
	then
        for i = period - 1, period-Frames, -1 do
            if i<=first then
             return true;
            end
            if Ind.DATA[period]<Ind.DATA[i] then
             return false;
            end
        end
        return true;
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if Ind.DATA[i] >= Ind.DATA[i - 1]
		and (Ind.DATA[i] > Ind.DATA[i - 2] or Simple)		
		and Ind.DATA[i] >= Ind.DATA[i + 1] 
		and (Ind.DATA[i] > Ind.DATA[i + 2] or Simple)
		then
           return i;
        end
    end
    return nil;
end
