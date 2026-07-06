-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4340

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
    indicator:name("Smoothed Three Line Break ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Smoothing");
	indicator.parameters:addString("Method", "The smoothing method for prices", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("Method", "Wilders*", "", "WMA");    
    indicator.parameters:addInteger("PERIOD", "Periods to smooth prices", "", 6, 1, 1000);
	
     indicator.parameters:addGroup("Three Line Break");
	 indicator.parameters:addInteger("N", "Number of periods", "", 3, 1, 100);
	 
	 indicator.parameters:addGroup("Style");    
    indicator.parameters:addColor("up_color", "Color of Up", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("down_color", "Color of Down", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;


local MIN, MAX;
local TOP= {};
local BOTTOM= {};

local N;

local PREV;

local high, low, close, open;
local up_color, down_color;

local LAST=0;

local Method;
local PERIOD;
local sopen;
local sclose;

-- Streams block

-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
    Method = instance.parameters.Method;  
    N = instance.parameters.N;
	up_color = instance.parameters.up_color;
	down_color = instance.parameters.down_color;
    source = instance.source;
   

	local name = profile:id() .. "(" .. source:name() ..", "..N ..", "..PERIOD ..", "..Method..  ")";
	instance:name(name);
	if nameOnly then
		return;
	end

	 assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install ".. Method.. ".LUA indicator");    
	 
	sopen = core.indicators:create(Method, source.open, PERIOD);
    sclose = core.indicators:create(Method, source.close, PERIOD); 
	
	 first = sopen.DATA:first();	    
	
	open =   instance:addStream("open", core.Line, name .. ".open", "open",  core.rgb(0, 255, 0), first);
	close =   instance:addStream("close", core.Line, name .. ".close", "close",  core.rgb(0, 255, 0), first);
	high =   instance:addStream("high", core.Line, name .. ".high", "high",  core.rgb(0, 255, 0), first);
	low =   instance:addStream("low", core.Line, name .. ".low", "low",  core.rgb(0, 255, 0), first);
	
	 instance:createCandleGroup(name, "TLB", open, high, low, close);
	
	MAX =0;
	MIN = math.huge;
	LAST=0;
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not source:hasData(period) then
    return;  
    end
	
	sopen:update(mode);
    sclose:update(mode);
	
	if period == source:size()-1 then
	return;
	end	
	
	if period == first then
	MAX =0;
	MIN = math.huge;
	LAST=1;
	
             	if sclose.DATA[period] >  sopen.DATA[period] then
				TOP[LAST] = sclose.DATA[period];
				BOTTOM[LAST] = sopen.DATA[period];
				else
				TOP[LAST] = sopen.DATA[period];
				BOTTOM[LAST] = sclose.DATA[period];				
				end		
	
	end  
		  
			if LAST >=  N then
			MINMAX(N);
			else
			MINMAX(LAST);
			
			end
	    
			if sclose.DATA[period] > MAX then
			Shift();
			TES(period,true);
			elseif sclose.DATA[period] < MIN  then
			Shift();
			TES(period, false);			
			 
			end	
	

	if period == source:size()-2 then
	local i,j;
	j= source:size()-2 - #BOTTOM ;
	
			for i = 1, LAST , 1 do
			
					j=j+1;
					
					open[j]=  BOTTOM[i];
					close[j] = TOP[i];					
					low[j] =math.min(BOTTOM[i],  TOP[i]);
					high[j]= math.max(BOTTOM[i],  TOP[i]);
					
					if open[j] > open[j-1] then
					open:setColor(j,up_color);
					else
					open:setColor(j,down_color);
					end
			end
  
	end	
	
	
end

function SET(period)

    
       if sclose.DATA>sopen.DATA[period] then
			TOP[LAST] = sclose.DATA[period];
			BOTTOM[LAST] = sopen.DATA[period];
		else
		    TOP[LAST] = sclose.DATA[period];
			BOTTOM[LAST] = sopen.DATA[period];
        end				
		
end

function TES (period, FLAG)
	    
		if FLAG then	 		
			BOTTOM[LAST] = TOP[LAST-1];
			TOP[LAST] = sclose.DATA[period];		
        elseif not FLAG  then	    
			BOTTOM[LAST] = sclose.DATA[period];
			TOP[LAST] = BOTTOM[LAST-1];
		
        end			
	
end	


function Shift ()
   LAST= LAST+1;  
end

function MINMAX(M)
  
  local min = math.huge;
  local max = 0; 
  
		  
			  local i;
			  
			  for i = LAST, LAST-(M-1), -1 do
				 
					min = math.min(min , BOTTOM[i]);  
				   max = math.max(max, TOP[i]);
			  end   
		  
		
		  
  MIN = min;
  MAX = max;  
  
end

