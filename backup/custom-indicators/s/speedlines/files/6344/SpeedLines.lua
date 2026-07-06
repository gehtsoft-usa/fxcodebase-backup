-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2783

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
    indicator:name("Speedlines");
    indicator:description("Speedlines");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Period", "Period", 100);
	indicator.parameters:addBoolean("Extend", "Extend Lines", "", false);

	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("COLOR", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;
local line_id = 0;
local Extend;
-- Streams block
local MIN, MAX, ONE, TWO;
local RANGE;
local dummy;

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
	Extend= instance.parameters.Extend;
    source = instance.source;
    first = source:first();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	dummy = instance:addStream("D", core.Dot, "", "", instance.parameters.COLOR, first, 300);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period < ( source:size()-1- Frame+1)
	or not  source:hasData(period) then
    return;
    end
	
	core.host:execute ("removeAll");
	
	local line_id = 0;
	
	
	
	   MIN, MAX, ONE, TWO = mathex.minmax( source,  period-Frame+1,period);
	   RANGE= MAX- MIN;
	   

		
	  if ONE < TWO then
		   if MIN ==  source.low[ONE] then 
		   
		   x1=ONE;
		   x2=TWO;
		   y1= source.low[ONE];
		   y2=  source.high[TWO];
		   
		   DrawLine(x1,y1,x2,y2, 0,-1,RANGE);
		   DrawLine(x1,y1,x2,y2, 33,-1,RANGE);
		   DrawLine(x1,y1,x2,y2, 50,-1,RANGE);
		   DrawLine(x1,y1,x2,y2, 66,-1,RANGE);		 
		   
		   else
		 
		   
		  x1=ONE;
		   x2=TWO;
		   y1= source.high[ONE];
		   y2 = source.low[TWO];
		   
		   DrawLine(x1,y1,x2,y2, 0,1,RANGE);
		   DrawLine(x1,y1,x2,y2, 33,1,RANGE);
		   DrawLine(x1,y1,x2,y2, 50,1,RANGE);
		   DrawLine(x1,y1,x2,y2, 66,1,RANGE);
		   
		   end
	   else
	         if MIN ==  source.low[TWO] then
			 
				 
					x1=TWO;
				   x2=ONE;
				   y1= source.low[TWO];
				   y2 = source.high[ONE];
				 
				  DrawLine(x1,y1,x2,y2, 0,-1,RANGE);
				   DrawLine(x1,y1,x2,y2, 33,-1,RANGE);
				   DrawLine(x1,y1,x2,y2, 50,-1,RANGE);
				   DrawLine(x1,y1,x2,y2, 66,-1,RANGE);
				   
			  else 
			  
				 
				   x1=TWO;
				   x2=ONE;
				   y1= source.high[TWO];
				   y2 = source.low[ONE];
				 
			       DrawLine(x1,y1,x2,y2, 0,1,RANGE);
				   DrawLine(x1,y1,x2,y2, 33,1,RANGE);
				   DrawLine(x1,y1,x2,y2, 50,1,RANGE);
				   DrawLine(x1,y1,x2,y2, 66,1,RANGE);
			   end
       end	   
  
end
 
function DrawLine(x1,y1,x2,y2, Label,Flag, Range)

    y2=y2+Range*(Label/100)*(Flag);
	
	
	if Extend then	
	 local a, c=math2d.lineEquation (x1, y1, x2, y2);
	 
	 if a== nil or c == nil then
	 return;
	 end
	 
	 y2=a*(source:size()-1)+c;
	 x2=source:size()-1;
	end
	
	


    line_id=line_id+1;
   core.host:execute("drawLine", line_id, source:date(x1), y1, source:date(x2),y2, instance.parameters.COLOR,   instance.parameters.style,  instance.parameters.width);
   line_id=line_id+1;   
	core.host:execute("drawLabel", line_id, source:date(x2), y2, Label);
 
end
 

-- get line equation coefficients
function getline(x1, y1, x2, y2)
    local a, b;

    a = ((y2 - y1) / (x2 - x1));
    b = (y1 - a * x1);
    return a, b;
end