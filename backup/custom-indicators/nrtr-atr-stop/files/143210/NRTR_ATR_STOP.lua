-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71420

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("NRTR_ATR_STOP");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
    indicator.parameters:addDouble("Coeficient", "Coeficient", "", 2, 0, 2000);
	
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Top Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Bottom Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
 
local Line;  
local ATR;
local Mode;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
    Coeficient= instance.parameters.Coeficient;
	
	
	local Parameters= Period..", "..Coeficient;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
	ATR = core.indicators:create("ATR", source, Period);
    first=ATR.DATA:first()+Period ;
  	
	Mode= instance:addInternalStream(0, 0);
 	
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.color1, first );
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)

    ATR:update(mode);
	
	if period < first
	then
	return;
	end
	
 	Mode[period]=Mode[period-1];
	Line[period]=Line[period-1];
	
    local AverageATR=mathex.avg(ATR.DATA, period-Period+1, period);
	local CoeficientATR= Coeficient*ATR.DATA[period];
 
	if period == first then 
	   
       if(ATR.DATA[period]  < AverageATR)  then
      
           Line[period-1] = source.low[period-1] - CoeficientATR; 
           Mode[period]=1;
		elseif(ATR.DATA[period]  > AverageATR)  then   
           Line[period-1] = source.high[period-1] + CoeficientATR; 
           Mode[period]=-1;
        end 
	else
	
	
 
       if( Mode[period-1] == -1 and  source.low[period-1] > Line[period-1]) then 
       
           Line[period-1] = source.low[period-1] - CoeficientATR; 
            Mode[period] = 1; 
        end
  
       if( Mode[period-1] == 1  and source.high[period-1] < Line[period-1]) then 
     
           Line[period-1] = source.high[period-1] + CoeficientATR; 
            Mode[period] = -1; 
        end
      
       if( Mode[period-1]==1) then 
      
           if(source.low[period-1] > Line[period-1] + CoeficientATR)  then 
           
               Line[period] = source.low[period-1] - CoeficientATR; 
            else
               Line[period] =Line[period-1];
		         end
		   end 
  
       if( Mode[period-1]==-1) then 
      
     	     if(source.high[period-1] < Line[period-1] - CoeficientATR) then 
     	     
     	         Line[period] = source.high[period-1] + CoeficientATR; 
     	               else
               Line[period] =Line[period-1];
     	      
	    
	          end
	    end
	
 
	end		

   if  Mode[period]==1 then
   Line:setColor(period, instance.parameters.color1);
   elseif  Mode[period]==-1 then   
	Line:setColor(period, instance.parameters.color2);  
   end

   if Mode[period]~= Mode[period-1] then
   Line:setBreak (period-1, true); 
   end   
end

 
