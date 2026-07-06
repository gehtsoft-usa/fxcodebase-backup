-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60523
-- Id: 11501

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("ATR Trailing Stop");
    indicator:description("ATR Trailing Stop");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "ATR Period", "ATRPeriod", 20);
    indicator.parameters:addDouble("Factor", "Factor", "Factor", 2);
	
    indicator.parameters:addString("Price", "SourcePrice", "SourcePrice", "median");
	indicator.parameters:addStringAlternative("Price", "Median", "Median" , "median");
	indicator.parameters:addStringAlternative("Price", "Close", "Close" , "close");
	
    indicator.parameters:addString("Mode", "Trailing Stop Mode", "Trailing Stop Mode", "High/Low");
	indicator.parameters:addStringAlternative("Mode", "High/Low", "High/Low" , "High/Low");
	indicator.parameters:addStringAlternative("Mode", "Close", "Close" , "Close");
	
	 indicator.parameters:addDouble("Distance", "Distance (in Pips)", "Distance", 0);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of TrailingStop Up", "Color of TrailingStop", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of TrailingStop Down", "Color of TrailingStop", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Factor;
local Price;
local Mode;
local Flag= true;
local first;
local source = nil;
local ATR;
local Direction;
-- Streams block
local TrailingStop = nil;
local Up,Down;


   local PrevUp, PrevDn;
   local CurrUp, CurrDn;
   local PriceCurr, PricePrev;
   local PriceLvl;
   local PriceHLorC;
   local LvlUp = 0;
   local LvlDn = 1000;
   local Dir = 1;
   
-- Routine
function Prepare(nameOnly)
  
    Period = instance.parameters.Period;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    Factor = instance.parameters.Factor;
    Price = instance.parameters.Price;
    Mode = instance.parameters.Mode;
    source = instance.source;
	
	Distance = instance.parameters.Distance*source:pipSize();
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Factor) .. ", " .. tostring(Price) .. ", " .. tostring(Mode) .. ", " .. tostring(Distance) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		ATR=core.indicators:create("ATR", source, Period);
		first = ATR.DATA:first();
		Flag= true;
		
        TrailingStop = instance:addStream("TrailingStop", core.Line, name, "TrailingStop",Up, first);
		TrailingStop:setWidth(instance.parameters.width);
        TrailingStop:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    ATR:update(mode);
    if period < first or not  source:hasData(period) then
	Flag= true;
	return;
	end
	
	  PriceLvl = source[Price][period];      
	  PriceCurr = source[Price][period];
	  PricePrev = source[Price][period-1];
         
	  if Flag then
        CurrUp=PriceCurr - ATR.DATA[period] * Factor;
        PrevUp=PricePrev - ATR.DATA[period-1] * Factor;
        CurrDn=PriceCurr + ATR.DATA[period] * Factor;
        PrevDn=PricePrev + ATR.DATA[period-1] * Factor;
           
		if (CurrUp > PrevUp) then
		Dir = 1;
		end
		 
        LvlUp = CurrUp;
		 
        if (CurrDn < PrevDn) then
		Dir = -1;         
		end
		LvlDn = CurrDn;
		 
		Flag = false;
			 
        else
		CurrUp=PriceLvl - ATR.DATA[period] * Factor;
        CurrDn=PriceLvl + ATR.DATA[period] * Factor;         		
        end   
		
		
		if (Dir == 1) then
			 if (CurrUp > LvlUp)  then
				TrailingStop[period] = CurrUp-Distance;
				LvlUp = CurrUp;
			 
			 else 
				TrailingStop[period] = LvlUp-Distance;
			 end
          
			 if Mode== "Close" then
			 PriceHLorC = source.close[period];
			 else 
			 PriceHLorC=source.low[period];
			 end
			 
			 
			 if (PriceHLorC < TrailingStop[period])  then
				Dir = -1;
				LvlDn = math.huge;
			 end
		 
		 
         end
		 
		 
		 if (Dir == -1)  then
			 if (CurrDn < LvlDn) then
				TrailingStop[period] = CurrDn+Distance;
				LvlDn = CurrDn;
			 
			 else 
				TrailingStop[period] = LvlDn+Distance;
			 end
		  
			 if Mode== "Close" then
			 PriceHLorC = source.close[period];
			 else 
			 PriceHLorC=source.high[period];
			 end
			 
			 if (PriceHLorC > TrailingStop[period])  then
				Dir = 1;
				LvlUp = - math.huge;
			 end
       end
	   
	   if source.close[period]> TrailingStop[period] then
	    TrailingStop:setColor(period, Down);
	   else
	   TrailingStop:setColor(period, Up);
	   end
	   
	   if 
	   (source.close[period]> TrailingStop[period] and source.close[period-1]< TrailingStop[period-1])
	   or
	   (source.close[period]< TrailingStop[period] and source.close[period-1]> TrailingStop[period-1])
	   then	   
	   TrailingStop:setBreak (period, true);
	   else
	   TrailingStop:setBreak (period, false);
	   end
		
 
end

