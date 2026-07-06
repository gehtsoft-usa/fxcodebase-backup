-- Id: 8068
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=760

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Keep On Trading Overlay");
    indicator:description("Keep On Trading");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "ATR Period", "Period", 10);
	indicator.parameters:addInteger("LWMA", "LWMA Period", "Period", 3);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 0.1);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Color of Up Trend", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down Trend", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral Trend", " ", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period, LWMA;
local Up, Down, Neutral;
local first;
local source = nil;

-- Streams block
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local KOTL;
local KOTH;

local HIGH;
local LOW;
local ATR;

local flag;


   
local  KOTH;
local  KOTL;

local HLWMA;
local LLWMA;
local Multiplier;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	LWMA = instance.parameters.LWMA;
    source = instance.source;
    Multiplier = instance.parameters.Multiplier;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
    local name = profile:id() .. " (" .. source:name() .. ", " .. Period .. ", " .. LWMA..   ", " .. Multiplier..")";
	instance:name(name);
	if nameOnly then
		return;
	end
   
	ATR = core.indicators:create("ATR", source, Period);
	HLWMA = core.indicators:create("LWMA", source.high, LWMA);
    LLWMA = core.indicators:create("LWMA", source.low, LWMA);
	
	first= math.max(ATR.DATA:first(), LLWMA.DATA:first())
		
    open = instance:addStream("openup", core.Line, name, "", Neutral, first);
    high = instance:addStream("highup", core.Line, name, "", Neutral, first);
    low = instance:addStream("lowup", core.Line, name, "", Neutral, first);
    close = instance:addStream("closeup", core.Line, name, "", Neutral, first);
    instance:createCandleGroup("KOT", "KOT", open, high, low, close);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	local signal=0;
	
	 open:setColor(period, Neutral);	

     ATR:update(mode); 
	 HLWMA:update(mode); 
	 LLWMA:update(mode); 
	 
    if period <  first then
	return;
	end
	
          
          if(source.close[period] < source.low[period-1] and source.close[period] < source.low[period-2]) then
		  flag =-1;		
		  end
		  
		   if(source.close[period] > source.high[period-1] and source.close[period] > source.high[period-2]) then
		  flag =1;		
		  end
		  		  
		  
		  HIGH=HLWMA.DATA[period];
		  LOW= LLWMA.DATA[period];
		  
		 
		     KOTH=HIGH +Multiplier*  ATR.DATA[period];
             KOTL=LOW -Multiplier* ATR.DATA[period];
			 
			 
			 
			 if flag == 1 then
			 signal = KOTL; 
			 end
		 
		     if flag == -1 then
		     signal = KOTH;	           	 		   
             end
			 
        
         if  source.close[period] > signal then		
         open:setColor(period, Up);			 
		 elseif  source.close[period] < signal then		   
           open:setColor(period, Down);		
 		 else
          open:setColor(period, Neutral);			 
           end
end

