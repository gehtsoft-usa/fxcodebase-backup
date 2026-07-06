-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34868
-- Id: 9012

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("True Strength Index Overlay");
    indicator:description("True Strength Index");
	
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("Long", "Long Term", "Period", 7);
	indicator.parameters:addInteger("Short", "Short Term", "Period", 14);
	
 
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("PositiveUp", "Color of positive Up", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("PositiveDown", "Color of positive Down", " ", core.rgb(0, 200, 0));
	
	 indicator.parameters:addColor("NegativUp", "Color of negativ Up", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NegativDown", "Color of negativ Down", " ", core.rgb(200, 0, 0));
	
	indicator.parameters:addGroup("OB/OS Style");	
	indicator.parameters:addInteger("Level", "OB/OS Level", "Level", 50);
	indicator.parameters:addColor("Up", "Color of Up", " ", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Down", "Color of Down", " ", core.rgb(75, 75, 75));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short, Long;
local Up, Down, Neutral;
local first;
local source = nil;
local Price;
-- Streams block
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local TSI;
local Level;   
-- Routine
function Prepare(nameOnly)
    Long = instance.parameters.Long;
	Short = instance.parameters.Short;
	Level = instance.parameters.Level;
	Price = instance.parameters.Price;
    source = instance.source;
     
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	PositiveUp=instance.parameters.PositiveUp;
	PositiveDown=instance.parameters.PositiveDown;
	NegativUp=instance.parameters.NegativUp;
	NegativDown=instance.parameters.NegativDown;
	
		
    local name = profile:id() .. " (" .. source:name() .. ", " .. Price.. ", " .. Long.. ", ".. Short ..")";
	instance:name(name);
	if nameOnly then
		return;
	end
	TSI = core.indicators:create("TSI", source[Price] , Long, Short);
	
	first= TSI.DATA:first();
   
    open = instance:addStream("open", core.Line, name, "", core.rgb(128, 128, 128), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(128, 128, 128), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(128, 128, 128), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(128, 128, 128), first);
    instance:createCandleGroup("TSI", "TSI", open, high, low, close);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	

     TSI:update(mode); 
	 
	 
    if period <  first then
	return;
	end
	
	
	
	if TSI.DATA[period] > Level  or TSI.DATA[period] < -Level  then
	
		if TSI.DATA[period] > TSI.DATA[period-1] then
		 open:setColor(period, Up);	
		else 
		open:setColor(period, Down);
		end
		
	return;
	end
	
          
     if TSI.DATA[period] > 0 then  
         if TSI.DATA[period] > TSI.DATA[period-1] then
		 open:setColor(period, PositiveUp);	
		else 
		open:setColor(period, PositiveDown);
		end 
     elseif TSI.DATA[period] < 0 then  	   
        if TSI.DATA[period] > TSI.DATA[period-1] then
		 open:setColor(period, NegativUp);	
		else 
		open:setColor(period, NegativDown);
		end
    end	   
    
end

