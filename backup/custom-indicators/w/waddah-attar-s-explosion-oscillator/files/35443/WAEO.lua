-- Id: 6770
--+------------------------------------------------------------------+
--|                               Copyright � 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- This is a port of Waddah_Attar_Explosion.mq4 
-- Original indicator Copyright � 2006, Eng. Waddah Attar, waddahattar@hotmail.com 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Waddah Attar's Explosion Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Sen", "Sensitivity", "", 150);
    indicator.parameters:addInteger("DeadZonePip", "Dead Zone in pips", "", 30);
	indicator.parameters:addInteger("Period1", "Short EMA Period", "", 20);
	indicator.parameters:addInteger("Period2", "Long EMA Period", "", 40);
	indicator.parameters:addInteger("Period3", "Calculation Period", "", 20);
	indicator.parameters:addDouble("Dev", "Deviation", "", 2);
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("TG_color", "Color of postive trend", "", core.rgb(0, 192, 0));
    indicator.parameters:addColor("TR_color", "Color of negative trend", "", core.rgb(192, 0, 0));
    indicator.parameters:addColor("E_color", "Color of explosion line", "", core.rgb(128, 64, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Sen;
local DeadZonePip;

local first;
local firstBB;
local source = nil;

-- Streams block
local WAEO = nil;
local E = nil;

local Period1, Period2, Period3;
local EMAF = nil;
local EMAS = nil;
local BB_H = nil;
local BB_L = nil;
local Dev;
-- Routine
function Prepare()
    Sen = instance.parameters.Sen;
    DeadZonePip = instance.parameters.DeadZonePip;
    source = instance.source;
	
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	Dev = instance.parameters.Dev;

    EMAF = core.indicators:create("EMA", source, Period1);
    EMAS = core.indicators:create("EMA", source, Period2);
    first = EMAS.DATA:first() +Period1;
    firstBB = source:first() + Period1;
    BB_H = instance:addInternalStream(firstBB, 0);
    BB_L = instance:addInternalStream(firstBB, 0);

    local name = profile:id() .. "(" .. source:name() .. ", " .. Sen .. ", " .. DeadZonePip .. ", " ..Period1.. ", " ..Period2.. ", " ..Period3.. ", " ..Dev..")";
    instance:name(name);    
    WAEO = instance:addStream("WAEO", core.Bar, name .. ".WAEO", "WAEO", instance.parameters.TR_color, first);
    WAEO:setPrecision(math.max(2, instance.source:getPrecision()));
    E = instance:addStream("E", core.Line, name .. ".E", "E", instance.parameters.E_color, first);
    E:setPrecision(math.max(2, instance.source:getPrecision()));
	E:setWidth(instance.parameters.width);
	E:setStyle(instance.parameters.style);
    E:addLevel(0);
    E:addLevel(DeadZonePip * source:pipSize());
end

-- Indicator calculation routine
function Update(period, mode)
    EMAF:update(mode);
    EMAS:update(mode);

    if period >= firstBB then
       -- local p = core.rangeTo(period, 20);
        local ml = mathex.avg(source, period- Period3+1,period);
        local d = mathex.stdev(source, period- Period3+1,period);
        BB_H[period] = ml + Dev * d;
        BB_L[period] = ml - Dev * d;
    end

    if period >= first then
        local  trend, explosion;
        trend = (MACD(period) - MACD(period - 1)) * Sen;
        explosion = BB_H[period] - BB_L[period];
		
		
        if trend > 0 then
            WAEO[period] = trend;
            WAEO:setColor(period, instance.parameters.TG_color);  
        elseif trend < 0 then
            WAEO[period] = -trend;  
            WAEO:setColor(period, instance.parameters.TR_color);   			
        end
        E[period] = explosion;
    end
end

function MACD(period)
    return EMAF.DATA[period] - EMAS.DATA[period];
end

