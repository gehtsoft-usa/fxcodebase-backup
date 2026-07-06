-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26220
-- Id: 7897

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
    indicator:name("Combining Rsi With Rsi ");
    indicator:description("Combining Rsi With Rsi ");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
	
	
	indicator.parameters:addGroup("RSI Calculation");
	indicator.parameters:addInteger("RSI1", "1.RSI Period", "1. RSI Period", 17);
    indicator.parameters:addInteger("RSI2", "2. RSI Period", "2. RSI Period", 5);
	
	indicator.parameters:addDouble("B", "RSI Buy Level", "RSI Buy Level", 50);
    indicator.parameters:addDouble("S", "RSI Sell Level", "RSI Sell Level", 50);
	
	indicator.parameters:addGroup("MA Calculation");
	indicator.parameters:addInteger("MA1", "1.MA Period", "1. MA Period", 40);
    indicator.parameters:addInteger("MA2", "2. MA Period", "2. MA Period", 10);
	indicator.parameters:addGroup("Filter");
	 indicator.parameters:addBoolean("Filter", "Use Filter", "", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BC", "Color of Buy", "Color of Buy", core.rgb(0, 255, 0));
	indicator.parameters:addColor("SC", "Color of Sell", "Color of Sell", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NC", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
end

 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local RSI1, RSI2, B, S;

local first;
local source = nil;
local BC, SC, NC;
local MA1, MA2;
 
local open, close;

local MVA_1, MVA_2, KST, RSI_1, RSI_2;
local BUY, SELL;
local Buy, Sell, CBuy, CSell;

-- Routine
function Prepare(nameOnly)

    Filter = instance.parameters.Filter;
 
 	
	MA1 = instance.parameters.MA1;
	MA2 = instance.parameters.MA2;
	
	BC = instance.parameters.BC;
	SC = instance.parameters.SC;
	NC = instance.parameters.NC;	
	
	RSI1 = instance.parameters.RSI1;
	RSI2 = instance.parameters.RSI2;
	B = instance.parameters.B;
	S = instance.parameters.S;
	
    source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() 
	.. " RSI: " .. tostring(RSI1).. ", " .. tostring(RSI2).. ", " .. tostring(B).. ", " .. tostring(S)
	.. " MA: " .. tostring(MA1).. ", " .. tostring(MA2)
	.. ")";
    instance:name(name);

    if (not (nameOnly)) then
        MVA_1 = core.indicators:create("MVA", source, MA1);
        MVA_2= core.indicators:create("MVA", source, MA2);
     
        RSI_1 = core.indicators:create("RSI", source, RSI1);
        RSI_2 = core.indicators:create("RSI", source, RSI2);
         first = math.max(RSI_1.DATA:first(), RSI_2.DATA:first(),MVA_1.DATA:first(), MVA_2.DATA:first()) ;
        open = instance:addStream("open", core.Line, name, "open", NC, first);    
        close = instance:addStream("close", core.Line, name, "close", NC, first);
		open:setPrecision(math.max(2, instance.source:getPrecision()));
		close:setPrecision(math.max(2, instance.source:getPrecision()));
 
	 instance:createChannelGroup ("ZONE", "ZONE", open, close, NC, 100)
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	RSI_1:update(mode);
	RSI_2:update(mode);
	MVA_1:update(mode);
	MVA_2:update(mode);
 
   if RSI_1.DATA[period] > B and source[period]> MVA_1.DATA[period] then
   Buy = true;
   Sell = false;
   end
   
   if RSI_1.DATA[period] < S and source[period] < MVA_1.DATA[period] then
   Sell = true;
   Buy= false;
   end
   
   
   
    if RSI_2.DATA[period] > B and source[period]> MVA_2.DATA[period]  then
   CBuy = true;
   CSell = false;
   end
   
   if RSI_2.DATA[period] < S and source[period] < MVA_2.DATA[period]  then
   CSell = true;
   CBuy = false;
   end
   
   if Buy and CBuy then
   BUY = true;
   SELL = false;
   elseif  Sell and CSell then
   SELL = true;
   BUY= false;
   elseif  not Filter then
   SELL = nil;
   BUY= nil;
   end
   
	
	close[period] = 0;
	open[period]  = 1;
	
	if BUY and not SELL then
	open:setColor(period, BC);
	elseif SELL and not BUY then
	open:setColor(period, SC); 
	else
	 open:setColor(period, NC);
	end
	
    
end
