
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23506 
 
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
    indicator:name("Swing High/Low");
    indicator:description("Swing High/Low");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Size", "Arrow Size", "", 12);
    indicator.parameters:addColor("clrUP", "Up Swing Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Swing Color", "", core.COLOR_DOWNCANDLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local SLOPE;
local SLH;
local LOW,HIGH;
local LAST;
local Size;
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    first = source:first()+6;
	Size= instance.parameters.Size;
    
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if (not (nameOnly)) then  
     up = instance:createTextOutput ("Up", "Up", "Verdana", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
	 down = instance:createTextOutput ("Dn", "Dn", "Verdana", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    local Note, Color;
	if period < first or not source:hasData(period) then
        return;
    end

	  
	  if period == first then
	  HIGH=period;
	  LOW=period;
	  end
	
	
	 local curr = period - 2;
        if (source.high[curr]  > source.high[curr -1]  and source.high[curr] > source.high[curr -2] and
            source.high[curr]  > source.high[curr + 1] and source.high[curr]  > source.high[curr+2]) then
			
			if LAST  and  source.high[HIGH] < source.high[curr] then
			up:setNoData (HIGH);
			elseif LAST then
			return;
			end
			
			
			if source.high[curr] > source.high[HIGH]  then
             Note="HH";
			 Color = instance.parameters.clrUP;
			else
			Note="LH";
			Color = instance.parameters.clrDN;
			end
			 
			up:set(curr, source.high[curr], Note, source.high[curr],Color);	
            LAST= true;			
			HIGH= curr;
           
        end
         
        if (source.low[curr]  < source.low[curr -1] and source.low[curr] < source.low[curr -2] and
            source.low[curr] < source.low[curr + 1] and source.low[curr] < source.low[curr+2]) then
			
			if not LAST   and  source.low[LOW] > source.low[curr] then
			down:setNoData (LOW);
			elseif not LAST then
			return;			
			end
			
			if source.low[curr] < source.low[LOW]  then
             Note="LL";
			 Color = instance.parameters.clrDN;
			else
			Note="HL";
			Color = instance.parameters.clrUP;
			end
			 
            down:set(curr, source.low[curr], Note, source.low[curr],Color);
            LOW= curr;
			LAST= false;
			
        end
	

	
	 
end

