-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66614

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
    indicator:name("Average Number of Price Changes overview");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


 
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", " Period","" , 5);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("LabelSize", "Label Size", "", 10); 
	indicator.parameters:addInteger("xShift", "X Shift", "", 8); 
 
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 5);
	
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
 
	 indicator.parameters:addColor("Mark", "Current Hour Color", "", core.rgb(0, 0, 255));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local X,Y,xShift;
local LabelSize;
local font;
local Label;
local Mark;
local ShiftY;

local SourceData, loading;
local Data1={};
local Data2={};
local Count={};
local Current;
local Period;
local AVG1,AVG2;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 source = instance.source;
    first=source:first();
	
	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), "H1", source:isBid(), 300, 100, 101);
	loading=true;

    Y="Top";
	X=instance.parameters.X;  
	xShift=instance.parameters.xShift;
	LabelSize=instance.parameters.LabelSize;
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	Mark=instance.parameters.Mark;
	Period=instance.parameters.Period;
	 
   
 
    instance:ownerDrawn(true);
	
	core.host:execute ("setTimer", 1, 10);

	
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  
end
 
 
 
function Draw(stage, context)
 
	  if stage~= 2
	  or  loading
	  then
	  return;
	  end
	
 
	context:createFont (1, "Arial", LabelSize, LabelSize, 0);
 
   width0, height0 = context:measureText (1, "1", 0);
   
   
   
   

 
    
	local Text="Current";
	width, height = context:measureText (1, Text, 0);
    context:drawText (1,  Text, Label, -1,  iX(context,width0,xShift/2,1) ,  iY(context,height,1 ,0) ,iX(context,width,xShift/2,2),iY(context,height,1 ,1), 0 );	
	
    if AVG1~= nil then	
	Text= win32.formatNumber(AVG1, false, 0);
	width, height = context:measureText (1, Text, 0);
    context:drawText (1,  Text, Label, -1,  iX(context,width0,xShift/2,1) ,  iY(context,height,1+25 ,0) ,iX(context,width,xShift/2,2),iY(context,height,1+25 ,1), 0 );
	end
	
	Text="Average";
	width, height = context:measureText (1, Text, 0);
	context:drawText (1,  Text, Label, -1,  iX(context,width0,xShift*(3/2),1) ,  iY(context,height,1 ,0) ,iX(context,width,xShift*(3/2),2),iY(context,height,1 ,1), 0 );	
	
	if AVG2 ~= nil then
	Text= win32.formatNumber(AVG2, false, 0);
	width, height = context:measureText (1, Text, 0);
	context:drawText (1,  Text, Label, -1,  iX(context,width0,xShift*(3/2),1) ,  iY(context,height,1+25 ,0) ,iX(context,width,xShift*(3/2),2),iY(context,height,1+25 ,1), 0 );	
	end
	
   
   for i= 1, 24, 1 do
   width, height = context:measureText (1, i, 0);
   
	   if i== Current then
		context:drawText (1,  i, Label, Mark,  iX(context,width0,0,1) ,  iY(context,height,1+i,0) ,iX(context,width,0,2),iY(context,height,1+i,1), 0 );	
	   else
	   context:drawText (1,  i, Label, -1,  iX(context,width0,0,1) ,  iY(context,height,1+i,0) ,iX(context,width,0,2),iY(context,height,1+i,1), 0 );	
	   end
   end
   
   
   for i= 1, 24, 1 do
   if Data1[i]~= nil then
   Text= win32.formatNumber(Data1[i], false, 0);
   width, height = context:measureText (1, Text, 0);
   context:drawText (1,  Text, Label, -1,  iX(context,width0,xShift/2,1) ,  iY(context,height,1+i,0) ,iX(context,width,xShift/2,2),iY(context,height,1+i,1), 0 );	
   end
   end
   
   
   for i= 1, 24, 1 do
   if Data2[i]~= nil then
   Text= win32.formatNumber(Data2[i], false, 0);
   width, height = context:measureText (1, Text, 0);
   context:drawText (1,  Text, Label, -1,  iX(context,width0,xShift*(3/2),1) ,  iY(context,height,1+i,0) ,iX(context,width,xShift*(3/2),2),iY(context,height,1+i,1), 0 );	
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
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	
	
	  if not loading and cookie== 1 then 
	  
	    for i= 1, 24 , 1 do
		Data1[i]=0;  
        Data2[i]=0;      		
		Count[i]=0;
		end
		
		AVG1=0;
		local dateTable;
		for i= 1, 24 , 1 do
	    dateTable= core.dateToTable (SourceData:date(SourceData:size()-1 -i+1 ));
	
				if Data1[dateTable.hour+1]==0 then
				Data1[dateTable.hour+1]=SourceData.volume[SourceData:size()-1 -i+1 ];  
                Current= dateTable.hour+1;
                AVG1= AVG1+ Data1[i]; 				
				end		
		end
		
		AVG1=AVG1/24;
		
		for i= SourceData:size()-1, SourceData:first() , -1 do
	    dateTable= core.dateToTable (SourceData:date(i));
	
				if Count[dateTable.hour+1]< Period then
				Count[dateTable.hour+1]=Count[dateTable.hour+1]+1;		
				
				Data2[dateTable.hour+1]=Data2[dateTable.hour+1] + SourceData.volume[SourceData:size()-1 -i+1 ];  
                
				end		
		end
		
		AVG2= 0;
		for i= 1, 24 , 1 do
			if Count[i]~=0 then
			Data2[i]= Data2[i]/Count[i];
			AVG2= AVG2+ Data2[i];
			end
		end
		
		AVG2= AVG2/24;
		 
	  end
	
end

 