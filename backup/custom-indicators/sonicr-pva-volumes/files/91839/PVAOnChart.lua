--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("PVA Volumes on chart");
    indicator:description("Shows volume in the main chart.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PVA_Climax_Period", "PVA Climax Period", "PVA Climax Period", 10);
    indicator.parameters:addInteger("PVA_Rising_Period", "PVA Rising Period", "PVA Rising Period", 10);
    indicator.parameters:addDouble("PVA_Rising_Factor", "PVA Rising Factor", "PVA Rising Factor", 1);
    indicator.parameters:addDouble("PVA_Extreme_Factor", "PVA Extreme Factor", "PVA Extreme Factor", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Position", "Position", "", "1");
    indicator.parameters:addStringAlternative("Position", "Top", "", "0");
    indicator.parameters:addStringAlternative("Position", "Bottom", "", "1");
    indicator.parameters:addInteger("Height", "Height (% of chart height)", "", 20);

    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
	
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128,128, 128));
	
	indicator.parameters:addColor("RisingBull", "Color of Rising Bull", "Color of Rising Bull", core.rgb(0,200, 0));	
	indicator.parameters:addColor("RisingBear", "Color of Rising Bear", "Color of Rising Bear", core.rgb(200,0, 0));
	
	indicator.parameters:addColor("ClimaxBull", "Color of Climax Bull", "Color of Climax Bull", core.rgb(0,255, 0));	
	indicator.parameters:addColor("ClimaxBear", "Color of Climax Bear", "Color of Climax Bear", core.rgb(255,0, 0));
end

local source = nil;
local first;
local transparency;
local Position;
local Height;
local Color;
local PVA_Climax_Period;
local PVA_Rising_Period;
local PVA_Rising_Factor;
local PVA_Extreme_Factor;
local ma_volume;
local Range;



-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;   

    if onlyName then
        return ;
    end

    instance:ownerDrawn(true);
	instance:setLabelColor(instance.parameters.Neutral);
    
    Position = tonumber(instance.parameters.Position)
    Height = instance.parameters.Height/100; 
    
    
 
    PVA_Climax_Period = instance.parameters.PVA_Climax_Period;
    PVA_Rising_Period = instance.parameters.PVA_Rising_Period;
    PVA_Rising_Factor = instance.parameters.PVA_Rising_Factor;
    PVA_Extreme_Factor = instance.parameters.PVA_Extreme_Factor;
    
	ma_volume = core.indicators:create("MVA", source.volume, PVA_Rising_Period);
    first = ma_volume.DATA:first();
	Color = instance:addInternalStream(0, 0);
	Range = instance:addInternalStream(0, 0);

	 assert(source:supportsVolume(), "The source must have volume");
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PVA_Climax_Period) .. ", " .. tostring(PVA_Rising_Period) .. ", " .. tostring(PVA_Rising_Factor) .. ", " .. tostring(PVA_Extreme_Factor) .. ")";
    instance:name(name);

   
 
 

    
end


function Update(period, mode)
if period < first then
return;
end
	
	Color[period]=  0;
	
	ma_volume:update(mode);
	
	if period < first or not  source:hasData(period) then
	return;
	end
	
	 if(source.volume[period] >= ma_volume.DATA[period] * PVA_Rising_Factor) then
	 
	  if(source.close[period] > source.open[period]) then	  
	    Color[period]=  1;	
	  end
	  
      if(source.close[period] <= source.open[period]) then
	  Color[period]=  2;	
	  end 
	 
	 end
	
	Range[period]= (source.high[period]-source.low[period])*source.volume[period];
	
	if period < PVA_Climax_Period then 
	return;
	end
	
	local max = mathex.max( Range, period -PVA_Climax_Period, period-1 );
	
	
    if Range[period] >=  max  or  (source.volume[period] >= ma_volume.DATA[period] * PVA_Extreme_Factor) then
	
			if(source.close[period] > source.open[period]) then
			   Color[period]=  3;
			  end
			  
			  if(source.close[period] <= source.open[period]) then		
			   Color[period]=  4;
			  end 
	  
	  
	end
	
	
end



local init = false;

function Draw(stage, context)
    if stage == 2 then
    
        if not init then
		
			
           context:createSolidBrush(15, instance.parameters.Neutral);
            context:createPen(	5, context.SOLID, 1, instance.parameters.Neutral);
			
			
			context:createSolidBrush(11, instance.parameters.RisingBull);
            context:createPen(1, context.SOLID, 1, instance.parameters.RisingBull);
			
			context:createSolidBrush(12, instance.parameters.RisingBear);
            context:createPen(2, context.SOLID, 1, instance.parameters.RisingBear);
			
			
			
			context:createSolidBrush(13, instance.parameters.ClimaxBull);
            context:createPen(3, context.SOLID, 1, instance.parameters.ClimaxBull);
			
			context:createSolidBrush(14, instance.parameters.ClimaxBear);
            context:createPen(4, context.SOLID, 1, instance.parameters.ClimaxBear);
			
			 
			
			
            transparency = context:convertTransparency(instance.parameters.transparency);
            init = true;
        end
    
        
        local firstBar, lastBar = context:firstBar(), context:lastBar();
        firstBar=math.max(firstBar, first);
        lastBar=math.min(lastBar, source:size()-1);
	
        local MaxVolume=mathex.max(source.volume, firstBar, lastBar);
        
        if MaxVolume==0 then
         return;
        end
        
        local top, bottom = context:top(), context:bottom();
        local HeightCoeff=(bottom-top)*Height/MaxVolume;
        
        local BarHeight;
        local barSrc;
        local y1, y2;

     --   context:startEnumeration();
        for i= firstBar, lastBar, 1 do
           -- index, x, x1, x2, c1, c2 = context:nextBar();
         --   if index == nil then
           --     break;
          --  end
            c, c1, c2 = context:positionOfBar (i);
            
            if barSrc==-1 then
             BarHeight=0;
            else
             BarHeight=HeightCoeff*source.volume[i];
            end

            if Position==0 then
             y1=top;
             y2=top+BarHeight;
            else
             y1=bottom-BarHeight;
             y2=bottom;
            end
            
			if Color[i]== 1 then
			 context:drawRectangle(1,  11, c1, y1, c2, y2, transparency);
			elseif Color[i]== 2 then
			 context:drawRectangle(2,  12, c1, y1, c2, y2, transparency);
			elseif Color[i]== 3 then
			 context:drawRectangle(3,  13, c1, y1, c2, y2, transparency);
			elseif Color[i]== 4 then
			 context:drawRectangle(4,  14, c1, y1, c2, y2, transparency);
			else
            context:drawRectangle(5,  15, c1, y1, c2, y2, transparency);
            end
        end

    end
end



