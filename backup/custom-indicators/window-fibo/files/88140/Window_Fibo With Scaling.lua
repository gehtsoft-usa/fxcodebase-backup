
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58796

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("Window Fibo indicator");
    indicator:description("Finds the maximum and minimum in the chart window and shows the Fibo levels.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	
	
	local i;
	local  Level={0, 23.6, 38.2, 50, 61.8, 76.4, 100};
	for i = 1,7, 1 do
	indicator.parameters:addGroup(i.. ". Level");
	indicator.parameters:addBoolean("On".. i, "Show "  , "", true);
	indicator.parameters:addDouble("Level".. i, "Level "  , "", Level[i]);
	end
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LineClr", "Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("LineWidth", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("LineStyle", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("LineStyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UpFiboClr", "Up Fibo Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnFiboClr", "Dn Fibo Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("FiboWidth", "Fibo width", "Fibo width", 1, 1, 5);
    indicator.parameters:addInteger("FiboStyle", "Fibo style", "Fibo style", core.LINE_DOT);
    indicator.parameters:setFlag("FiboStyle", core.FLAG_LINE_STYLE);
	indicator.parameters:addBoolean("Show" , "Show  Label"  , "", true);
	indicator.parameters:addInteger("Size" , "Font Size"  , "", 75);
end

local source = nil;
local first;
local Precision;
local Level={};
local On={};
local Show;
local Ratio;
local Size;
-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
	Size=instance.parameters.Size;
	Show=instance.parameters.Show;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);
    
    instance:setLabelColor(instance.parameters.LineClr);
    Precision = source:getPrecision();
end

function Update(period) 	
end

local init = false;

function Draw(stage, context)
    if stage == 0 then
    
        if not init then
            context:createPen(1, context:convertPenStyle(instance.parameters.LineStyle), instance.parameters.LineWidth, instance.parameters.LineClr);
            context:createPen(2, context:convertPenStyle(instance.parameters.FiboStyle), instance.parameters.FiboWidth, instance.parameters.UpFiboClr);
            context:createPen(3, context:convertPenStyle(instance.parameters.FiboStyle), instance.parameters.FiboWidth, instance.parameters.DnFiboClr);
           -- context:createFont(4, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
            init = true;
        end
		
		
		local top = context:top();
		local  bottom = context:bottom();
		  Ratio = math.abs(  math.abs(bottom -top)/1680 )
		
		 context:createFont(4, "Arial", 0, Size*Ratio, 0);
        
        local m, pH, pL;
        local xH, xL;

        local firstBar, lastBar = context:firstBar(), context:lastBar();
        firstBar = math.max(firstBar, first);
        lastBar = math.min(lastBar, source:size()-1);
        if firstBar<lastBar then
         local Min, MinPos = mathex.min(source.low, firstBar, lastBar);
         local Max, MaxPos = mathex.max(source.high, firstBar, lastBar);
         m, pL = context:pointOfPrice(Min);
         m, pH = context:pointOfPrice(Max);
         xL = context:positionOfBar(MinPos);
         xH = context:positionOfBar(MaxPos);
         context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
         context:drawLine(1, xL, pL, xH, pH);
         local Pen, Level0, Level100, X, P0, P100;
         local Color;
         if MinPos>MaxPos then
          Pen = 3;
          Level0 = pL;
          Level100 = pH;
          P0 = Min;
          P100 = Max;
          X = xH;
          Color = instance.parameters.DnFiboClr;
         else
          Pen = 2;
          Level0 = pH;
          Level100 = pL;
          P0 = Max;
          P100 = Min;
          X = xL;
          Color = instance.parameters.UpFiboClr;
         end
        
		
		local i;
		
		 for i = 1, 7, 1  do
		 
			 if instance.parameters:getBoolean ("On"..i) then
			 DrawLevel(context, Level0, Level100, instance.parameters:getDouble ("Level"..i) , P0, P100, X, Pen, Color);
			 end
		 
         end
         
         context:resetClipRectangle();
        end 

    end
end

function DrawLevel(context, level0, level100, level, p0, p100, x, pen, color)
 local y = level*(level100-level0)/100+level0;
 local p = level*(p100-p0)/100+p0;
 
 local right = context:right();
local  left = context:left();
 local top = context:top();
local  bottom = context:bottom();
local Off= false;

if math.abs(bottom -top) < 200 then
Off= true;
end

 




 context:drawLine(pen, x, y, right, y);
 local str = win32.formatNumber(p, false, Precision) .. " (" .. win32.formatNumber(level, false, 1) .. "%)";
 local w, h = context:measureText(4, str, context.LEFT);
 if Show and not Off then
  context:drawText(4, str, color, -1, math.max(left,x ), y-h, math.max(left,x )+w, y, context.RIGHT);
  end
 return;
end



