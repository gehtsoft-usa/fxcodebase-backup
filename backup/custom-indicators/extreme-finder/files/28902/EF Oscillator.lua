-- Id: 13586
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15322


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Extreme Finder");
    indicator:description("Extreme Finder");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FP", "Forward Testing Period ", "", 5);
    indicator.parameters:addInteger("BP", "Backward Testing Period", "", 5);	
	 indicator.parameters:addDouble("SIZE", "Current Candle Min. Size (pips)", "", 0);
      indicator.parameters:addDouble("NEXT", "Next Candle Min. Size (pips)", "", 0);		 

	indicator.parameters:addGroup("Style");indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UP", "Confirmed fractal color", "", core.rgb(0,255,0)); 
	indicator.parameters:addColor("U_UP", "Unconfirmed fractal color", "", core.rgb(0,0,255));
 
	


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local FP;
local BP;
local Show, Live;
local first;
local source = nil;
local Flag;
-- Streams block
local up, down;
local Unconfirmed, Confirmed;
local UP, DOWN;
local U_UP, U_DOWN; 
local NEXT;
local SIZE;
local Shift=0;


-- Routine
function Prepare(nameOnly)
     
	NEXT = instance.parameters.NEXT;
    UP = instance.parameters.UP; 
	Live = instance.parameters.Live;
	Show = instance.parameters.Show;
	SIZE = instance.parameters.SIZE;	
	U_UP = instance.parameters.U_UP;
	 
	 
    FP = instance.parameters.FP;
    BP = instance.parameters.BP;
    source = instance.source;
    first = source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(FP) .. ", " .. tostring(BP) .. ", " .. tostring(SIZE).. ", " .. tostring(NEXT) .. ")";
    instance:name(name);
    --Unconfirmed, Confirmed
    if   (nameOnly) then
        return;
    end
         Unconfirmed =   instance:addStream("Unconfirmed", core.Bar, name .. ".Unconfirmed", "Unconfirmed", UP, first);
    Unconfirmed:setPrecision(math.max(2, instance.source:getPrecision()));
         Confirmed =   instance:addStream("Confirmed", core.Bar, name .. ".Confirmed", "Confirmed", U_UP, first);
    Confirmed:setPrecision(math.max(2, instance.source:getPrecision()));
 
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <  first or  not source:hasData(period) then
        return;
    end
 
	 
   if period < source:size() -1 then
	return;	
	end
	
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end 
				
	for i = first, period , 1 do
	Calculate(i);		
	end
end

function Calculate(i)


    Unconfirmed[i]=0;
	Confirmed[i]=0;

                if  (SIZE * source:pipSize()) > math.abs(source.open[i] - source.close[i]) 
				or  (NEXT * source:pipSize()) > math.abs(source.open[math.min(i+1, source:size()-1-Shift)] - source.close[math.min(i+1, source:size()-1-Shift)]) 
				then
				return;
				end
				
				
				BMin, BMax= mathex.minmax (source, math.max( first, i - BP) , i);	
				FMin, FMax= mathex.minmax (source, i , math.min ( i + FP , source:size()-1 -Shift));		

		 
				


				if BMax <=  source.high[i] and   FMax  <=  source.high[i]  then
				
				
				 
				   if math.max( first, i - BP) == first 
				   or math.min ( i + FP , source:size()-1-Shift ) ==  source:size()-1-Shift
				   then
				   Unconfirmed[i]=1;
				   else
				    Confirmed[i]=1;
	               end   	
				  		  
				end
				
				if BMin >=  source.low[i] and   FMin  >=  source.low[i] then
				   
				   
				    if math.max( first, i - BP) == first 
				   or math.min ( i + FP , source:size()-1-Shift ) ==  source:size()-1-Shift
				   then
				   Unconfirmed[i]=-1;
				   else
				    Confirmed[i]=-1;
	               end  	
				    
				end
				
end				


 