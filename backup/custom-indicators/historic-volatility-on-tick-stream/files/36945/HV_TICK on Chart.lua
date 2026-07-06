-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=21021
-- Id: 12070

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
   07/11/2012 G.M. Prepared for publication

]]


-----------------------------------------------------------------------------------------------
-- Indicator constants
-----------------------------------------------------------------------------------------------
local TRADING_DAYS_IN_YEAR = 252;


-----------------------------------------------------------------------------------------------
-- Indicator profile initialization routine
-----------------------------------------------------------------------------------------------
function Init()
-- Define indicator properties and parameters
    indicator:name("HV");
    indicator:description("Historical Volatility for tick stream");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Volatility");

-- Group parameters to make parameter list intuitive as possible 
-- Calculation section. Place valuable information as possible 
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Periods", "Number of periods", "Time series in periods to measure a volatility", 14, 2, 1000);
    indicator.parameters:addBoolean("Annualization", "Annualization", "Express in annualized terms", true);



	
	indicator.parameters:addGroup("Placement");
    indicator.parameters:addString("Position", "Position", "", "1");
    indicator.parameters:addStringAlternative("Position", "Top", "", "0");
    indicator.parameters:addStringAlternative("Position", "Bottom", "", "1");
    indicator.parameters:addInteger("Height", "Height (% of chart height)", "", 20);
    indicator.parameters:addColor("color", "Fill Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
end

-----------------------------------------------------------------------------------------------
-- Indicator state
-----------------------------------------------------------------------------------------------

-- Indicator calculation parameters
-- Use camel notation started with capital letter, keep same names as on parameter list, name paramters meaningful as possible
local Periods;
local Annualization;

-- variables and local streams
-- Use camel notation started with capital letter, name variables meaningful as possible
local FirstPosition;  -- position of first element for the indicator
local LogReturn;      -- logarithmic return's internal stream

-- output stream, in case of single output: usually name of the indicator
local HV;
local source;

local color;
local transparency;
local Position;
local Height;

-----------------------------------------------------------------------------------------------
-- Indicator warm-up routine
-----------------------------------------------------------------------------------------------
function Prepare(onlyName)
    -- fill shortcuts to indicator's parameters
    Periods = instance.parameters.Periods;
    Annualization = instance.parameters.Annualization;
	
	  source = instance.source;

    -- local variables and agumentens in camel notation, started with small letter
    local name =  profile:name();                   
    if Annualization then
        name = name .. "-A";
    end
    name =  name .. "(" .. instance.source:name() .. ", " .. Periods .. ")";                   

    -- initialze name of indicator
    instance:name(name);
    if onlyName then
        return ;
    end

    -- initialize indicator memory state    
    LogReturn = instance:addInternalStream(instance.source:first() + 1, 0);

    FirstPosition = LogReturn:first() + Periods;

    HV = instance:addInternalStream(0, 0);
	
	 instance:ownerDrawn(true);
	Position = tonumber(instance.parameters.Position)
    Height = instance.parameters.Height/100; 
    color = instance.parameters.color;
	 instance:setLabelColor(color);

end


-----------------------------------------------------------------------------------------------
-- Indicator calculation routine
-----------------------------------------------------------------------------------------------
function Update(period)

  -- note with XXX tricks or non-obvious statemets
   -- note with TODO statemets that planned to tune or rewrite
   -- note with TBD statemets that required additional reseach

   
    if (source[period] == nil or source[period -1] == nil) then
        LogReturn[period] =  LogReturn[period -1];
        core.host:trace("source got no value skip it?");
        return;
    end
    local final = source[period];
    local investment = source[period -1];

    if final == 0 or investment == 0 then
        core.host:trace("source got 0 value: you need to use correct source");
        LogReturn[period] =  LogReturn[period -1];
        return;
    end
	
	 -- calculate logarithmic return
    LogReturn[period] = math.log (final / investment);
	   
       if period < FirstPosition then
	   return;
	   end
	   
	    Calculate(period);
end


function Calculate(period)
 
   
    

        local sigma = 100 * mathex.stdev(LogReturn, period - Periods + 1, period);

        if Annualization then
             local ends = source:date(period);
             local begins = source:date(period -1);
            local days = ends - begins;
            ends = source:date(period-1);
            begins = source:date(period -2);
            -- skip weekends and holidays
            if (ends - begins) < days then
                days = ends - begins;
            end
            sigma = sigma * math.sqrt( TRADING_DAYS_IN_YEAR  / days);
        
        HV[period] = sigma;
    end

end


local init = false;

function Draw(stage, context)
    if stage~= 2 then
	return;
	end
	
    
        if not init then
            context:createSolidBrush(2, color);
            context:createPen(1, context.SOLID, 1, color);
            transparency = context:convertTransparency(instance.parameters.transparency);
            init = true;
        end
        

        
        local firstBar, lastBar = context:firstBar(), context:lastBar();
        firstBar=math.max(firstBar, source:first());
        lastBar=math.min(lastBar, source:size()-1);

        local Max =mathex.max(HV, firstBar, lastBar);
        
        if Max ==0 then
         return;
        end
        
        local top, bottom = context:top(), context:bottom();
        local HeightCoeff=(bottom-top)*Height/Max ;
        
        local BarHeight; 
        local y1, y2; 
	    local period;
		
		for period=firstBar, lastBar, 1 do
          
            x, x1, x2 = context:positionOfBar (period); 
             
             BarHeight=HeightCoeff*HV[period];
             

            if Position==0 then
              y1=top+HeightCoeff*Max;
              y2=y1-BarHeight;
            else
             y1=bottom-BarHeight;
             y2=bottom;
            end

            context:drawRectangle(1, 2, x1, y1, x2, y2, transparency);
            
        end

   
end





