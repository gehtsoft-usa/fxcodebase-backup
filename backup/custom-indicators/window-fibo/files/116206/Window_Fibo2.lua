
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
end

local source = nil;
local first;
local Precision;
local Level={};
local On={};

local OutLevels={};

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);

    local i;
    for i=1, 7, 1 do
      OutLevels[i]=instance:addStream("Level" .. i, core.Line, name .. ".Level" .. i, "Level" .. i, instance.parameters.LineClr, first);
      OutLevels[i]:setVisible(false);
    end
    
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
            context:createFont(4, "Arial", 0, -context:pointsToPixels(source:pipSize()), 0);
            init = true;
        end
        
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
    local LL;
		
		 for i = 1, 7, 1  do
       LL=instance.parameters:getDouble ("Level"..i);
		   OutLevels[i][source:size()-1]=LL*(Max-Min)/100+Min;
			 if instance.parameters:getBoolean("On"..i) then
			   DrawLevel(context, Level0, Level100, LL , P0, P100, X, Pen, Color);
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
 context:drawLine(pen, x, y, right, y);
 local str = win32.formatNumber(p, false, Precision) .. " (" .. win32.formatNumber(level, false, 1) .. "%)";
 local w, h = context:measureText(4, str, context.RIGHT);
 context:drawText(4, str, color, -1, right-w, y-h, right, y, context.RIGHT);
 return;
end



