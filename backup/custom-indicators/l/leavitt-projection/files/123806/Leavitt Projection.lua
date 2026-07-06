-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67335

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
    indicator:name("Leavitt Projection");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
 
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
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
local x, xy, xx; 
local Oscillator;  
 
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period= instance.parameters.Period;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    first=source:first();
  
    x = instance:addInternalStream(0, 0);
    xy = instance:addInternalStream(0, 0);
	xx = instance:addInternalStream(0, 0);
	 
   
 
	Projection = instance:addStream("Projection" , core.Line, "Projection","Projection",instance.parameters.color, first+Period);
	Projection:setWidth(instance.parameters.width);
    Projection:setStyle(instance.parameters.style);
    Projection:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

  
	
	
    if period < first then
	return;
	end
	
	if period==first then
	x[period]=1;
	else
	x[period]=x[period-1]+1;
	end
	
	xy[period]=x[period]*source[period];
	xx[period]=x[period]*x[period]; 
	
	if period < first + Period then
	return;
	end
	local sum_x= mathex.sum(x, period-Period+1, period);
	local sum_y= mathex.sum(source, period-Period+1, period);
	local sum_xy= mathex.sum(xy, period-Period+1, period);
	local sum_xx= mathex.sum(xx, period-Period+1, period);
	
	local  a = (Period * sum_xy - sum_x * sum_y ) / ( Period *sum_xx -  sum_x*sum_x );
    local  b = (sum_xx * sum_y - sum_x * sum_xy ) / ( Period * sum_xx -  sum_x*sum_x );
 
		
     Projection[period]=a*x[period]+ b;
				  
end


--[[
script LeavittProjection{ input y = close; 
input n = 20; 
rec x = x[1] + 1;
 def a = (n * sum(x * y, n) - sum(x, n) * sum(y, n) ) / ( n *sum(Sqr(x), n) - Sqr(sum(x, n)));
 def b = (sum(Sqr(x), n) * sum(y, n) - sum(x, n) * sum(x *y, n) ) / ( n * sum(Sqr(x), n) - Sqr(sum(x, n)));
 plot LeavittProjection= a*x+ b; } 
 
 script LeavittConvolution { input   price = close; 
 input n = 20; def intLength = Floor(Sqrt(n)); 
 plot LeavittConvolution = LeavittProjection (LeavittProjection (price, n), intLength);
 }

 def price = Close; 
 input length = 9;
 def intLength = Floor(Sqrt(length)); 
 plot LeavittConvolution = LeavittProjection (LeavittProjection (price, length), intLength);
 LeavittConvolution.AssignValueColor(if LeavittConvolution > LeavittConvolution [1] then Color.GREEN else Color.RED);

]]
