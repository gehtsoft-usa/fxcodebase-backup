-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4385

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Trendy");
    indicator:description("Trendy");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI Period", "RSI Period", 7);
    indicator.parameters:addInteger("MACD_Short_Period", "MACD Short Period", "MACD Short Period", 12);
    indicator.parameters:addInteger("MACD_Long_Period", "MACD Long Period", "MACD Long Period", 26);
    indicator.parameters:addInteger("MACD_Signal_Period", "MACD Signal Period", "MACD Signal Period", 9);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Range Color", "", core.rgb(128, 128, 128));
	 indicator.parameters:addInteger("Size", "Font Size", "", 15);
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RSI_Period;
local MACD_Short_Period;
local MACD_Long_Period;
local MACD_Signal_Period;

local first;
local source = nil;

-- Streams block
local open = nil;
local close = nil;
local high = nil;
local low = nil;

local Neutral, Up, Down;

local MACD;
local RSI;

local Overbought;
local Oversold;
local Size;
-- Routine
function Prepare(nameOnly)
    RSI_Period = instance.parameters.RSI_Period;
    MACD_Short_Period = instance.parameters.MACD_Short_Period;
    MACD_Long_Period = instance.parameters.MACD_Long_Period;
    MACD_Signal_Period = instance.parameters.MACD_Signal_Period;
	Size = instance.parameters.Size;
    source = instance.source;
   
   Neutral = instance.parameters.Neutral;
   Up = instance.parameters.Up;
   Down = instance.parameters.Down;
   
	
	if (MACD_Long_Period<= MACD_Short_Period) then
       error("The short EMA period must be smaller than long EMA period");
    end
    local name = profile:id() .. "(" .. source:name() .. ", " .. RSI_Period .. ", " .. MACD_Short_Period .. ", " .. MACD_Long_Period .. ", " .. MACD_Signal_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end	
	RSI = core.indicators:create("RSI", source.close, RSI_Period);
	MACD = core.indicators:create("MACD", source.close, MACD_Short_Period, MACD_Long_Period, MACD_Signal_Period  );
	
	
	
	 first = math.max(source:first(), RSI.DATA:first(), MACD.SIGNAL:first());

    open = instance:addStream("open", core.Line, name .. ".open", "open", Neutral, first);
    close = instance:addStream("close", core.Line, name .. ".close", "close", Neutral, first);
    high = instance:addStream("high", core.Line, name .. ".high", "high", Neutral, first);
    low = instance:addStream("low", core.Line, name .. ".low", "low", Neutral, first);	
	instance:createCandleGroup("Trendy", "", open, high, low, close);
	
	Overbought = instance:createTextOutput ("Overbought", "Overbought", "Wingdings 3", Size, core.H_Center, core.V_Top, Up, 0);
    Oversold = instance:createTextOutput ("Oversold", "Oversold", "Wingdings 3", Size, core.H_Center, core.V_Bottom, Down, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	  

	
		Overbought:setNoData (period);   
        Oversold:setNoData (period);    
	
    
        
		if period < first  or not source:hasData(period) then
		open:setColor(period, Neutral);			
		return;
		end 
		
		 MACD:update(mode);
         RSI:update(mode);
		 
		 
		  
		 
		 
		if RSI.DATA[period] > 75 then
        Overbought:set(period, source.high[period], "\113"); 
        elseif RSI.DATA[period] < 25 then
		Oversold:set(period, source.low[period], "\112");	
        end
		 
		 
		if MACD.SIGNAL[period] < MACD.MACD[period ] and MACD.SIGNAL[period] > 0 then
        open:setColor(period, Up);	    
        elseif MACD.SIGNAL[period] > MACD.MACD[period] and MACD.SIGNAL[period] < 0 then
		open:setColor(period, Down);	
		else
		open:setColor(period, Neutral);	            
        end
		
   
end

