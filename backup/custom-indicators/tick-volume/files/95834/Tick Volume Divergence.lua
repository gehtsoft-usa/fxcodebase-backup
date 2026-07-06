
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61127

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Tick Volume");
    indicator:description("Tick Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addInteger("Size", "Arrow Size", "", 15);
    indicator.parameters:addColor("UpColor", "Color of Up Volume Divergence", "", core.rgb(0,255, 0));
    indicator.parameters:addColor("DownColor", "Color of Down Volume Divergence", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
 
local first;
local source = nil;
local From,To;
-- Streams block
local Up = nil;
local Down = nil;
local Bid=nil;
local Ask=nil;
local loadingAsk, loadingBid;
local weekoffset, offset;
local prevAsk, prevBid;
local UpCount = 0;
local DownCount = 0;
local Cumulative;
local Absolute;
local font, Size;
-- Routine
local UpColor,DownColor;
function Prepare(nameOnly)
     Size =instance.parameters.Size;
    source = instance.source;
    first = source:first();
	UpColor=instance.parameters.UpColor;
	DownColor=instance.parameters.DownColor;
 
	font = core.host:execute("createFont", "Wingdings", Size, false, false);

	offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");


    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	  
    if (not (nameOnly)) then
	
	 
		Up = instance:addInternalStream(0, 0);
		Down = instance:addInternalStream(0, 0);
		Cumulative= instance:addInternalStream(0, 0);
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
           Bid = core.host:execute("getHistory", 1, source:instrument(), "t1", from, to, true);
		   Ask = core.host:execute("getHistory", 2, source:instrument(), "t1", from, to, false);
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
	   
	      Calculate(index, period);              
		  
	   end
	 
	 
     	 Cumulative[period]=Up[period]+Down[period];
		 
	
        if Cumulative[period] > 0
		and source.close[period]< source.open[period] 		
		then
		core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,  font, UpColor, "\217");
		elseif Cumulative[period] < 0 
		and source.close[period]> source.open[period] 	
		then
		core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART,  source.high[period], core.CR_CHART, core.H_Center, core.V_Top,  font, DownColor, "\218");
		else
		core.host:execute ("removeLabel",source:serial(period) );
        end
end

function Calculate(index, period)


    if index <Bid:first() 
	or index < Ask:first() 
	or   not Bid:hasData(index) 
	or   not Ask:first(index) 
	then
    return;
	end
         if index== s then
		  
		         Up[period]=0;
				 Down[period]=0;
				
                if  Ask[index]~=prevAsk then
					if Ask[index] > Ask[index-1] then
					Up[period]=Up[period]+1;
					elseif Ask[index] < Ask[index-1] then
					Down[period]=Down[period]+1;
					end
				  prevAsk = Ask[index];
				end
				
				if  Bid[index]~=prevBid then
				
				   if Bid[index] > Bid[index-1] then
					Up[period]=Up[period]+1;
					elseif Bid[index] < Bid[index-1] then
					Down[period]=Down[period]+1;
					end
				 prevBid = Bid[index];
				end
                
              
               

                 
				
		  else
		  
		       if  Ask[index]~=prevAsk then
					if Ask[index] > Ask[index-1] then
					Up[period]=Up[period]+1;
					elseif Ask[index] < Ask[index-1] then
					Down[period]=Down[period]-1;
					end
					 prevAsk = Ask[index];
				end
				
				if  Bid[index]~=prevBid then
				
				   if Bid[index] > Bid[index-1] then
					Up[period]=Up[period]+1;
					elseif Bid[index] < Bid[index-1] then
					Down[period]=Down[period]-1;
					end
				    prevBid = Bid[index];
				end
                
           end    

end

 function ReleaseInstance()
       core.host:execute("deleteFont", font);

	   
end	   


   function AsyncOperationFinished(cookie, success, message)
       if cookie == 1 then
           loadingAsk = false;
           -- update the indicator output when loading is finished
           
           
       elseif cookie == 2 then
           loadingBid = false;
           -- update the indicator output when loading is finished
           
           
       end
	   
	   
	   if loadingAsk== false
	   and loadingBid== false
       then	   
	   instance:updateFrom(0);
	   end
	   
end	 

