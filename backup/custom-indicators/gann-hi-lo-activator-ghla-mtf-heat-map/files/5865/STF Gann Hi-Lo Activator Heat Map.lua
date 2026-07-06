-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2610&p=93504#p93504


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
    indicator:name("Gann Hi-Lo Activator Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	 	 

		 
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "GHLA Period","", 14);
     indicator.parameters:addGroup("Style");
	
	indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutal Color","", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	--	indicator.parameters:addDouble("size", "Line Size","",10, 0, 100);
 -- indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",50, 0, 100);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",25, 0, 30);
end

 

local source;
local day_offset, week_offset;
--local Label = "";
local first;
local HSpace;
local Color;
--local size;
local host;
local  Period;
local Up, Down, Neutral;
local  GHLA;
--local Number=1;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    source = instance.source;	
	Period=instance.parameters.Period;
--VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	 host = core.host;
	--size=instance.parameters.size;
    Color=instance.parameters.Color;
    
 
   instance:setLabelColor(Color);
   instance:ownerDrawn(true);
   
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
	
	assert(core.indicators:findIndicator("GHLA") ~= nil, "Please, download and install GHLA.LUA indicator");    
  
 
  
  
	GHLA= core.indicators:create("GHLA",source , Period);  
	first=source:first();
	
end






function Update(period, mode)
 
	 
		 GHLA:update(mode); 
   
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	-- local Size = context:pointsToPixels(size);
	--local CellSize = math.floor(Size * 0.9);
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		    context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 1, Up)       
			context:createSolidBrush(12, Up);
			
			context:createPen (21, context.SOLID, 1, Down)       
			context:createSolidBrush(22, Down);
			
			
			context:createPen (31, context.SOLID, 1, Neutral)       
			context:createSolidBrush(32, Neutral);
			
			--context:createFont(3, "Arial", Size, CellSize, context.NORMAL);
            init = true;
        end
 
      
        local first = math.max(first, context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
        local p;
      -- local VS=(Size*VSpace);
       local i,j;
	   j=1;
	   local x0, x1, x2;
	   local style = context.SINGLELINE + context.CENTER + context.VCENTER;
       for i= first, last, 1 do	   
	   			   
			   x0, x1, x2 = context:positionOfBar (i);
					
					 local HS= HSpace;
					 --if x2-x1 <= Size then
					-- HS=0;
					-- end
					
					 
						
						  if GHLA.DATA:hasData(i) then
							  if source.close[i]> GHLA.DATA[i] then
							  context:drawRectangle (11, 12, x1+(x2-x1)*HS,  context:top(), x2-(x2-x1)*HS,  context:bottom());
							  elseif source.close[i]< GHLA.DATA[i] then
							  context:drawRectangle (21, 22, x1+(x2-x1)*HS,  context:top(), x2-(x2-x1)*HS, context:bottom());
							  else
							  context:drawRectangle (31, 32, x1+(x2-x1)*HS,  context:top(), x2-(x2-x1)*HS, context:bottom());
							  end
						  else
						       context:drawRectangle (1, 2, x1+(x2-x1)*HS, context:top(), x2-(x2-x1)*HS, context:bottom());
						  end
					
	   end
     
     
 
 
end


