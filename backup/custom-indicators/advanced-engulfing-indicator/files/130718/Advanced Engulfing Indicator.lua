-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69316

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
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
function Init()
	indicator:name("Advanced Engulfing Indicator")
	indicator:description(" ")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addBoolean("Complet", "Use Complet candle", "", false)
	indicator.parameters:addBoolean("Gap", "Gap Only", "", false)
	indicator.parameters:addBoolean("Ignore", "Ignore Direction", "", false) 


	indicator.parameters:addGroup("Style")

    indicator.parameters:addInteger("Size", "Arrow Size", "", 15)
	indicator.parameters:addColor("Up", "Color of Bullish bar", "Color of Bullish bar", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Color of Bearish bar", "Color of Bearish bar", core.rgb(255, 0, 0))
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil
-- Streams block
local up = nil
local down = nil
local Gap = nil
local Size
local Complet
local Raw;
local Ignore;
-- Routine
function Prepare(nameOnly)
	source = instance.source;
	first = source:first();
	Complet = instance.parameters.Complet;
	Size = instance.parameters.Size;
	Gap = instance.parameters.Gap;
    Ignore= instance.parameters.Ignore;

	local name = profile:id() .. "(" .. source:name() .. ")"
	instance:name(name)
	
	if (nameOnly) then
		return
	end 
	
	
	    Raw = instance:addInternalStream(0, 0);
		down = instance:createTextOutput("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
		up = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);

end


function Update(period, mode)
	
		up:setNoData(period);
		down:setNoData(period);
		
		
		
		if Bullish(period) then			
			Raw[period]=1;
		elseif Bearish(period) then			
			Raw[period]=-1;
	    else
		    Raw[period]=0;
		end
		
		
		local Signal=0;
		
		if Complet then
		Signal= Raw[period-1];
		else
		Signal= Raw[period];
		end
		
		if Signal == 1 then
		up:set(period, source.low[period], "\225");
		elseif Signal == -1 then
		down:set(period, source.high[period], "\226");
		end
		
	
end

function Bullish (period)




    
	if Ignore then
	
	        local min=math.min(source.close[period],source.open[period] );
			local max=math.max(source.close[period],source.open[period] );
			
			local min1=math.min(source.close[period-1],source.open[period-1] );
			local max1=math.max(source.close[period-1],source.open[period-1] );
	
	    if Gap 
		then
			if   min < min1
			and max > max1
			and source.close[period]> max1
			then
				return true;
			else
				return false;	
			end
		
			
		else
		
			if   min <= min1
			and max >= max1
			and source.close[period]>= max1
			then
				return true;
			else
				return false;	
			end

		end
 
		
	else
	
	    if Gap 
		then
			if   source.open[period] < source.close[period - 1] 
			and source.close[period] > source.open[period - 1]
			and   source.close[period-1] <= source.open[period - 1] 
			then
				return true;
			else
				return false;	
			end
		
			
		else
		
			 if source.open[period] <= source.close[period - 1]
			and source.close[period] >= source.open[period - 1]
			and   source.close[period-1] <= source.open[period - 1] 
			then
				return true;
			else
				return false;	
			end

		end
		
	end
	
end

function Bearish(period)

  
    if Ignore then
	        local min=math.min(source.close[period],source.open[period] );
			local max=math.max(source.close[period],source.open[period] );
			
			local min1=math.min(source.close[period-1],source.open[period-1] );
			local max1=math.max(source.close[period-1],source.open[period-1] );          
		
			
			if Gap
		then
			 if   min < min1
			and max > max1
			and source.close[period]< min1
			then
				return true;
			else
				return false;	
			end
				 
		else
		
			  if   min <= min1
			and max >= max1
			and source.close[period]<= min1
			then
				return true;
			else
				return false;	
			end
		end
	else
		if Gap
		then
			 if source.open[period] > source.close[period - 1]
			and source.close[period] < source.open[period - 1]
			and   source.close[period-1] >= source.open[period - 1] 
			then
				return true;
			else
				return false;	
			end
				 
		else
		
			 if source.open[period] >= source.close[period - 1]
			and source.close[period] <= source.open[period - 1]
			and  source.close[period-1] >= source.open[period - 1] 
			then
				return true;
			else
				return false;	
			end
		end
	end
end
 