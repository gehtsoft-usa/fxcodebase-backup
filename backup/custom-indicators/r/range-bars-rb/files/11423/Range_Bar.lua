-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3614

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
    indicator:name("Range Bar");
    indicator:description("Range Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addInteger("Size", "Bar Size", "Bar Size", 10);
 end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size;

local first;
local source = nil;

-- Streams block
local open = nil;
local high = nil;
local low = nil;
local close = nil;


local tick_open = {};
local tick_high = {};
local tick_low = {};
local tick_close = {};

local Count;  
local SIZE;

-- Routine
function Prepare(nameOnly) 
    Size = instance.parameters.Size;
    source = instance.source;
    first = source.close:first();
	
	--tick_open = instance:addInternalStream(0, 0);
    --tick_high = instance:addInternalStream(0, 0);
    --tick_low = instance:addInternalStream(0, 0);
    --tick_close = instance:addInternalStream(0, 0);
	
	SIZE= Size*source:pipSize();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Size .. ")";
    instance:name(name);
	
	if onlyName then
        return ;
    end
	
	
    open = instance:addStream("open", core.Line, name .. ".open", "open", core.rgb(255, 0, 0), first);
    high = instance:addStream("high", core.Line, name .. ".high", "high", core.rgb(255, 0, 0), first);
    low = instance:addStream("low", core.Line, name .. ".low", "low", core.rgb(255, 0, 0), first);
    close = instance:addStream("close", core.Line, name .. ".close", "close", core.rgb(255, 0, 0), first);
	 instance:createCandleGroup("RB", "RB", open, high, low, close);
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   if period < source:size()-2 then
   return;
   end

   
   local i;
   
     Count=1;
			   
				tick_open[first+1] = source.open[first+1];
				tick_high[first+1] = source.open[first+1];
				tick_low[first+1] = source.open[first+1];
				tick_close[first+1] = source.open[first+1];		
   
   for i = first+1, source:size()-2, 1 do		
    TEST(i);
	end	
	
    
	for i = Count,  0 ,-1 do
	
                open[ source:size()-2 -(Count-i)] = tick_open[i];
				high[source:size()-2-(Count-i)] = tick_high[i];
				low[source:size()-2-(Count-i)] = tick_low[i];
				close[source:size()-2-(Count-i)] = tick_close[i];		
	             if tick_close[i] == 0 then
				  open[ source:size()-2 -(Count-i)] = nil;
				high[source:size()-2-(Count-i)] = nil;
				low[source:size()-2-(Count-i)] = nil;
				close[source:size()-2-(Count-i)] = nil;		
				 end
				 
    end
end

function TEST(i)		 
		   
		  
		   
				   while true do				   
				   
						   if  source.high[i]>  (tick_low[Count]+   SIZE) then
						   
						
							tick_high[Count] = tick_low[Count] + SIZE;						
							tick_close[Count] = tick_low[Count] + SIZE;
						   
						 						
						    tick_open[Count+1] = tick_close[Count];
							tick_high[Count+1] = tick_close[Count];
							tick_low[Count+1] = tick_close[Count];
							tick_close[Count+1] = tick_close[Count];						
									   
                           Count= Count+1;
						   elseif    source.low[i]  < (tick_high[Count] - SIZE) then
						   
						   tick_low[Count] = tick_high[Count] - SIZE;						
							tick_close[Count] = tick_high[Count] - SIZE;	
						    
						    tick_open[Count+1] = tick_close[Count];
							tick_high[Count+1] = tick_close[Count];
							tick_low[Count+1] = tick_close[Count];
							tick_close[Count+1] = tick_close[Count];							
							 
						
							Count= Count+1;
						    else
							   if   source.low[i] < tick_low[Count] then
								   tick_low[Count] = source.low[i];
							   elseif   source.high[i] > tick_high[Count] then
								   tick_high[Count] = source.high[i];
							   end	   
							 
						   end		
                             break;
							 
				   end   
end


