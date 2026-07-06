-- Id: 14473
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62444

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Prediction MA");
    indicator:description("Prediction MA");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
  --  indicator.parameters:addString("Method", "Method", "Method", "MVA");
   -- indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
   -- indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");

	indicator.parameters:addDouble("Delta", "Delta", "Delta", 10);
	
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addInteger("transparency", "Transparency ", "Transparency ", 0);
    
    indicator.parameters:addColor("Top_color_Target", "Color of Top Target", "Color of Top", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Bottom_color_Target", "Color of Bottom Target", "Color of Bottom", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("Top_color_Move", "Color of Top Move", "Color of Top", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Bottom_color_Move", "Color of Bottom Move", "Color of Bottom", core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
--local Method;
local Delta;

local first;
local source = nil;

-- Streams block
local Top = nil;
local Bottom = nil;
local top,bottom;
local transparency;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    --Method = instance.parameters.Method;

    source = instance.source;
    first = source:first();
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(instance.parameters.Delta) .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	Delta = instance.parameters.Delta*source:pipSize();
 
   instance:ownerDrawn(true);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    
end


local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
        if not init then
            context:createPen (1, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Top_color_Target);
			context:createPen (2, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Bottom_color_Target);
			
		    context:createPen (3, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Top_color_Move);
			context:createPen (4, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Bottom_color_Move);
			
			transparency=context:convertTransparency (instance.parameters.transparency)
            init = true;
        end
     
	   local LastX=source:size()-1;
	   
       if LastX < Period then
	   return
	   end
	   	   
	   local Avg=mathex.avg(source, LastX-Period+1, LastX);
	   
	   local Value1=Avg+Delta;
	   local Value2=Avg-Delta;
	   
	   local TopX=Period*(Value1) ;
	   local BottomX=Period*(Value2) ;
	   
	   for i= 1 , Period-1 ,1 do
	   TopX=TopX-source[LastX-i];
	   BottomX=BottomX-source[LastX-i];
       end
	   
	 local x1=context:left();
     local x2=context:right();	 
	 visible, y1= context:pointOfPrice (Value1);
     context:drawLine (1, x1, y1, x2, y1, transparency); 
	 
	 visible, y2= context:pointOfPrice (Value2);
	 context:drawLine (2, x1, y2, x2, y2, transparency); 	 
	 
	 visible3, y3= context:pointOfPrice (TopX);
	 context:drawLine (3, x1, y3, x2, y3, transparency); 
	 
	 visible4, y4= context:pointOfPrice (BottomX);
     context:drawLine (4, x1, y4, x2, y4, transparency); 	 

 	   core.host:execute ("setStatus", " Top Target " .. win32.formatNumber(Value1, false, source:getPrecision())
                               	   ..  " Bottom Target " .. win32.formatNumber(Value2, false, source:getPrecision())
								   ..  " Top Move " .. win32.formatNumber(TopX, false, source:getPrecision()) 
								   ..  " Bottom Move " .. win32.formatNumber(BottomX, false, source:getPrecision())
								   );
end

