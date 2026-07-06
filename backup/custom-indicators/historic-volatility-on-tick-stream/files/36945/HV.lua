-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=21021
-- Id: 7038

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

--[[
Historical Volatility Oscillator

   In finance, volatility is a measure for variation of price of a financial instrument over time. 
   Historic volatility is derived from time series of past market prices. 
   It is common for discussions to talk about the volatility of a security's price, 
   even while it is the returns' volatility that is being measured. It is used to quantify the risk of the financial instrument 
   over the specified time period. 
   Volatility is normally expressed in annualized terms and in %.
   The annualized historical volatility (sigma) is the standard deviation of the instrument's yearly logarithmic returns

   The indicator code illiustrates creation of simple indicators for FXCM(tm) Marketscope (tm) charting package
   As well as naming convertion using for Marketscope(tm) lua programming
   (c) G.Miller 2011-2012

History if changes
   09/20/2011 G.M. Initally created
   06/12/2011 G.M. prepared for publication

]]



-----------------------------------------------------------------------------------------------
-- Indicator profile initialization routine
-----------------------------------------------------------------------------------------------
function Init()
-- Define indicator properties and parameters
    indicator:name("HV");
    indicator:description("Historical Volatility. Spread Included");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volatility");

-- Group parameters to make parameter list intuitive as possible 
-- Calculation section. Place valuable information as possible 
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Periods", "Number of periods", "Time series in periods to measure a volatility", 14, 2, 1000);
    indicator.parameters:addBoolean("Annualization", "Annualization", "Express in annualized terms", true);
    indicator.parameters:addBoolean("UseHiLo", "Use High-Low envelope", "Use High-Low envelope versus Close price", true);
    indicator.parameters:addBoolean("Spread", "Add Bid-Offer Spread", "Add Bid-Offer Spread to calculation of returns", false);


