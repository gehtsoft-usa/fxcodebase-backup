
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59801


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
    indicator:name("Hi/Lo Line");
    indicator:description("Hi/Lo Line");
     indicator:setTag("AllowAllSources", "y");
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Type", "Visible Screen/Data Stream", "", "Visible Screen");
    indicator.parameters:addStringAlternative("Type", "Visible Screen", "", "Visible Screen");
    indicator.parameters:addStringAlternative("Type", "Data Stream", "", "Data Stream");
	
	indicator.parameters:addString("Position", "Position of Distance between the lines", "", "Top");
    indicator.parameters:addStringAlternative("Position", "Top", "", "Top");
    indicator.parameters:addStringAlternative("Position", "Bottom", "", "Bottom");
	indicator.parameters:addStringAlternative("Position", "Not used", "", "Not");
	
	indicator.parameters:addBoolean("Show", "Show Midpoint", "", false);

	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of Top Line", "Color of Top Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color2", "Color of Bottom Line", "Color of Bottom Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3", "Color ofMidpoint Line", "Color of Midpoint Line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color4", "Label Color", "Label Color", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local Position; 
local source = nil;
local Type;
local init = false;
local Precision;
local Show;
-- Routine
function Prepare(nameOnly)
	
  
   source = instance.source;  
	Type=instance.parameters.Type;
	Position=instance.parameters.Position;
	Show=instance.parameters.Show;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type) .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end

    instance:ownerDrawn(true);   
    instance:setLabelColor(instance.parameters.color4);
	Precision = source:getPrecision();
	
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

   
   
end


function Draw(stage, context)
    if stage ~= 0 then
	return;
	end
	
	
        if not init then
            context:createPen(1, context:convertPenStyle(instance.parameters.style1), instance.parameters.width1, instance.parameters.color1);
            context:createPen(2, context:convertPenStyle(instance.parameters.style2), instance.parameters.width2, instance.parameters.color2); 
            context:createPen(4, context:convertPenStyle(instance.parameters.style3), instance.parameters.width3, instance.parameters.color3);                 
            context:createFont(3, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
            init = true;
			
       end
				 
		
			   local min, max;
			   local first, last;
			   
			   if Type ==  "Visible Screen" then
			   first, last = context:firstBar(), context:lastBar();
			   first = math.max(first, source:first());
			   last = math.min(last, source:size()-1);
			   min, max=mathex.minmax(source, first, last);   
			   else
			   first= source:first();
			   last=  source:size()-1;
			   min, max=mathex.minmax(source, first, last);   
			   end   
			   
			   local mid = min+((max-min)/2);
			   local visiblemin, xmin,  visiblemax, xmax;
			      visiblemin, xmin  = context:pointOfPrice(min);
                  visiblemax, xmax = context:pointOfPrice(max);
				   visiblemid, xmid = context:pointOfPrice(mid);
			 
		    
			local left=context:left();
			local right=context:right()
			
			context:drawLine(2, left, xmin, right, xmin);
			context:drawLine(1, left, xmax, right, xmax);
			context:drawLine(4, left, xmid, right, xmid);
			
			local str , w, h 
			 
			
			 str = win32.formatNumber(min, false, Precision);
			 w, h = context:measureText(3, str, context.RIGHT);
			 context:drawText(3, str, instance.parameters.color4, -1, right-w, xmin-h, right, xmin, context.RIGHT);
	 
	 
	         str = win32.formatNumber(max, false, Precision) ;
			 w, h = context:measureText(3, str, context.RIGHT);
			 context:drawText(3, str, instance.parameters.color4, -1, right-w, xmax-h, right, xmax, context.RIGHT);
			 
			 str = win32.formatNumber(mid, false, Precision) ;
			 w, h = context:measureText(3, str, context.RIGHT);
			 context:drawText(3, str, instance.parameters.color4, -1, right-w, xmid-h, right, xmid, context.RIGHT);
			 
			 
			 str = win32.formatNumber((max-min)/source:pipSize(), false, 1) ;
			 w, h = context:measureText(3, str, context.RIGHT);
			 
			 if Position == "Top" then
			 context:drawText(3, str, instance.parameters.color4, -1,  right-w, xmax,right, xmax+h,  context.RIGHT);
			 elseif Position == "Bottom" then
			  context:drawText(3, str, instance.parameters.color4, -1,  right-w, xmin,right, xmin+h,  context.RIGHT);
             end
end

