
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65872

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
    indicator:name("Average True Range on Chart");
    indicator:description("Average Daily Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	   
	
	indicator.parameters:addGroup("ADR Calculation");
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addInteger("N", "ADR Periods", "", 14);	
	indicator.parameters:addDouble("Multiplier", "Multiplier", "", 1);
	
 
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" ,  "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
end

 
local source;
 local Source, loading;
local N;
local TF;
local host;
local first;
local Multiplier;
local ATR;


local X,Y;
local Label;
local Size;
local ShiftY;

function Prepare(nameOnly)  
    
    N=instance.parameters.N;	
	Multiplier=instance.parameters.Multiplier;
	TF=instance.parameters.TF;
	
	
	Y=instance.parameters.Y;
	X=instance.parameters.X; 
	
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
	 
    local name =  profile:id() .. ","  .. instance.source:name() ;
	instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
    source = instance.source;
	first= source:first()+N;
    host = core.host;
   
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), N, 100, 101);
	loading=true;
	ATR = core.indicators:create("ATR", Source, N);
	
	    instance:ownerDrawn(true);

	 
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end
 

function Update(period, mode)
 
		ATR:update(mode);
end


 
 
 local init = false;
 
function Draw(stage, context)
 
	  if loading
	  or stage~= 2 
	  then
	  return;
	  end
	  
	  
	  
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	

	local Text1=  "ATR : " ..   win32.formatNumber(	ATR.DATA[ATR.DATA:size()-1], false, source:getPrecision());
	

	 
   local i=1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   

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
 
