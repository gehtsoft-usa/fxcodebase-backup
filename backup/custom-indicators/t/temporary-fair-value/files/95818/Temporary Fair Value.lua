-- Id: 12444

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61123
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
    indicator:name("Temporary Fair Value");
    indicator:description("Temporary Fair Value");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("exponential", "exponential", "exponential", 2);
	indicator.parameters:addGroup("Style"); 	 
	 indicator.parameters:addInteger("Size", "Font Size", "Font Size", 6);
    indicator.parameters:addColor("CandleHeart_color", "Color of CandleHeart", "Color of CandleHeart", core.rgb(255, 0, 0));
    indicator.parameters:addColor("CandleSpread_color", "Color of CandleSpread", "Color of CandleSpread", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local exponential;
local thisCandle;
local first;
local source = nil;
local From,To;
-- Streams block
local ResultHeart = nil;
local ResultMovement = nil;
local Bid=nil;
local Ask=nil;
local loadingAsk, loadingBid;
local weekoffset, offset;
local prevAsk, prevBid;
local aveAsk, aveBid;
local Size;
-- Routine
function Prepare(nameOnly)
    exponential = instance.parameters.exponential;
	Size = instance.parameters.Size;
    source = instance.source;
    first = source:first();
	
	offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(exponential) .. ")";
    instance:name(name);
	
	  
    if (not (nameOnly)) then
		 ResultHeart = instance:createTextOutput ("CandleHeart", "CandleHeart", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.CandleHeart_color, 0);
         ResultMovement = instance:createTextOutput ("CandleSpread", "CandleSpread", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.CandleSpread_color, 0);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
local init= true;
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	 
 
  local from, to;
 
 
 
       if Bid == nil then
           -- if the data is not loaded yet at all
           -- load the data
           from = source:date(source:first());   -- oldest data to load
           if source:isAlive() then              -- newest data to load or 0 if the source is "alive"
               to = 0;
           else
               to = source:date(source:size() - 1);
           end
           load_from = from;
           loadingBid = true;
		   loadingAsk = true;
           Bid = core.host:execute("getHistory", 1, source:instrument(), "m1", from, to, true);
		   Ask = core.host:execute("getHistory", 2, source:instrument(), "m1", from, to, false);
           return ;
       end
	   
 
       if loadingBid
	   or loadingAsk
	   then
           return ;
       end
 
       local curr_date = source:date(period);
	   
       if curr_date < load_from then
           -- if the data we are trying to get is oldest than previously loaded
           -- the extend the history to the oldest data we can request
           from = source:date(source:first());     -- load from the oldest data we have in source
           if Bid:size() > Bid:first() then
               to = Bid:date(Bid:first());     -- to the oldest data we have in other instrument
           else
               to = load_from;
           end
           load_from = from;
           loading = true;
           core.host:execute("extendHistory", 1, Bid, from, to);
		   core.host:execute("extendHistory", 2, Ask, from, to);
           return ;
       end
	   
       s, e = core.getcandle(source:barSize(),source:date(period),  offset, weekoffset);

        
       s = core.findDate(Ask, s,false);
	   e = core.findDate(Ask, e, false);
	   
       if s == -1 
	   or e == -1
	   then
	   return;
	   end
	   
	    
	   for index= s, e, 1 do
	   
	      if index== s then
		  
		       askCount = 1;
                bidCount = 1;
				
                aveAsk = (Ask.median[index - 1] + (exponential * Ask.close[index])) / (exponential + 1);
                aveBid = (Bid.median[index - 1] + (exponential * Bid.close[index])) / (exponential + 1);
                prevAsk = aveAsk;
                prevBid = aveBid;

                 
				
		  else
		  
		        if (Ask.close[index] ~= prevAsk) then
               
                    
                    aveAsk = ((askCount * aveAsk) + ( exponential *  Ask.close[index])) / (askCount +  exponential);
                    prevAsk = Ask.close[index];
                    askCount=askCount+1;
                end

                if ( Bid.close[index] ~= prevBid) then
                
                    
                    aveBid = ((bidCount * aveBid) + ( exponential *  Bid.close[index])) / (bidCount +  exponential);
                    prevBid = Bid.close[index];
                    bidCount=bidCount+1; 
                end
               
				 
		  end
		  
	   end
	   
	    ResultHeart:set(period , aveBid, "\108", aveBid);
		ResultMovement:set(period ,aveAsk, "\108", aveAsk);
	      
end


   function AsyncOperationFinished(cookie, success, message)
       if cookie == 1 then
           loadingAsk = false;
           -- update the indicator output when loading is finished
           
           
       elseif cookie == 2 then
           loadingBid = false;
           -- update the indicator output when loading is finished
           instance:updateFrom(source:first());
           
       end
	   
end	 


   
--[[

// start of a new candle
            if (index != thisCandle)
            {
                thisCandle = index;
                askCount = 1;
                bidCount = 1;

                // start a new candle with the average of the last minute of the previous candle + the current price.
                aveAsk = (minuut.Median[minuutindex - 1] + (_exponential * Symbol.Ask)) / (_exponential + 1);
                aveBid = (minuut.Median[minuutindex - 1] + (_exponential * Symbol.Bid)) / (_exponential + 1);
                prevAsk = aveAsk;
                prevBid = aveBid;

                ResultHeart[index] = aveBid;
                ResultMovement[index] = aveAsk;
            }
            else
            {
                // continue the current candle

                if (Symbol.Ask != prevAsk)
                {
                    // Ask price different from previous
                    aveAsk = ((askCount * aveAsk) + (_exponential * Symbol.Ask)) / (askCount + _exponential);
                    prevAsk = Symbol.Ask;
                    askCount++;
                }

                if (Symbol.Bid != prevBid)
                {
                    // Bid price different from previous
                    aveBid = ((bidCount * aveBid) + (_exponential * Symbol.Bid)) / (bidCount + _exponential);
                    prevBid = Symbol.Bid;
                    bidCount++;
                    candle = aveBid;
                }
                ResultHeart[index] = aveBid;
                ResultMovement[index] = aveAsk;
            }

   

]]

