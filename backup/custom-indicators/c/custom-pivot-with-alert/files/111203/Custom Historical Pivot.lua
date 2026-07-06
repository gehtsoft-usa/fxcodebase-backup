-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64483
-- Id: 17836

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Custom Historical Pivot");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
    indicator.parameters:addGroup("Calculation"); 
 
   indicator.parameters:addBoolean("Historical", "Show Historical", "", false);

    indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	local iLevel={0,38,61,78,100,138,161,200};
  	indicator.parameters:addInteger("iShift", "Shift", "", 0);
  
  

    for i=2, 8, 1 do	
		
		indicator.parameters:addDouble("Level"..i, (i-1)..". Level", "", iLevel[i]);		
		
	end
	
	indicator.parameters:addBoolean("level_value_in_label", "Show Level Value in Label", "", false);
	
	
	local Color={core.rgb(128, 128, 128), core.rgb(255, 0, 0), core.rgb(0, 255, 0), core.rgb(0, 0, 255), core.rgb(128, 255, 0), core.rgb(255, 128, 0), core.rgb(128, 0, 255), core.rgb(255, 0, 128)};
	
	for i=1, 8, 1 do	
	 if i== 1 then
	  indicator.parameters:addGroup("Pivot Line Style"); 
	 else
	 indicator.parameters:addGroup((i-1)..". Line Style"); 
	 end
	indicator.parameters:addColor("Color"..i, "Line Color", "", Color[i]);  
    indicator.parameters:addInteger("Width"..i, "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Style"..i, "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..i, core.FLAG_LINE_STYLE);
	end
 
	      indicator.parameters:addColor("iLabel", "Label Color", "Label", core.COLOR_LABEL );
		indicator.parameters:addInteger("iSize", "Font Size", "", 20);		
	indicator.parameters:addInteger("Size", "Arrow Size", "", 10, 1 , 100);
	


	
end



local Size;
local Historical;

local source;                    
 
 
      local LabelText={"PP", "R1", "R2", "R3", "R4",  "R5", "R6", "R7", "S1", "S2", "S3", "S4",  "S5", "S6", "S7"  } ;
	  local Value= {};
     local FinalLevel={};	--Level
	 local Level={};
     local Color={};
     local Style={};
     local Width={};	
     local Histogram={};	 
      local TF;
	  local Source;
	  local loading = false;
	  local iShift;
	  local iLabel;
	  local iSize;
	  local day_offset, week_offset;
function Prepare(nameOnly)
    source = instance.source;
	first=source:first();  
    local name = profile:id() ;
	instance:name(name); 
	if nameOnly then
		return;
	end
	
	day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");
	 
	Size=instance.parameters.Size;
	Historical=instance.parameters.Historical;
	
	if instance.parameters.level_value_in_label then
		LabelText = {"PP",
					 "R" .. instance.parameters.Level2,
					 "R" .. instance.parameters.Level3,
					 "R" .. instance.parameters.Level4,
					 "R" .. instance.parameters.Level5,
					 "R" .. instance.parameters.Level6,
					 "R" .. instance.parameters.Level7,
					 "R" .. instance.parameters.Level8,
					 "S" .. instance.parameters.Level2,
					 "S" .. instance.parameters.Level3,
					 "S" .. instance.parameters.Level4,
					 "S" .. instance.parameters.Level5,
					 "S" .. instance.parameters.Level6,
					 "S" .. instance.parameters.Level7,
					 "S" .. instance.parameters.Level8};
	end
	
 
    TF = instance.parameters.TF;
	iShift = instance.parameters.iShift;
	iLabel = instance.parameters.iLabel;
	iSize = instance.parameters.iSize;
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;
	

	 
	 for i=1, 8 , 1 do
		 if i==1 then
		 Level[i]=0;
		 else	 
		 Level[i]=instance.parameters:getDouble("Level" ..i);
		 end
		 
		 Color[i]=instance.parameters:getColor("Color" ..i)
         Style[i]=instance.parameters:getInteger("Style" ..i)
         Width[i]=instance.parameters:getInteger("Width" ..i)
 
	 end
	 
	 	 FinalLevel[1]= nil;	
          instance:ownerDrawn(true);
  
  
    if Historical then
	   for i=1, 8 , 1 do
	   
	 
	       Histogram[i]= instance:addStream(LabelText[i], core.Line, name .. LabelText[i], LabelText[i], Color[i], source:first()); 
	       Histogram[i]:setWidth(Width[i]);
           Histogram[i]:setStyle(Style[i]);  
	    
		   if i~= 1 then	   
		   Histogram[i+7]= instance:addStream(LabelText[i+7], core.Line, name .. LabelText[i+7], LabelText[i+7], Color[i], source:first());
		   Histogram[i+7]:setWidth(Width[i]);
		   Histogram[i+7]:setStyle(Style[i]); 
		   end
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
end

local init=false;
function Draw(stage, context)
    if stage ~= 2
	or FinalLevel[1]== nil
	then
	return;
	end
	
		context:createFont (10, "Arial",   iSize, iSize, 0);
	
        if not init then		
				for i= 1, 8, 1 do
				context:createPen (i, context:convertPenStyle (Style[i]), context:pointsToPixels (Width[i]), Color[i]);
				end
		init = true;
		end
		
		for i= 1, 8, 1 do
		
			if i == 1 then
			visible, y1= context:pointOfPrice (FinalLevel[i]);
			
			if not Historical then
			context:drawLine (i,context:left (), y1, context:right (), y1);
			end
			
			
				width, height=context:measureText (10, LabelText[i], 0);
				if not Historical then
				context:drawText (10, LabelText[i], iLabel, -1, context:right ()-width, y1+height, context:right (), y1, 0);
				else
				x, x1, x2= context:positionOfBar (source:size()-1);
				context:drawText (10, LabelText[i], iLabel, -1, x2+width/4, y1-height, x2+width/4+width , y1, 0);
				end
			else
			
			visible, y1= context:pointOfPrice (FinalLevel[i]);
			if not Historical then
			context:drawLine (i,context:left (), y1, context:right (), y1);
			end
			
			visible, y2= context:pointOfPrice (FinalLevel[i+7]);		
			if not Historical then
			context:drawLine (i,context:left (), y2, context:right (), y2);
			end
			
				width1, height1=context:measureText (10, LabelText[i], 0);
				width2, height2=context:measureText (10, LabelText[i+7], 0);
				
				if not Historical then
				context:drawText (10, LabelText[i], iLabel, -1, context:right ()-width1, y1-height1, context:right (), y1, 0);
				context:drawText (10, LabelText[i+7], iLabel, -1, context:right ()-width2, y2-height2, context:right (), y2, 0);
				else
				x, x1, x2= context:positionOfBar (source:size()-1);
				context:drawText (10, LabelText[i], iLabel, -1, x2+width1/4, y1-height1, x2+width/4+width, y1, 0);
				context:drawText (10, LabelText[i+7], iLabel, -1, x2+width2/4, y2-height2, x2+width/4+width, y2, 0);
				end
			
			end
			
			 
		end
	
		
		
end		


 
 
 local LastZone=0;
-- the function which is called to calculate the period
function Update(period  ) 	 

	if loading then
	return;
	end

   local Last;
   local p;
 
      if not Historical then
	     if period < source:size()-1  then
		 return;
		 end
	  
         Last= Source:size()-1-iShift;
	  else	  
           p= core.findDate (Source, source:date(period), false);
		  if p==-1 then
		  return;
		  end 
	      Last= p-iShift;
	  end
	  
      local  PreviousHigh  = Source.high[Last];
      local PreviousLow   = Source.low[Last];
      local PreviousClose = Source.close[Last];
	  
	  
      FinalLevel[1]  =  (PreviousHigh+PreviousLow+PreviousClose)/3;--1
	  FinalLevel[2] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *(Level[2]/100));
      FinalLevel[9] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[2]/100));
      FinalLevel[3] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[3]/100));
      FinalLevel[10] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[3]/100));
      FinalLevel[4] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[4]/100));
      FinalLevel[11] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[4]/100));
      FinalLevel[5] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[5]/100));
      FinalLevel[12] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[5]/100));
      FinalLevel[6] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[6]/100));
      FinalLevel[13] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[6]/100));
      FinalLevel[7] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[7]/100));
      FinalLevel[14] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[7]/100));
      FinalLevel[8] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[8]/100));
      FinalLevel[15] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[8]/100));
	  
	  
	 if Historical then 
		 for i= 1, 8, 1 do
		     Histogram[i][period]=FinalLevel[i];		 
			 if i~= 1 then
			 Histogram[i+7][period]=FinalLevel[i+7];			 
			 end		 
			  if period == source:size()-1 then		   
						 S1,S2 = core.getcandle(TF, source:date(period), day_offset, week_offset);
						 prev_peak= core.findDate (source, S1, false); 
						 if prev_peak~= -1  then
							 core.drawLine(Histogram[i], core.range(prev_peak, period), FinalLevel[i], prev_peak, FinalLevel[i], period, Color[i]);	 
							 if i~= 1 then
							 core.drawLine(Histogram[i+7], core.range(prev_peak, period), FinalLevel[i+7], prev_peak, FinalLevel[i+7], period, Color[i]);
							 end	
						 end
			 
			 end
			 
		 end
	 
	 end
end
