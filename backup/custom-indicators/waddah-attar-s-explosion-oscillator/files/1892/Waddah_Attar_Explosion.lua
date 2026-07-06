-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1011
-- Id: 671
 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

-- This is a port of Waddah_Attar_Explosion.mq4 
-- Original indicator Copyright � 2006, Eng. Waddah Attar, waddahattar@hotmail.com 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Waddah Attar's Explosion Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "ATR Period", "", 7);	
    indicator.parameters:addInteger("Period1", "Fast Period", "", 20);	
    indicator.parameters:addInteger("Period2", "Slow Period", "", 40);	
    indicator.parameters:addInteger("Period3", "BB Period", "", 20);	
	
    indicator.parameters:addInteger("Sen", "Sensitivity", "", 150);
    indicator.parameters:addInteger("DeadZonePip", "Dead Zone in pips", "", 30);
	
	
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
local Period1;
local Period2;
local Period3;


local first;
local firstBB;
local source = nil;

-- Streams block
local TG = nil;
local TR = nil;
local E = nil;

local EMAF = nil;
local EMAS = nil;
local BB_H = nil;
local BB_L = nil;

-- Routine
function Prepare(nameOnly)
    Sen = instance.parameters.Sen;
    DeadZonePip = instance.parameters.DeadZonePip;
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
    source = instance.source;


    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Period2.. ", " .. Period3.. ", " .. Sen .. ", " .. DeadZonePip .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    EMAF = core.indicators:create("EMA", source.close, Period1);
    EMAS = core.indicators:create("EMA", source.close, Period2);
    first = math.max(EMAS.DATA:first(),EMAF.DATA:first());
    firstBB = source:first() + Period3;
    BB_H = instance:addInternalStream(firstBB, 0);
    BB_L = instance:addInternalStream(firstBB, 0);
    TG = instance:addStream("TG", core.Bar, name .. ".TG", "TG", instance.parameters.TG_color, first);
    TG:setPrecision(math.max(2, instance.source:getPrecision()));
    TR = instance:addStream("TR", core.Bar, name .. ".TR", "TR", instance.parameters.TR_color, first);
    TR:setPrecision(math.max(2, instance.source:getPrecision()));
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
        local p = core.rangeTo(period, Period3)
        local ml = core.avg(source.close, p);
        local d = core.stdev(source.close, p);
        BB_H[period] = ml + 2 * d;
        BB_L[period] = ml - 2 * d;
    end

    if period >= first then
        local trend, explosion;
        trend = (MACD(period) - MACD(period - 1)) * Sen;
        explosion = BB_H[period] - BB_L[period];
        if trend > 0 then
            TG[period] = trend;
            TR[period] = 0;
        elseif trend < 0 then
            TG[period] = 0;
            TR[period] = -trend;
        end
        E[period] = explosion;
    end
end

function MACD(period)
    return EMAF.DATA[period] - EMAS.DATA[period];
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+