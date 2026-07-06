-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66639

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
    indicator:name("RSI Distribution");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("N", "RSI Perios", "Period", 14);
	indicator.parameters:addInteger("Period", "Period or 0 for All", "Period", 0);
	indicator.parameters:addInteger("BoxSize", "BoxSize", "Zone", 1);
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Color", "Color of Zone", "Color of Zone", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Label", "Color of Label", "Color of Label", core.rgb(0, 0, 255));
	indicator.parameters:addBoolean("Show", "Show Label", "", true);
	  indicator.parameters:addInteger("Transparency", "Transparency", "Transparency", 50);
	  
	  indicator.parameters:addGroup("Style");	
	  indicator.parameters:addDouble("OB", "OB Level", "Level", 70);
	  indicator.parameters:addDouble("OS", "OS Level", "Level", 30);
	  indicator.parameters:addColor("OB_Color", "OB Line Color", "Color of Zone", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("OS_Color", "OS Line Color", "Color of Zone", core.rgb(255, 0, 0));
	  indicator.parameters:addInteger("Size", "Size", "Size", 50);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Color; 
local Period = nil;
local BoxSize; 
local TPO;
local max;
local Min,Max;
local Show;
local Label; 
local Last;
local Transparency;
local N,RSI;
local OB, OS;
local Size;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	max=0;
	TPO = {};
	Last=nil;
	
	
    source = instance.source;
	RSI = core.indicators:create("RSI", source, N);
	 first = RSI.DATA:first();
	 
	 
	Color=instance.parameters.Color;
	Period=instance.parameters.Period;
	BoxSize=instance.parameters.BoxSize;
	Label=instance.parameters.Label;
	Show=instance.parameters.Show;
    N=instance.parameters.N;	
	OB=instance.parameters.OB;
	OS=instance.parameters.OS;
	Size=instance.parameters.Size;
	
	
	

   instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 

	RSI:update(mode);
	
	if period<= source:first() then
	TPO = {};
    max = 0; 
	--Min=math.huge;
	--Max=0;
	Min=0;
	Max=100;
	Last=nil;
	end
	
	
	
	period=period-1;
	
	
	
	if Last==source:serial(period) then
	return;
	end
	
	Last=source:serial(period);
	
	
	
	if Period==0 then
	         
		 local median=RSI.DATA [period];
       -- median = median / source:pipSize();
        median = median - median % BoxSize;
		
	    Max=math.max(Max, median);	
		Min=math.min(Min, median);	
	
			local v = rawget(TPO, median);
			
			
			if v == nil then
				v = 0;
			end 
			
			 
			v = v + 1;
			 
			 
			if v > max then
				max = v;
			end
			  
			 
			local v = rawset(TPO, median, v);
 
			 
	elseif Period~=0  and period >= source:size()-1 -Period +1 then
			 
		  local median=RSI.DATA [period];
          --  median = median / source:pipSize();
           median = median - median % BoxSize;
		   
		    Max=math.max(Max, median);	
	     	Min=math.min(Min, median);	
		
		
			local v = rawget(TPO, median);
			
			
			if v == nil then
				v = 0;
			end 
			
			 
			v = v + 1;
			 
			 
			if v > max then
				max = v;
			end
			  
			 
			local v = rawset(TPO, median, v);
 
			 
	end
	
 
end
 

 

local init = false;
 
function Draw(stage, context)
    if stage ~= 0
	or max==0 
	then
	return;
	end 
	
        if not init then
            context:createSolidBrush(1, Color);
			context:createSolidBrush(2, instance.parameters.OB_Color);			
			context:createSolidBrush(3, instance.parameters.OB_Color);			
			context:createSolidBrush(12, instance.parameters.OS_Color);			
			context:createSolidBrush(13, instance.parameters.OS_Color);
			Transparency = context:convertTransparency (instance.parameters.Transparency);	  
            init = true;
        end
		
        for k, v in pairs(TPO) do 	 
	    Add(context, k, v );			
        end

end

function Add(context,k,v )

        if v== nil or v==0 then
		return;
		end
		
 
		 local x1= context:left()  +  ((context:right() -context:left())/110) * ((k-BoxSize+10));
        local  x2=  context:left() +  ((context:right() -context:left())/110) * (k+10);
		local  y=context:bottom() -  v* ((context:bottom()-context:top())/max);
        
		if k== OB  then
		context:drawRectangle(2, 3, x1,y, x2, context:bottom(), Transparency);
		context:drawRectangle(2, -1, x1,context:top(), x2, context:bottom(), Transparency);
		elseif k== OS  then
		context:drawRectangle(12,13, x1,y, x2, context:bottom(), Transparency);
		 context:drawRectangle(12,-1, x1,context:top(), x2, context:bottom(), Transparency);
		else
		context:drawRectangle(-1, 1, x1,y, x2, context:bottom(), Transparency);
		end
		 
		if Show then
 
		context:createFont (4, "Arial", ((x2-x1)/100)*Size, ((x2-x1)/100)*Size, 0);
		width, height=context:measureText (4, tostring(v), 0);
		context:drawText (4, tostring(v) , Label, -1, x1, y, x2+width, y+height, 0, 0);
		end 
end
