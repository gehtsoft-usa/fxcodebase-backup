-- Id: 19987

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65461&p=116519#p116519

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
function Init()
    indicator:name("Trend Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
 
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SlowLength", "Slow Length","", 7);	
	indicator.parameters:addInteger("SlowPipDisplace", "Slow Pip Displace","", 0);
	
	 indicator.parameters:addInteger("FastLength", "Fast Length","", 3);	
	indicator.parameters:addInteger("FastPipDisplace", "Slow Pip Displace","", 0);
 
	indicator.parameters:addBoolean("Histogram", "3 state histogram", "", true);
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Up Color","", core.rgb(0, 255, 0)); 	
	indicator.parameters:addColor("color2", "Down Color","", core.rgb(255, 0, 0));
 
	indicator.parameters:addGroup("Candle Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 

local first;
local source = nil;
local  SlowLength, SlowPipDisplace,FastLength,FastPipDisplace;
local ShowCandles;

-- Streams block
local Line1, Line2 = nil;
local Trend,Cross;
local Histogram;
local histogram;
local Up, Down;--, Neutral;
 

local Size, cross_up, cross_down;
-- Routine
function Prepare(nameOnly) 
     
   
    SlowLength= instance.parameters.SlowLength;
	SlowPipDisplace= instance.parameters.SlowPipDisplace;
	FastLength= instance.parameters.FastLength;
	FastPipDisplace= instance.parameters.FastPipDisplace;
	ShowCandles= instance.parameters.ShowCandles;
	Size= instance.parameters.Size;
	 Histogram= instance.parameters. Histogram;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	
    source = instance.source;
    first = source:first()+math.max(SlowLength, FastLength);

    local name = profile:id() .. "(" .. source:name() .. ", " .. SlowLength .. ", " .. FastLength.. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	Trend = instance:addInternalStream(0, 0);
	Cross = instance:addInternalStream(0, 0);
	
    Line1= instance:addInternalStream(0, 0);
	Line2= instance:addInternalStream(0, 0);
	
	histogram = instance:addStream("histogram", core.Bar, name, "histogram", instance.parameters.color2, first);
    histogram:setPrecision(math.max(2, instance.source:getPrecision()));
    histogram:addLevel(1);
    histogram:addLevel(0);
 
	
 
 
end
 
function Update(period)
    if period < first then
	return;
	end
 
 
    histogram[period]=1;
	
	
	 local  pipMultiplier = source:pipSize()*math.pow(10,source:getPrecision()%2);
	 
	 local L1, H1= mathex.minmax(source, period -SlowLength +1 ,period); 
	 local L2, H2= mathex.minmax(source, period -FastLength +1 ,period); 
 
         local High1 = H1+ SlowPipDisplace*pipMultiplier;
         local Low1  = L1 - SlowPipDisplace*pipMultiplier;
         local High2 = H2 + FastPipDisplace*pipMultiplier;
         local Low2  = L2 - FastPipDisplace*pipMultiplier;
		 
            if   source.close[period]>Line1[period-1]  then
            Line1[period] = Low1;
            else 
			Line1[period] = High1; 
            end            
            if   source.close[period]>Line2[period-1]  then
            Line2[period] = Low2;
            else  
			Line2[period] = High2;   
	        end
			
			 
			Trend[period] =  0;
			Cross[period]=Cross[period-1];
			
		
		       if (source.close[period]<Line1[period] and source.close[period]<Line2[period]) then
			   Trend[period] =  1;
			   end
               if (source.close[period]>Line1[period] and source.close[period]>Line2[period])  then
			   Trend[period] = -1; 
			   end
 
				   
				  if (Line1[period]>Line2[period] or Trend[period] ==  1)  then   Cross[period] =  1;  end
                 if (Line1[period]<Line2[period] or Trend[period] == -1)  then  Cross[period] = -1;  end	  
  
  
                 if Histogram then
				   
				    if Cross[period]== -1 then
					histogram:setColor(period, instance.parameters.color1);
					elseif Cross[period]== 1 then
					histogram:setColor(period, instance.parameters.color2);
					else
					histogram[period]=0;
					end
					
				 
				 else
				 
				     if Trend[period]== -1 then
					 histogram:setColor(period, instance.parameters.color1);
					elseif Trend[period]== 1 then
					histogram:setColor(period, instance.parameters.color2);
					else
					histogram[period]=0;
					end
				 
				 end
				 
	 
end
 