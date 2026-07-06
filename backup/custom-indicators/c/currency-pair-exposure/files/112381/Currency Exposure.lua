-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64647

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
    indicator:name("Currency Exposure");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Consolidate", "Consolidate", "", true);

		
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Height", "Height as % of Chart", "", 100 , 50, 100);
    indicator.parameters:addInteger("Size", "Font Size as % of Cell Size", "", 100, 50, 150);
	indicator.parameters:addInteger("Spacing", "Spacing", "", 25, 0, 25); 
	indicator.parameters:addInteger("transparency", "Transparency", "",25, 0, 100); 
	 
	--indicator.parameters:addString("Orientation", "Orientation", "", "Vertical");    
    --indicator.parameters:addStringAlternative("Orientation", "Horizontal", "", "Horizontal");
    --indicator.parameters:addStringAlternative("Orientation", "Vertical", "", "Vertical");
	
 
    indicator.parameters:addBoolean("ShowLabel", "Show Label", "", true);
	 indicator.parameters:addBoolean("ShowNeutral", "Show Neutral", "", true);
    indicator.parameters:addColor("Up", "Long Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Short Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(128, 128, 128));		
    indicator.parameters:addColor("Label", "Label color", "", core.COLOR_LABEL);
   

end
local Spacing;
local Height; 
local fisrt, source;
local Up,Down, Neutral,Label;
local Placement;
local Size;
--local Number=5;
local  ShowLabel; 
--local Orientation;
local Transparency;
local Maximum;
local ShowNeutral;
local WeHave=0;
local Max;
local Index={};
local ValueLong;
local ValueShort;
local Consolidate;
 local pauto =  "(%a%a%a)/(%a%a%a)";
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    Placement= instance.parameters.Placement; 
    ShowLabel= instance.parameters.ShowLabel;
	ShowNeutral= instance.parameters.ShowNeutral;
	Consolidate= instance.parameters.Consolidate;
	Spacing= instance.parameters.Spacing;
    Size= instance.parameters.Size; 
    Height= instance.parameters.Height;
    Up= instance.parameters.Up;
	Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
    Label= instance.parameters.Label 
    source = instance.source;
    first= source:first();  
	 
 
	
	 
	   core.host:execute ("setTimer", 100, 1);
	  
	 instance:ownerDrawn(true);

end

function ReleaseInstance()
core.host:execute ("killTimer", 100);
end 



function Update(period, mode)
			
      
end


local init = false;
 
function Draw(stage, context)

 
if stage~= 2 
then
return;
end



    Transparency = context:convertTransparency (instance.parameters.transparency);

   
	ySize= context:bottom ()-context:top ();
	xSize= (context:right ()-context:left ())/(WeHave);   
  --- context:createFont (1, "Arial", xSize*(Spacing/100)/3, xSize*(Spacing/100)/3, 0);	
     
    
    --core.host:execute("setStatus", "WeHave: " ..  WeHave); 
   
   
    if ShowNeutral then 
	context:drawGradientRectangle (context:left (), context:top (), Neutral, context:right (), context:top (), Neutral, context:right (), context:bottom (), Neutral, context:left (), context:bottom (), Neutral,Transparency);
	end
	
 
	
   
   for i=1,  WeHave, 1 do
   Add(context, i,xSize,ySize, ValueLong[Index[i]],ValueShort[Index[i]]);
   end

   

end	

 function Add(context,id,xSize,ySize,Value3,Value4)
 
 
  
	
    y1=context:bottom ()-ySize*(Height/100); 
	y2=context:bottom ()-ySize*(Height/100); 
	y3=context:bottom ();
	y4=context:bottom ();	
	
	

	mid=y4-(y4-y2)/2;
	

	if Consolidate then
	
	local Delta=0;
	Delta=Value3-Value4;
		if Delta> 0 then
		Value3=Delta;
		Value4=0;
		else
		Value3=0;
	    Value4=-Delta;
		end
	end
	
	
	x1 =context:left ()+xSize*(Height/100)*(id) - xSize*(Spacing/100) ;
	x2=context:left ()+xSize*(Height/100)*(id-1) + xSize*(Spacing/100) ;
	
	x3=context:left ()+xSize*(Height/100)*(id-1) + xSize*(Spacing/100);
	x4=context:left ()+xSize*(Height/100)*(id) - xSize*(Spacing/100);
	
	 
	
	y1=mid-ySize*(Height/200)*(math.max(Value3)/Maximum); 
	y2=mid-ySize*(Height/200)*(math.max(Value3)/Maximum); 
	
	y3=mid+ySize*(Height/200)*(math.max(Value4)/Maximum); 
	y4=mid+ySize*(Height/200)*(math.max(Value4)/Maximum); 
	
	
	context:drawGradientRectangle (x1, y1, Up, x2, y2, Up, x3, mid, Up, x4, mid, Up,Transparency);
	
	context:drawGradientRectangle (x1, mid, Down, x2, mid, Down, x3, y3, Down, x4, y4, Down,Transparency);
	
	
 
	 
	
	

	
	
	if ShowLabel then 
	
	context:createFont (22, "Arial", (((x4-x1)/12)), (((x4-x1)/12)), 0);	
	
	
	if Value3 ~=0 then
 
	width, height = context:measureText (22, (Value3/1000).. "K", 0);
	context:drawText (22, (Value3/1000).. "K", Label, -1, x2, mid-height, x2+width, mid,0);
	
   	width, height = context:measureText (22,Index[id], 0);
	context:drawText (22, Index[id], Label, -1, x2, mid-height*2, x2+width, mid-height,0);
	
	end
	
	if Value4 ~=0 then 
	 
	
	width, height = context:measureText (22, (Value4/1000).. "K", 0);
	context:drawText (22, (Value4/1000).. "K", Label, -1, x2, mid+height, x2+width, mid+height*2,0);
	
		width, height = context:measureText (22, Index[id], 0);
	context:drawText (22, Index[id], Label, -1, x2, mid, x2+width, mid+height,0);
	
	end
	 
	end
	
	 
	 
 
	 
 end
 
 function AsyncOperationFinished(cookie)
 
 
 	 if cookie~= 100   then
	 return;
     end

	
		 
 
	Maximum=0; 
	WeHave=0;
    ValueLong={};
    ValueShort={};

	
	local enum, row;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
	
	
    while row ~= nil do
    

	    crncy1, crncy2 = string.match(row.Instrument, pauto);	 
		
		
	    if ValueLong[crncy1]== nil 
		then
		WeHave=WeHave+1;
		Index[WeHave]=crncy1;
		ValueLong[crncy1]=0;
		ValueShort[crncy1]=0; 
		end
		
		 if ValueLong[crncy2]== nil 
		then
		WeHave=WeHave+1;
		Index[WeHave]=crncy2;
		ValueLong[crncy2]=0;
		ValueShort[crncy2]=0; 
		end
	 
	 
     
		if row.BS == "B" then	
			ValueLong[crncy1]=ValueLong[crncy1]+ row.Lot;
            Maximum=math.max(Maximum, ValueLong[crncy1]);
			
			ValueShort[crncy2]=ValueShort[crncy2]+ row.Lot;
            Maximum=math.max(Maximum, ValueShort[crncy2]);
			
        end
		
		if row.BS == "S" then					
			ValueShort[crncy1]=ValueShort[crncy1]+ row.Lot;
			Maximum=math.max(Maximum, ValueShort[crncy1]);
			
			ValueLong[crncy2]=ValueLong[crncy2]+ row.Lot;
			Maximum=math.max(Maximum, ValueLong[crncy1]);
			
        end

        row = enum:next();
    end
 
 end