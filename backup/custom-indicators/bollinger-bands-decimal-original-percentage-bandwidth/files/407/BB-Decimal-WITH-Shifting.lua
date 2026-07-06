--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

--
-- Bollinger Bands Indicator with Decimal + Shifting
-- 
-- Changes & Added Featured:
-- 1. Decimal Support Added
-- 2. Shifting bands by n-periods added
--    
-- SUPPORT: http://www.fxcodebase.com/
-- 
-- COPYRIGHT: The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- COPYRIGHT: The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)
--

function Init()
    indicator:name("Bollinger Bands w. Shifting (Original+Decimal)");
    indicator:description("Original Bollinger Bands with Decimal Support and Shifting Support.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addDouble("N", "Number of periods", "Number of periods", 20.0);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2.0);
    
    indicator.parameters:addInteger("S_TL", "Shift TL line, n-periods.(NO DECIMAL)", "Shift TL line, n-periods.(NO DECIMAL)", 0);
    indicator.parameters:addInteger("S_BL", "Shift BL line, n-periods.(NO DECIMAL)", "Shift BL line, n-periods.(NO DECIMAL)", 0);
    indicator.parameters:addInteger("S_AL", "Shift AL line, n-periods.(NO DECIMAL)", "Shift AL line, n-periods.(NO DECIMAL)", 0);
    
    indicator.parameters:addColor("clrBBP", "clrBBP", "clrBBP", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrBBM", "clrBBM", "clrBBM", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrBBA", "clrBBA", "clrBBA", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;

local firstPeriod;
local source = nil;

local S_TL = nil;
local S_BL = nil;
local S_AL = nil;

-- Streams block
local TL = nil;
local BL = nil;

-- Routine
function Prepare()
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    
    S_TL = instance.parameters.S_TL;
    S_BL = instance.parameters.S_BL;
    S_AL = instance.parameters.S_AL;
    
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = "Bollinger Bands - Decimal + Shifting (" .. N .. ", " .. D .. ")";
    instance:name(name);
    
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrBBP, firstPeriod + S_TL, S_TL)
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clrBBM, firstPeriod + S_BL, S_BL)
    AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.clrBBA, firstPeriod + S_AL, S_AL)
end

-- Indicator calculation routine
function Update(period)
    if(period >= firstPeriod) then
        local p = core.rangeTo(period, N);
        local ml = core.avg(source, p);
        local d = core.stdev(source, p);
        
        if( period + S_TL >= 0  ) then
        	TL[period + S_TL] = ml + D * d;
        end
        
        if( period + S_BL >= 0  ) then
        	BL[period + S_BL] = ml - D * d;
        end
        
        if( period + S_BL >= 0  ) then
        	AL[period + S_AL] = ml;
        end
    end
end





