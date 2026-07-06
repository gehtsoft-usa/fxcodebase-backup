-- Id: 17809
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64525

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
    indicator:name("Weighted Side Standard Deviation");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period" ,  " Period", "", 14);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
 
       indicator.parameters:addColor("color2", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
end
 


local source;
local first;
local Period;
local Up;
local Down;


function Prepare(onlyName)
    source = instance.source;
	Period = instance.parameters.Period;
    first=source:first()+Period;
	
	 name = profile:id() .. "(" .. source:name() .. "," .. Period .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
	
 
    Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.color1, first);
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
    Up:setWidth(instance.parameters.width1);
    Up:setStyle(instance.parameters.style1);
	
	Down = instance:addStream("Down", core.Line, name .. ".Down", "Down", instance.parameters.color2, first);
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
    Down:setWidth(instance.parameters.width2);
    Down:setStyle(instance.parameters.style2);
end

function Update(period)
   
  if period < first then
  return;
  end
  
  
            local  sumsma1 = 0.0;
            local  sumsma2 = 0.0;
            local  weight1 = 0;
            local  weight2 = 0;
			
			for i= period-Period+1, period, 1 do
			 
			   if (source[i]-source[i-1])>0 then
			    
			    weight1=weight1+1;
				sumsma1  = sumsma1 + math.abs(source[i] - source[i - 1]) * weight1;
			   
			   elseif (source[i]-source[i-1])<0  then
			   
			    weight2=weight2+1; 
				sumsma2  = sumsma2 + math.abs(source[i] - source[i - 1]) * weight2;
			   end
			
			end
			
			
  
  
 

            local  su1 = summ(weight1);
            local su2 = summ(weight2);
            local average1 = sumsma1 / su1;
            local average2 = sumsma2 / su2;
            local sum1 = 0;
            local sum2 = 0;
			
 
 
            for i = period - Period + 1, period,1  do
            
                if (source[i] - source[i - 1] > 0) then
                    sum1  = sum1 + math.pow(math.abs(source[i] - source[i - 1]) - average1, 2.0);
                end
                if (source[i] - source[i - 1] < 0) then
                    sum2  = sum2 + math.pow(math.abs(source[i] - source[i - 1]) - average2, 2.0);
				end	
            end
 
            Up[period] = math.sqrt(sum1 / su1);
            Down[period] = math.sqrt(sum2 / su2);
  
end

function  summ( X)
        
            local  result = 0;
			
            for i = 1,  X, 1 do
                result= result+ i;
			end
			
            return result;
 end
 
