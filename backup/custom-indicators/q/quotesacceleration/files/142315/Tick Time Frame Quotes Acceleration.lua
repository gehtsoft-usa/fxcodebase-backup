-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71227

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+
 
function Init()
    indicator:name("Tick Time Frame Quotes Acceleration");
    indicator:description("Higher Time Frame Tick Count");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
   indicator.parameters:addBoolean("Filter", "Filter", "", true);
indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("down", "Down color", "", core.rgb(255, 0, 0));

    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local source = nil;
local first; 
local bid, ask;
local offset, weekoffset;
local loading1, loading2;
local Filter;
--local Cumulative;
function Prepare(nameOnly)
    source = instance.source;
    first = source:first(); 
	Filter= instance.parameters.Filter;
    
    local name = profile:id().. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    bid=nil;
    ask=nil;	
	offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

 assert(source:barSize()=="m1", " Please use m1 time frame.");
 
 
 
	QuotesAcceleration = instance:addStream("QuotesAcceleration", core.Bar, name .. ".QuotesAcceleration", "QuotesAcceleration", instance.parameters.up, source:first()); 
	QuotesAcceleration:setPrecision (source:getPrecision());
	QuotesSlowdown = instance:addStream("QuotesSlowdown", core.Bar, name .. ".QuotesSlowdown", "QuotesSlowdown", instance.parameters.down, source:first()); 
	QuotesSlowdown:setPrecision (source:getPrecision());
 
end

 
--other
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 function Update(period, mode)
       local from, to;

       if period < source:first() then
           return ;
       end
 
       if  bid == nil then
           -- if the data is not loaded yet at all
           -- load the data
           from = source:date(source:first());   -- oldest data to load
           from = core.getcandle(source:barSize(), from, offset, weekoffset);
           if source:isAlive() then              -- newest data to load or 0 if the source is "alive"
               to = 0;
           else
               to = source:date(source:size() - 1);
               to = core.getcandle(source:barSize(), to, offset, weekoffset);
           end
           load_from = from;
           loading1 = true;
		 --  loading2 = true;
           bid = core.host:execute("getHistory", 1, source:instrument(), "t1", from, to, true);
		   --ask = core.host:execute("getHistory", 2, source:instrument(), "t1", from, to, false);
           return ;
       end
 
       if loading1  then
           return ;
       end
     
   
	   
		 
       local curr_date = source:date(period);
       curr_date = core.getcandle(source:barSize(), curr_date, offset, weekoffset);
 
       if curr_date < load_from then
           -- if the data we are trying to get is oldest than previously loaded
           -- the extend the history to the oldest data we can request
           from = source:date(source:first());     -- load from the oldest data we have in source
           from = core.getcandle(source:barSize(), from, offset, weekoffset);
           if bid:size() > bid:first() then
               to = bid:date(bid:first());     -- to the oldest data we have in other instrument
           else
               to = load_from;
           end
           load_from = from;
           loading1 = true;
		 --  loading2 = true;
           core.host:execute("extendHistory", 1, bid, from, to);
		  -- core.host:execute("extendHistory", 2, ask, from, to);
           return ;
       end
	   
	        
       if loading1 then-- or loading2 then
           return ;
       end
	   startdate, enddate  = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
	   Start=core.findDate(bid, startdate, false);
	   End=core.findDate(bid, enddate, false);
	   
	   
	   if Start == -1 
	   or End==-1  
	   then
	   return;
	   end

		
	 if Start < 3 or End < 3  then
	 return;
	 end
	 
	 QuotesAcceleration[period]=0;
	 QuotesSlowdown[period]=0;
	 
	 for i= Start, End, 1 do
		 if bid:date(i)-bid:date(i-1) > bid:date(i-1)-bid:date(i-2) then
		 QuotesAcceleration[period]=QuotesAcceleration[period]+1;
		 else
		 QuotesSlowdown[period]=QuotesSlowdown[period]-1;
		 end
	 
	 end
	  
	
	if Filter then
	
	if QuotesAcceleration[period] > math.abs(QuotesSlowdown[period]) then
	QuotesSlowdown[period]=0;
	end
	
	if QuotesAcceleration[period] < math.abs(QuotesSlowdown[period]) then
	QuotesAcceleration[period]=0;
	end
	
	end
	
	   
end
 
function AsyncOperationFinished(cookie, success, message)
       if cookie == 1 then
           loading1  = false;
           -- update the indicator output when loading is finished
       end
	   --elseif cookie == 2 then
        --   loading2  = false;
           -- update the indicator output when loading is finished
     --  end

      if not loading1 then --and not loading2 then    
  	  instance:updateFrom(source:first());
           return ;	   
       end
 end