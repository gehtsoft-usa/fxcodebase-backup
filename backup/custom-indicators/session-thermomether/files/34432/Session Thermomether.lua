
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=19447

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
    indicator:name("Session Thermomether");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    
    
	AddSession(1,"Sidney", -7, 9 , core.rgb(128, 128, 128))
	AddSession(2,"Tokyo", -5, 9 ,core.rgb(128, 128, 128));
	AddSession(3,"London", 3, 9 ,core.rgb(128, 128, 128));
	AddSession(4,"New York", 8, 9,core.rgb(128, 128, 128) );
	 indicator.parameters:addGroup("Style"); 
--	 indicator.parameters:addBoolean("Consolidate", "Consolidate", "", true);
	indicator.parameters:addColor("Label" , "label Color", "Label Color", core.rgb(0, 0, 0)); 
	 indicator.parameters:addInteger("Height", "Height as % of Chart", "", 100 , 50, 100);
    indicator.parameters:addInteger("Size", "Font Size as % of Cell Size", "", 100, 50, 150);
	indicator.parameters:addInteger("Spacing", "Spacing", "", 25, 0, 25); 
	indicator.parameters:addInteger("transparency", "Transparency", "",25, 0, 100); 
	     indicator.parameters:addColor("Up", "Long Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Short Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));		
end

 

function AddSession(id,Name,From, Length,Color) 

     indicator.parameters:addGroup(id .. ". Session");	
  

    indicator.parameters:addString("Name"..id, "Session Name", "Session Name", Name); 
	indicator.parameters:addDouble("From"..id, "Session Start Time", "Session Start Time", From); 
	indicator.parameters:addDouble("Length"..id, "Session Length", "Session Length", Length);
    indicator.parameters:addColor("Color"..id, "Session Color", "Session Color", Color);
    
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Name={};
local From={};
local Length={};
local first;
local Transparency;
local source = nil;
--local ShowPriceTarget;
local Color = {};
 local Count;
 local Size;
 local Label; 
 local Open={};
 local Close={};
 
 local Maximum;
 local Source;
 local loading;
 local Spacing, Height, Label;
 --local Consolidate;
 local Up,Down,Neutral;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();  
	
	Spacing= instance.parameters.Spacing;
    Size= instance.parameters.Size; 
    Height= instance.parameters.Height;
	 Label= instance.parameters.Label;
	-- Consolidate= instance.parameters.Consolidate;
	 
	 Up= instance.parameters.Up;
	Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	
	Count=0;
	local i;
	
	for i= 1, 4,1 do	
	    
	   Count=Count+1;
		Color[Count]=instance.parameters:getDouble("Color" .. i);
		Name[Count]=instance.parameters:getString("Name" .. i);
		From[Count]=instance.parameters:getDouble("From" .. i);
		Length[Count]=instance.parameters:getDouble("Length" .. i);
	 
	end
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end 
 
  
	Source = core.host:execute("getSyncHistory", source:instrument(), "H1", source:isBid(), 0, 100, 101);
	loading=true;

	  
	 instance:ownerDrawn(true);

end

local init = false;
 
function Draw(stage, context)

 
if stage~= 2 
or loading
then
return;
end



    Transparency = context:convertTransparency (instance.parameters.transparency);

   
	ySize= context:bottom ()-context:top ();
	xSize= (context:right ()-context:left ())/(4);   

   if Open[1]== -1
   or Open[2]==-1
   or Open[3]== -1
   or Open[4]==-1
   or Close[1]==-1
   or Close[2]== -1
   or Close[3]==-1
   or Close[4]==-1
    or Open[1]==nil
   or Open[2]==nil
   or Open[3]==nil
   or Open[4]==nil
   or Close[1]==nil
   or Close[2]== nil
   or Close[3]==nil
   or Close[4]==nil
   then
   return;
   end
   
	
	Maximum=math.max(0,
	math.abs(Source.open[Open[1]]-Source.close[Close[1]]),
	math.abs(Source.open[Open[2]]-Source.close[Close[2]]),
	math.abs(Source.open[Open[3]]-Source.close[Close[3]]),
	math.abs(Source.open[Open[4]]-Source.close[Close[4]])
	);
   
   for i=1,  4, 1 do
   Add(context, i,xSize,ySize);
   end


end	

 function Add(context,id,xSize,ySize)
 
 
  
	
    y1=context:bottom ()-ySize*(Height/100); 
	y2=context:bottom ()-ySize*(Height/100); 
	y3=context:bottom ();
	y4=context:bottom ();	
	
	

	mid=y4-(y4-y2)/2;
	

	
	local Delta=0;
	Delta=Source.close[Close[id]]-Source.open[Open[id]];
		if Delta> 0 then
		Value3=Delta;
		Value4=0;
		else
		Value3=0;
	    Value4=-Delta;
		end

	
	
	x1 =context:left ()+xSize*(Height/100)*(id) - xSize*(Spacing/100) ;
	x2=context:left ()+xSize*(Height/100)*(id-1) + xSize*(Spacing/100) ;
	
	x3=context:left ()+xSize*(Height/100)*(id-1) + xSize*(Spacing/100);
	x4=context:left ()+xSize*(Height/100)*(id) - xSize*(Spacing/100);
	
 
	
	
	y1=mid-ySize*(Height/200)*(Value3/Maximum); 
	y2=mid-ySize*(Height/200)*(Value3/Maximum); 
	
	y3=mid+ySize*(Height/200)*(Value4/Maximum); 
	y4=mid+ySize*(Height/200)*(Value4/Maximum); 
	
	
	context:drawGradientRectangle (x1, y1, Up, x2, y2, Up, x3, mid, Up, x4, mid, Up,Transparency);
	
	context:drawGradientRectangle (x1, mid, Down, x2, mid, Down, x3, y3, Down, x4, y4, Down,Transparency);
	
	
 
	 



	
	context:createFont (22, "Arial", (((x4-x1)/12)), (((x4-x1)/12)), 0);	
	
	
	if Value3 ~=0 then
    Value= win32.formatNumber(Value3/source:pipSize(), false, 2);
	
	width, height = context:measureText (22, Value, context.CENTER);
	context:drawText (22, Value, Label, -1, x2, mid-height, x4, mid,context.CENTER);
	
   	width, height = context:measureText (22,Name[id],context.CENTER);
	context:drawText (22, Name[id], Color[id], -1, x2, mid-height*2, x4, mid-height,context.CENTER);
	
	end
	
	if Value4 ~=0 then 
	 
	 Value= win32.formatNumber(Value4/source:pipSize(), false, 2);
	width, height = context:measureText (22, Value, context.CENTER);
	context:drawText (22, Value, Label, -1, x2, mid+height, x4, mid+height*2,context.CENTER);
	
		width, height = context:measureText (22, Name[id],context.CENTER);
	context:drawText (22, Name[id], Color[id], -1, x2, mid, x4, mid+height,context.CENTER);
	
	end
	 

	
	 
 end
 
 

function Process(session, period)
 
 local date = Source:date(period);       -- bar date;
  

   local sfrom, sto;

    -- 1) calculate the session to which the specified date belongs
    local t;
    t = math.floor(date * 86400 + 0.5);     -- date/time in seconds

    -- shift the date so it is in the virtual time zone in which 0:00 is the begin of the session
    t = t - From[session] * 3600;
    -- truncate to the day only.
    t = math.floor(t / 86400 + 0.5) * 86400;
    -- and shift it back to est time zone
    t = t + From[session] * 3600;

    sfrom = t;                          -- begin of the session
    sto = sfrom + Length[session] * 3600;   -- end of the session
	
	sfrom = sfrom / 86400;
    sto = sto / 86400;
	
    if Open[session]== nil  then
	p1= core.findDate (Source, sfrom, false);
	p2= core.findDate (Source, sto, false); 
	
		if p1~=-1 and p2~=-1 and ( p1~= p2 or(Source[Source:size()-1] == p1 or  Source[Source:size()-1] == p2 )) then
		Open[session]=p1;
		Close[session]=p2;
		end
	end
	
end
 
function Update(period)

    
	if loading or period < source:size()-1 then
	return;
	end
	
	Open={};
	Close={};
 
 
    local Flag=false; 
	
	for period= Source:size()-1 , Source:first(), -1 do
	
				
		 
						
						for session= 1, Count ,1 do 
						Process(session,period ); 
						end		 
						
						if Open[1]~= -1
						and Open[1]~= nil
						and Open[2]~= -1
						and Open[2]~= nil
						and Open[3]~= -1
						and Open[3]~= nil
						and Open[4]~= -1
						and Open[4]~= nil				
						and Close[1]~= -1
						and Close[1]~= nil
						and Close[2]~= -1
						and Close[2]~= nil
						and Close[3]~= -1
						and Close[3]~= nil
						and Close[4]~= -1
						and Close[4]~= nil
						then 
                 
						if Flag then
						break;
						end		
                end				
				
    end
	
	--[[
	 core.host:execute("setStatus",Open[1].."/".. Close[1].. "   "
	 .. Open[2].."/".. Close[2].. "   "
	 .. Open[3].."/".. Close[3].. "   "
	 .. Open[4].."/".. Close[4].. "   "
	 ); ]]
	
    
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


