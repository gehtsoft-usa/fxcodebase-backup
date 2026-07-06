-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60016&hilit=levels

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



function AddParam(id, Enable, Level, Color, Width, Style)

    indicator.parameters:addGroup(id..". Line");	
    indicator.parameters:addBoolean("Enable" .. id, "Enable level " .. id, "", Enable);
    indicator.parameters:addInteger("Level" .. id, "Level " .. id .. " (Last digits)", "", Level);
    indicator.parameters:addColor("Color" .. id, "Level " .. id .. " color", "", Color);
    indicator.parameters:addInteger("Width" .. id, "Level " .. id .. " width", "", Width);
    indicator.parameters:addInteger("Style" .. id, "Level " .. id .. " style", "", Style);
    indicator.parameters:setFlag("Style" .. id, core.FLAG_LINE_STYLE);
end

local pipSize;
local ShowLabels;
local FontSize;
local DigitsNumber;
local Dig;

function Init()
    indicator:name("Prime levels indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("LookBack", "LookBack Period", "", 0);
 
	
    indicator.parameters:addInteger("DigitsNumber", "Number of last digits", "", 2);
    
	
	
    AddParam(1, true, 0, core.rgb(255, 0, 0), 1, core.LINE_SOLID);
    AddParam(2, true, 50, core.rgb(0, 0, 255), 1, core.LINE_DASH);
    AddParam(3, true, 17, core.rgb(128, 128, 0), 1, core.LINE_DOT);
	
    AddParam(4, true, 83, core.rgb(0, 255, 0), 1, core.LINE_SOLID);
    AddParam(5, true, 67, core.rgb(0, 128, 128), 1, core.LINE_DASH);
    AddParam(6, true, 33, core.rgb(255, 255, 0), 1, core.LINE_DOT);
	
    AddParam(7, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(8, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DASH);
    AddParam(9, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DOT);
	
    AddParam(10, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);	
	AddParam(11, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DASH);
    AddParam(12, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DOT);
	
    AddParam(13, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(14, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DASH);
    AddParam(15, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DOT);
	
    AddParam(16, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(17, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DASH);
    AddParam(18, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DOT);
	
    AddParam(19, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(20, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DASH);
	
    
    indicator.parameters:addBoolean("ShowLabels", "Show labels", "", true);
    indicator.parameters:addInteger("FontSize", "Labels font size", "", 0);
end

local source = nil;

-- initializes the instance of the indicator
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
    pipSize = source:pipSize();
	LookBack=instance.parameters.LookBack;
    ShowLabels=instance.parameters.ShowLabels;
    DigitsNumber=instance.parameters.DigitsNumber;
    Dig=math.pow(10, DigitsNumber);
    FontSize=instance.parameters.FontSize;
 

    instance:ownerDrawn(true);
    
    instance:setLabelColor(instance.parameters.Color1);
end

function Update(period)
end

local init = false;

function Draw(stage, context)
 local i, iLevel;
    if stage == 0 then
    
        if not init then
            for i=1, 20, 1 do
             context:createPen(i, context:convertPenStyle(instance.parameters:getInteger("Style" .. i)), instance.parameters:getInteger("Width" .. i), instance.parameters:getColor("Color" .. i));
            end 
            if FontSize==0 then
               context:createFont(21, "Arial", 0, -context:pointsToPixels(pipSize), 0);
            else  
               context:createFont(21, "Arial", 0, FontSize, 0);
            end 
            init = true;
        end
        
        local top, bottom = context:top(), context:bottom();
        local topPrice, bottomPrice = context:priceOfPoint(top), context:priceOfPoint(bottom);
        local left, right = context:left(), context:right();
		
		if LookBack~=0 then
		newleft, x1, x2 = context:positionOfBar (source:size()-1-LookBack)
		left=math.max(left,newleft);
		end
		
        
        local MaxLevel, MinLevel;
        local Level;
        local v, y;
        local w, h;
        for i=1, 20, 1 do
         if instance.parameters:getBoolean("Enable" .. i) then
          Level=instance.parameters:getInteger("Level" .. i)*pipSize;
          MaxLevel=math.floor((topPrice-Level)/(Dig*pipSize))*(Dig*pipSize)+Level;
          MinLevel=math.ceil((bottomPrice-Level)/(Dig*pipSize))*(Dig*pipSize)+Level;
          iLevel=MinLevel;
          while iLevel<=MaxLevel do
           v, y=context:pointOfPrice(iLevel);
           context:drawLine(i, left, y, right, y);
           if ShowLabels then
            w, h=context:measureText(21, iLevel, context.LEFT);
            context:drawText(21, iLevel, instance.parameters:getColor("Color" .. i), -1, right-w, y, right, y+h, context.CENTER+context.VCENTER);
           end
           iLevel=iLevel+Dig*pipSize;
          end
         end
        end

    end
end