-- Visualization section. Give all possible options to maintain an indicator look-n-feel 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("StyleHV", "Line style", "Style of volatility line", core.LINE_SOLID);
    indicator.parameters:setFlag("StyleHV", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("ClrHV", "Line color", "Color of volatilty line", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("WidthHV", "Line width", "Width of volatilty line", 1, 1, 5);
end

-----------------------------------------------------------------------------------------------
-- Indicator constants
-----------------------------------------------------------------------------------------------
local TRADING_DAYS_IN_YEAR = 252;
local OPPOSITEPRICE_EVENT = 1;  -- cookee for  load of OppositePrice history

-----------------------------------------------------------------------------------------------
-- Indicator state
-----------------------------------------------------------------------------------------------

-- Indicator calculation parameters
-- Use camel notation started with capital letter, keep same names as on parameter list, name paramters meaningful as possible
local Periods;
local Annualization;
local UseHiLo;
local Spread;

-- variables and local streams
-- Use camel notation started with capital letter, name variables meaningful as possible
local FirstPosition;  -- position of first element for the indicator
local LogReturn;      -- logarithmic return's internal stream
local DayOffset;      -- trading day offset
local WeekOffset;     -- trading week offset

local OppositePrice                 -- Opposite prices for the stream
local OppositePriceLoaded = true;   -- flag whether we need to load/reload OppositePrice stream or not
local Loading = true;               -- flags inital load

-- output stream, in case of single output: usually name of the indicator
local HV;


-----------------------------------------------------------------------------------------------
-- Indicator warm-up routine
-----------------------------------------------------------------------------------------------
function Prepare(onlyName)
    -- fill shortcuts to indicator's parameters
    Periods = instance.parameters.Periods;
    Annualization = instance.parameters.Annualization;
    UseHiLo = instance.parameters.UseHiLo;
    Spread = instance.parameters.Spread;
    

    -- local variables and arguments in camel notation, started with small letter
    local name = profile:name();
    if Annualization or UseHiLo or Spread then
        if Spread then
            name = name .. "-SPREAD";
            OppositePriceLoaded = false;
        end 
        name = name .. "-";
        if Annualization then
            name = name .. "A";
        end 
        if UseHiLo then
            name = name .. "HL";
        end 
    end
    name =  name.. "(" .. instance.source:name() .. ", " .. Periods .. ")";                   

    -- initialze name of indicator
    instance:name(name);
    if onlyName then
        return ;
    end

    -- initialize indicator memory state    
    LogReturn = instance:addInternalStream(instance.source:first() + 1, 0);

    FirstPosition = LogReturn:first() + Periods;

    HV = instance:addStream("HV", core.Line, name, "HV", instance.parameters.ClrHV, FirstPosition)
    HV:setPrecision(math.max(2, instance.source:getPrecision()));
    HV:setWidth(instance.parameters.WidthHV);
    HV:setStyle(instance.parameters.StyleHV);

    DayOffset = core.host:execute("getTradingDayOffset");
    WeekOffset = core.host:execute("getTradingWeekOffset");

end


function AsyncOperationFinished(cookie)
    if cookie == OPPOSITEPRICE_EVENT then
        OppositePriceLoaded = true;
        instance:updateFrom(0);
--        core.host:trace("AsyncOperationFinished...updating..." .. OppositePrice:first() .. " to " .. OppositePrice:size());
    end
end


-----------------------------------------------------------------------------------------------
-- Indicator calculation routine
-----------------------------------------------------------------------------------------------
function Update(period)

   -- note with XXX tricks or non-obvious statemets
   -- note with TODO statemets that planned to tune or rewrite
   -- note with TBD statemets that required additional reseach

    local source = instance.source;
    if not OppositePriceLoaded and Spread and Loading then
        OppositePrice = core.host:execute("getHistory", OPPOSITEPRICE_EVENT
            ,source:instrument()
            ,source:barSize()
            ,source:date(source:first())
            ,0
            ,not source:isBid() );
        Loading = false;
--        core.host:trace("run for getHistory from " .. source:first() .. " on " .. period);
    end    
    if not OppositePriceLoaded then
        return;
    end
    
    -- take care if we need to refresh a history on opposite stream
    local pos = 0;
    if Spread then
        pos = core.findDate(OppositePrice, source:date(period), true)
    end    
    if Spread and pos < 0 and OppositePrice:date(OppositePrice:first()) > source:date(source:first()) then
            OppositePriceLoaded = false;
--            core.host:trace("need to extend the history?" .. " " .. OppositePrice:first() .. " vs " .. period);
            core.host:execute("extendHistory", OPPOSITEPRICE_EVENT, OppositePrice, source:date(source:first()), OppositePrice:date(0));
            return;
    end
    
    local final = source.close[period];
    if Spread then
        if pos < 0 then
            core.host:trace("no data on OppositePrice")
            return;
        else
            final = OppositePrice.close[pos];
        end
    end
    local investment = source.open[period];

    if UseHiLo then 
        --xxx we do not care if loss or profit, only deviaton makes sense
        if Spread then
            final = OppositePrice.low[pos];
        else 
            final = source.low[period];
        end 
        investment = source.high[period];
    end

    -- calculate logarithmic return     
    LogReturn[period] = math.log (final / investment);
    
    if period >= FirstPosition then
        local sigma = 100 * mathex.stdev(LogReturn, period - Periods + 1, period);
        if Annualization then
           -- XXX: need to calc time in number of days. Here: number of d1 periods
            local begins, ends = core.getcandle(source:barSize(), source:date(period)
                ,DayOffset, WeekOffset);
            local days = ends - begins;
            -- TBD: TRADING_DAYS_IN_YEAR=252 that might possible to use exact no of trading days in year
            -- or 365 as in interest rate annualization (360 for pound, audy, kiwy)
            sigma = sigma * math.sqrt( TRADING_DAYS_IN_YEAR  / days);
        end
        HV[period] = sigma;
    end
end




