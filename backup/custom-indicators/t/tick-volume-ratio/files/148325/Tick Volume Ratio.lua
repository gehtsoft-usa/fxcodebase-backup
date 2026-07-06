-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72942

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Tick Volume Ratio");
    indicator:description("Tick Volume Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
 
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Method", "Method", "Method" , "2");
    indicator.parameters:addStringAlternative("Method", "Positive/Negative", "Positive/Negative" , "1");
    indicator.parameters:addStringAlternative("Method", "Positive/Total", "Positive/Total" , "2");
    indicator.parameters:addStringAlternative("Method", "Negative/Total", "Negative/Total" , "3");
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Up", "Color of Up Volume", "", core.rgb(0,255, 0));
    indicator.parameters:addColor("Down", "Color of Down Volume", "", core.rgb(255, 0, 0));
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
local Method;
-- Routine
function Prepare(nameOnly)
 
    source = instance.source;
    first = source:first();
	Method=instance.parameters.Method;
	
	offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");


    local name = profile:id() .. "(" .. source:name() .. ", " ..  Method .. ")";
    instance:name(name);
	
   assert(source:barSize()=="m1", "Please use 1 minute Time Frame");
   
     if   (nameOnly) then
        return;
    end
 	
 
		Up = instance:addInternalStream(0, 0);
		Down = instance:addInternalStream(0, 0);
		Ratio= instance:addStream("Ratio", core.Bar, name .. ".Ratio", "Ratio", instance.parameters.Up, first);
		Ratio:addLevel (0)
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)

 
    if period <= first
	or not source:hasData(period) 
	then
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
	   
	 if Down[period]~=0 then    
	 
		  if Method == "1" then
		  Ratio[period]=(Up[period]/Down[period])*100;
		  elseif Method ==  "2" then
		  Ratio[period]=Up[period]/((Up[period]+Down[period]))*100;	
          else
		  Ratio[period]=Down[period]/((Up[period]+Down[period]))*100;			  
		  end
		  
		  if Up[period]> Down[period] then
		  Ratio:setColor(period,  instance.parameters.Up);	
		  else
		  Ratio:setColor(period,  instance.parameters.Down);
		  end	  
		  
	 end
end


function Calculate(index, period)


    if index <Bid:first() 
	or   not Bid:hasData(index) 
	or  index <Ask:first() 
	or   not Ask:hasData(index) 
	then
    return;
	end
 
	if Bid[index]>= source.median[period] then
	Up[period]=Up[period]+1;
	else
	Down[period]=Down[period]+1;	
	end
	
	if Ask[index]>= source.median[period] then
	Up[period]=Up[period]+1;
	else
	Down[period]=Down[period]+1;	
	end	 
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
	   instance:updateFrom(source:first());
	   end
	   
end	 

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+


--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+