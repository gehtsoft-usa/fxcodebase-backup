
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=27663

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
    indicator:name("SuperTrend");
    indicator:description("SuperTrend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addInteger("Shift", "Shift", "Shift", 20);	
	indicator.parameters:addBoolean("FILTER", "Use Price Filter", "", true);
	indicator.parameters:addGroup("Style");     
	indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period,Shift;
local CCI;
local first;
local source = nil;
--local TrendUp,TrendDown; 
-- Streams block
local ST = nil;
local FLAG;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Shift = instance.parameters.Shift;
	FILTER = instance.parameters.FILTER;
    source = instance.source;
	
	CCI = core.indicators:create("CCI", source, Period);
    first = CCI.DATA:first();
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Shift) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    
         ST = instance:addStream("ST", core.Line, name, "ST", instance.parameters.Up, first);
		ST:setWidth(instance.parameters.width);
        ST:setStyle(instance.parameters.style);	
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	CCI:update(mode);
	
	if period < first  then
	return;
	end
	

	
	
	ST[period]=ST[period-1];
	
	if CCI.DATA[period] >  0 and FLAG~= true then
	FLAG = true; 
	ST[period] = source.low[period]-source:pipSize()*Shift; 
	end
	if CCI.DATA[period] <  0 and FLAG~= false then
	  ST[period] = source.high[period] + source:pipSize()*Shift;
	FLAG = false;
    end	
	
	if FLAG 
	and  source.low[period]-source:pipSize()*Shift > ST[period-1]
	then
	ST[period] = source.low[period]-source:pipSize()*Shift; 
	elseif not FLAG
	and source.high[period] + source:pipSize()*Shift <  ST[period-1]
	then
	 ST[period] = source.high[period] + source:pipSize()*Shift;
	end
	
	
		
	if FILTER  then
	
			 if FLAG and ST[period] > ST[period-1] then   
			   
				 if source.close[period] < source.open[period] then
					 ST[period]=ST[period-1];            
				 end       
				 
		  
				  if source.high[period] < source.high[period-1]    then
				   
					ST[period] = ST[period-1];
				 end
				 
				
				 
			elseif not FLAG  and ST[period] < ST[period-1]  then
				
				 if  source.close[period] > source.open[period] then
				   
					ST[period] = ST[period-1];
				 end
						
			   
				if source.low[period] > source.low[period-1]   then
				  
					ST[period] = ST[period-1];
				 end		 
				
			end

	end
  
  
   if  source.close[period] > ST[period] then
   ST:setColor(period, instance.parameters.Up);
   else
   ST:setColor(period, instance.parameters.Down);
   end  
    
end

