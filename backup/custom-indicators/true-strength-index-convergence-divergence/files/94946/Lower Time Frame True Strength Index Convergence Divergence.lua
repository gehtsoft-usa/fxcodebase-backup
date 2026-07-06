-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69782

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
    indicator:name("Lower Time Frame True Strength Index Convergence Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Long Term", "The number of periods to average the Price Momentum.", 7, 2, 1000);
    indicator.parameters:addInteger("M", "Short Term", "The number of periods to smooth the Average Momentum.", 14, 2, 1000);
	
	indicator.parameters:addString("Method1", "TSI MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("S", "Signal Line Period", "", 14, 2, 1000);
	indicator.parameters:addString("Method2", "Signal MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");	 

    indicator.parameters:addGroup("Indicator Selection");	 
	indicator.parameters:addInteger("StreamNumber", "Data Stream Number", "", 1, 1 , 100);
	
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "m1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);	 
	

	indicator.parameters:addGroup("Style");
	
 
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));

 
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Period;

local Indicator;
local loading;

local day_offset, week_offset;
 
local host;
 
local TF;
local Up, Down; 
local Number=0;

local Count1;
local INDEX;
local StreamNumber;
function Prepare(nameOnly) 
   
	TF= instance.parameters.TF;       
	Up= instance.parameters.Up;
	Down= instance.parameters.Dn;
	source = instance.source;
	first = source:first();
	
	 
	
 
   	StreamNumber=instance.parameters.StreamNumber;
	StreamNumber=StreamNumber-1;
	
     
	
	host = core.host;
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	Number=0;
	 
	 
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);	
	if   (nameOnly) then
        return;
    end
   
   
    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
    s1, e1 = core.getcandle(TF, 0, 0, 0);  
 
		 if (e-s) < (e1-s1) then 
		        error("Choose a time frame smaller than the chart time frame.");
		 end 
 
 	assert(core.indicators:findIndicator("TSICD") ~= nil, "Please, download and install TSICD.LUA indicator"); 

	
 
	high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);    
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("STF", "STF", open, high, low, close);
   
  
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    open:setPrecision(math.max(2, instance.source:getPrecision()));	
    close:setPrecision(math.max(2, instance.source:getPrecision()));	
 
	 
	 

	 
	 
	BaseTimeFrame=nil
	Indicator=nil
	 
  
	instance:setLabelColor(Up); 
core.host:execute ("setTimer", 1, 1);

		 
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie) 

      if cookie == 1 then
           loading = false;
           -- update the indicator output when loading is finished

       
       end
			   
	if loading then
	core.host:execute ("setStatus", "  Loading "  );	 
	else
	core.host:execute ("setStatus", "Loaded");	 
    instance:updateFrom(0);    
	end
	 
        
    return core.ASYNC_REDRAW ;
	
	
end


        

function   Initialization(i)



    if loading or BaseTimeFrame:size() == 0  then
    return false;
    end
	

 
    local Candle;
    Candle = core.getcandle(TF, BaseTimeFrame:date(i), day_offset, week_offset);	
    local P = core.findDate(source , Candle, false);


    if P < 0    then
    return false;
	else
    return P;	
    end
			
end	


local Last;

-- Indicator calculation routine
function Update(period, mode)


    if loading   then
    return;
    end
	
		
	if period < source:size()-1 then
	return;
	end
	
	for i= 1, source:size()-1 , 1 do
	open[i] = 0;
	close[i] = 0; 
	high[i] = 0;
	low[i] = 0; 
    end
	
	
	if Indicator~= nil then
	Indicator:update(mode); 
	end



-------------------------------------------------------------------

		--local curr_date = source:date(period);
		--	   curr_date = core.getcandle(TF, curr_date, offset, weekoffset);
        if BaseTimeFrame==nil then
		
		
           from = source:date(source:first());   -- oldest data to load
           from = core.getcandle(TF, from, day_offset, week_offset);
           if source:isAlive() then              -- newest data to load or 0 if the source is "alive"
               to = 0;
           else
               to = source:date(source:size() - 1);
               to = core.getcandle(TF, to, day_offset, week_offset);
           end
           load_from = from;
 
				   loading = true;
				   BaseTimeFrame = core.host:execute("getHistory", 1, source:instrument(), TF,  from, to, source:isBid());
				   
						 
									   
						 
							Indicator= core.indicators:create("TSICD", BaseTimeFrame.close, instance.parameters.N,instance.parameters.M, instance.parameters.Method1, instance.parameters.S, instance.parameters.Method2); 		
									 
							Count1= Indicator:getStreamCount ();
								 
									  
							if StreamNumber >= Count1 then
							StreamNumber = Count1;
							assert( false, "Incorrect index of stream. The indicator has only ".. Count1  .. " stream(s).");
							end
						 
						  
					 
						 
							INDEX=  Indicator:getStream (StreamNumber);					   
		  

		  
				   return ;
				   
		
        end
		
		
		
		if loading then
		return ;
		end
		
		

       local curr_date = source:date(period);
       curr_date = core.getcandle(TF, curr_date, day_offset, week_offset);
 
       if curr_date < load_from then
           -- if the data we are trying to get is oldest than previously loaded
           -- the extend the history to the oldest data we can request
           from = source:date(source:first());     -- load from the oldest data we have in source
           from = core.getcandle(TF, from, day_offset, week_offset);
           if BaseTimeFrame:size() > BaseTimeFrame:first() then
               to = BaseTimeFrame:date(BaseTimeFrame:first());     -- to the oldest data we have in other instrument
           else
               to = load_from;
           end
           load_from = from;
           loading = true;
           core.host:execute("extendHistory", 1, BaseTimeFrame, from, to);
           return ;
       end

		  
---------------------------------------------------------------------
	
	if Last~=source:serial(period) then
    Last=source:serial(period)
    Indicator:update(core.UpdateAll );
    end
	
	for i= 1, BaseTimeFrame:size()-1 , 1 do
    Calculate(i);
	end

		
 end
 
 
function Calculate(i) 
					
	if not INDEX:hasData(i) then 
    return;
	end
	
 
					
   


				p = Initialization(i);	
            
                
				               if  p~= false and p> 0  then
							
							 
												
													if high[p]== 0   or   low[p]== 0  then	
																
														high[p] = INDEX[i] ;
														low[p] = INDEX[i];
														
														
													else
												 
															if  INDEX[i] > high[p] then
															high[p] = INDEX[i];
															end
															if  INDEX[i] < low[p] then
															low[p] = INDEX[i];
															end													
														
														
													end		


										   if source.close[p] > source.open[p] then
											 open[p] = low[p];
											 close[p] = high[p];
											 open:setColor(p, Up);
										   else	
											 open[p] = high[p];
											 close[p] = low[p];
											 open:setColor(p, Down);					 
										   end  											
								
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