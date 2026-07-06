-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67123

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

function Init()
    indicator:name("Quadratic regression");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("length", "length", "", 100, 1, 2000);
 
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local length; 
local first;
local source = nil;
local x1, x2, x1x2, x2x2,yx1,yx2,y,yx1,yx2; 
local  Line;  
 

-- Routine
 function Prepare(nameOnly)    
 
    length= instance.parameters.length; 
	
	
	local Parameters= length  ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    first=source:first();
     
	x1= instance:addInternalStream(0, 0);
	x2= instance:addInternalStream(0, 0);
	x1x2= instance:addInternalStream(0, 0);
	x2x2= instance:addInternalStream(0, 0);
	yx1= instance:addInternalStream(0, 0);
	yx2= instance:addInternalStream(0, 0);
	y= instance:addInternalStream(0, 0);
 

  
     
	 Line = instance:addStream(" Line" , core.Line, "  Line","  Line",instance.parameters.color, first);
	 Line:setWidth(instance.parameters.width);
     Line:setStyle(instance.parameters.style);
    
	
	 
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
   -- Indicator[1]:update(mode);
  	
    if period < first then
	return;
	end
	
	y[period] = source[period];
	
	x1[period]= period;
	x2[period]=x1[period]*x1[period];
	x1x2[period]=x1[period]*x2[period];
	x2x2[period]=x2[period]*x2[period];
	
	yx1[period] = y[period]*x1[period];
	yx2[period] = y[period]*x2[period];
	
	
	if period < first+length then
	return;
	end
	
	
    local Sx1 = mathex.sum(x1, period-length+1, period);
	local Sx2 = mathex.sum(x2, period-length+1, period);
	local Sy=mathex.sum(y, period-length+1, period);
	local Sx1x2=mathex.sum(x1x2, period-length+1, period);
	local Sx2x2=mathex.sum(x2x2, period-length+1, period);
	local Syx1=mathex.sum(yx1, period-length+1, period);
	local Syx2=mathex.sum(yx2, period-length+1, period);
	
	local S11 =Sx2 - ((Sx1)^2)/length;
	local S12 = Sx1x2 - (Sx1 * Sx2)/length;
	local S22 = Sx2x2 - ((Sx2)^2)/length;
	local Sy1 = Syx1 - (Sy*Sx1)/length;
	local Sy2 =  Syx2 - (Sy*Sx2)/length;
	
	
	local max1= mathex.avg(x1, period-length+1, period);
	local max2= mathex.avg(x2, period-length+1, period);
	local may = mathex.avg(source, period-length+1, period);
	
	local b2 = ((Sy1 * S22) - (Sy2*S12))/(S22*S11 -  (S12)^2);
	local b3 = ((Sy2 * S11) - (Sy1 * S12))/(S22 * S11 -  (S12)^2);
	local b1 = may - b2*max1 - b3*max2;
	
	Line[period] = b1 + b2*x1[period] + b3*x2[period];
		
      
				  
end



