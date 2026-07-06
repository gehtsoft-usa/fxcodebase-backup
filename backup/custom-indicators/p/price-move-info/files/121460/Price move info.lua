-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66726

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Price move info");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	
	indicator.parameters:addString("TF1", "1. Time Frame", "", "D1");
	indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
	
	indicator.parameters:addString("TF2", "2. Time Frame", "", "W1");
	indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
	
	indicator.parameters:addString("TF3", "3. Time Frame", "", "M1");
	indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 1);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local X,Y;
local font;
local Label;
local Size;
local ShiftY;
local TF={};
local Source={};
local loading={};

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
	
	TF[1]=instance.parameters.TF1;
	TF[2]=instance.parameters.TF2;
	TF[3]=instance.parameters.TF3;
	
	for i= 1, 3, 1 do
	Source[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), first, 100*(i), 100*(i)+1);
	loading[i]=true;
	end
 
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  
end
 
local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 
	  or loading[1] 
	  or loading[2]  
	  or loading[3]   
	  then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
			
	local Text;
	 
	 
   for i= 1, 3, 1 do
		   if Source[i].close:hasData(Source[i].close:size()-1) then
		   Text=TF[i] .. " : "..  win32.formatNumber((Source[i].close[Source[i].close:size()-1]-Source[i].open[Source[i].open:size()-1])/source:pipSize(), false, 2);
		   width, height = context:measureText (1, Text, 0);
		   context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
		   end
   end

end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


   for i= 1, 3 , 1 do
		if cookie == 100*i then
			loading[i] = false;
		elseif cookie == (100*i+1)  then
			loading[i] = true;
		end
	
	end
	
	
	if not loading[1] and not loading[2]  and not loading[3] then
		instance:updateFrom(0);
	end		
end

