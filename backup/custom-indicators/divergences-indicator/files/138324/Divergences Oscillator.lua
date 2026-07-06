-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70545

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Divergence Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar); 
    indicator:type(core.Oscillator);
	
 
      indicator.parameters:addGroup("Indicator Selection");	
	indicator.parameters:addString("INDICATOR1", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR1",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number1", "Data Stream Number", "", 1, 1 , 100);
	
	indicator.parameters:addDouble("Cut_Off", "Cut Off (As Percent)", "", 1);
	
 
	
	indicator.parameters:addGroup("Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color_line", "Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addInteger("style_line", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style_line", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width_line", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Label Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
   
   indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
   
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
 
local Last;
local first;
local source = nil;
 
local top1,bottom1;
local Indicator;

local top1,bottom1;
local Top1={};
local Bottom1={};

local top2,bottom2;
local Top2={};
local Bottom2={};
 
local Oscillator;

local Number1;
local INDICATOR1;

local Y, X, Label, Size,ShiftY;
local INDEX;

local Cut_Off, Cut_Off_P, Cut_Off_O;
-- Routine
 function Prepare(nameOnly)   
 

    source = instance.source; 
	
	
    Y=instance.parameters.Y;
	X=instance.parameters.X;   
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;  
    ShiftY=instance.parameters.ShiftY;	
	Cut_Off=instance.parameters.Cut_Off ;
 
	
	
	INDICATOR1=instance.parameters.INDICATOR1;    
   	Number1=instance.parameters.Number1;
	Number1=Number1-1;
	
	local iprofile1 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR1"));
	local iparams1 = instance.parameters:getCustomParameters("INDICATOR1");
	
	if  iprofile1:requiredSource() == core.Tick then			
			Indicator = iprofile1:createInstance( source.close, iparams1);
		else
			Indicator = iprofile1:createInstance(source, iparams1);
		end
    first=math.max(source:first() +6, Indicator.DATA:first() )+50;
	
	INDEX=  Indicator:getStream (Number1);	
	
	local Parameters= instance.parameters:getString("INDICATOR1");
	
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name);



    if   (nameOnly) then
        return;
    end

    Last=nil;
	Top1={};
    Bottom1={};
    Top2={};
    Bottom2={};

	
	top1= instance:addInternalStream(0, 0);
    bottom1= instance:addInternalStream(0, 0);
	
	top2= instance:addInternalStream(0, 0);
    bottom2= instance:addInternalStream(0, 0);
	
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color_line, first );
	Oscillator:setWidth(instance.parameters.width_line);
    Oscillator:setStyle(instance.parameters.style_line);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
 
    
		 instance:ownerDrawn(true); 
	
end



-- Indicator calculation routine
function Update(period, mode)

   Indicator:update(mode);
   
 
  if (period < first) then
  return;
  end
  
  
  
  local min1,max1=mathex.minmax(source,period-50+1, period);
  local min2,max2=mathex.minmax(INDEX,period-50+1, period);
   Cut_Off_P=((max1-min1)/100)*Cut_Off;
   Cut_Off_O=((max2-min2)/100)*Cut_Off;
   
   
  
  Oscillator[period]=INDEX[period];
  
  top1[period - 1]=0;
  bottom1[period - 1]=0;
  
   
  top2[period - 1]=0;
  bottom2[period - 1]=0;
  
        local curr = source.high[period - 1];
        if ( 
            curr > source.high[period - 2] and curr > source.high[period]) then
			
            top1 [period - 1]=1;
      
        end
        curr = source.low[period - 1];
        if ( 
            curr < source.low[period - 2] and curr < source.low[period]) then
           


		      bottom1[period - 1]=1;
        
            
        end
		
		
        local curr = INDEX[period - 1];
        if ( 
            curr > INDEX[period - 2] and curr > INDEX[period]) then
			
            top2 [period - 1]=1;
      
        end
        curr = INDEX[period - 1];
        if ( 
            curr < INDEX[period - 2] and curr < INDEX[period]) then
           


		      bottom2[period - 1]=1;
        
            
        end
		
		
		if period < source:size()-1 then
		return;
		end
		
		
		 if Last== source:size()-1 then
		 return;
		 end
		
		Last= period;		
		FindLast1(period);
		FindLast2(period);			
				  
end

function FindLast1(period)

local TopCount=0;
local BottomCount=0;

Top1={};
Bottom1={};

	for i= period, first, -1 do
	
	
	    if ( TopCount == 0 or TopCount == 2  )and top1[i]== 1 then
		TopCount=TopCount+1;
		Top1[TopCount]=i;
		elseif   TopCount == 1   and bottom1[i]== 1  then
		TopCount=TopCount+1;
		Top1[TopCount]=i;
		end
	 
		
	     if (BottomCount==0 or BottomCount== 2) and bottom1[i]== 1 then
		BottomCount=BottomCount+1;
		Bottom1[BottomCount]=i;
		
		elseif  BottomCount==1  and top1[i]== 1 then
		BottomCount=BottomCount+1;
		Bottom1[BottomCount]=i;
		end
		
 
		
		
		if TopCount >= 3 and BottomCount >= 3 then
		break;	
		end		
		
		
    end

end

function FindLast2(period)

local TopCount=0;
local BottomCount=0;

Top2={};
Bottom2={};

	for i= period, first, -1 do
	
	    if ( TopCount == 0 or TopCount == 2  )and top2[i]== 1 then
		TopCount=TopCount+1;
		Top2[TopCount]=i;
		elseif   TopCount == 1   and bottom2[i]== 1  then
		TopCount=TopCount+1;
		Top2[TopCount]=i;
		end
	 
		
	     if (BottomCount==0 or BottomCount== 2) and bottom2[i]== 1 then
		BottomCount=BottomCount+1;
		Bottom2[BottomCount]=i;
		
		elseif  BottomCount==1  and top2[i]== 1 then
		BottomCount=BottomCount+1;
		Bottom2[BottomCount]=i;
		end
		
		
		
		if TopCount >= 3 and BottomCount >= 3 then
		break;	
		end		
		
		

	end

end

function Draw(stage, context)
    if stage~= 2 then
	 return;
	end
	
	 
	 
	 
	
        if not init then
		
		     context:createPen(1, context:convertPenStyle (core.LINE_SOLID), instance.parameters.width, instance.parameters.color); 
		    context:createPen(2, context:convertPenStyle ( context.DASHDOT ), instance.parameters.width, instance.parameters.color); 
		 
						
            init = true;
        end
		
	  
	local Text1=  "";
	local Text2=  "";
	local Text3=  "";
	local Text4=  "";
	local Text5=  "";
	local Text6=  "";
	local Text7=  "";
	local Text8=  "";
	
	local Text9=  "";
	local Text10=  "";
	local Text11=  "";
	local Text12=  "";
	local Text13=  "";
	local Text14=  "";
	local Text15=  "";
	local Text16=  "";
 
                        x1, x, x = context:positionOfBar (Top1[1]);
					    x2, x, x = context:positionOfBar (Top1[2]);
						x3, x, x = context:positionOfBar (Top1[3]);
						
						visible, y1 = context:pointOfPrice (INDEX[Top1[1]]);
						visible, y2 = context:pointOfPrice (INDEX[Top1[2]]);
						visible, y3 = context:pointOfPrice (INDEX[Top1[3]]);
						
						a, c = math2d.lineEquation (x1, y1, x3, y3);
						y = a * x2 + c;
						
						--if y2> y  then	
						
							context:drawLine (2, x1 , y1, x3 ,y3);
							
							
							if source.high[Top1[1]]< source.high[Top1[3]]
							and INDEX[Top1[1]]> INDEX[Top1[3]]
							then
							
						
								Text1=Text1.. " Bearish ";
									Text1=Text1.. " Hidden divergence ";
							end
							
							
							if source.high[Top1[1]]> source.high[Top1[3]]
							and INDEX[Top1[1]]< INDEX[Top1[3]]
							then
							
						            Text2= Text2.. "Strong"
								    Text2=Text2.. " Bearish ";
									Text2=Text2.. " Divergence ";
							end
							
							
				 --Cut_Off
									
							
							if math.abs (source.high[Top1[1]]- source.high[Top1[3]])< Cut_Off_P
							and INDEX[Top1[1]]< INDEX[Top1[3]]
							then
							
						            Text3= Text3.. "Medium"
								    Text3=Text3.. " Bearish ";
									Text3=Text3.. " Divergence ";
							end
							
							
							 if source.high[Top1[1]]> source.high[Top1[3]]
							and (INDEX[Top1[1]]- INDEX[Top1[3]])< Cut_Off_O
							then
							
						            Text4= Text4.. "Weak"
								    Text4=Text4.. " Bearish ";
									Text4=Text4.. " Divergence ";
							end
						
					--	end
						
					 
 	
						
						
					 
						x1, x, x = context:positionOfBar (Bottom1[1]);
					    x2, x, x = context:positionOfBar (Bottom1[2]);
						x3, x, x = context:positionOfBar (Bottom1[3]);
						
						visible, y1 = context:pointOfPrice (INDEX[Bottom1[1]]);
						visible, y2 = context:pointOfPrice (INDEX[Bottom1[2]]);
						visible, y3 = context:pointOfPrice (INDEX[Bottom1[3]]);
						
						a, c = math2d.lineEquation (x1, y1, x3, y3);
						y = a * x2 + c;
						
						--if y2< y   then						
					
								context:drawLine (2, x1 , y1, x3 ,y3);
								
								if source.low[Bottom1[1]]> source.low[Bottom1[3]]
								and  INDEX[Bottom1[1]]< INDEX[Bottom1[3]]
								then
								
								
							    Text5=Text5.. " Bullish ";
								Text5=Text5.. " Hidden divergence ";
								end
								
								if source.low[Bottom1[1]]< source.low[Bottom1[3]]
								and  INDEX[Bottom1[1]]> INDEX[Bottom1[3]]
								then
								
								Text6= Text6.. "Strong"
							    Text6=Text6.. " Bullish ";
								Text6=Text6.. " Divergence ";
								end
								
								if (source.low[Bottom1[1]]- source.low[Bottom1[3]])< Cut_Off_P
								and  INDEX[Bottom1[1]]> INDEX[Bottom1[3]]
								then
								
								Text7= Text7.. "Strong"
							    Text7=Text7.. " Bullish ";
								Text7=Text7.. " Divergence ";
								end
								
								
								if source.low[Bottom1[1]]< source.low[Bottom1[3]]
								and  (INDEX[Bottom1[1]]- INDEX[Bottom1[3]])< Cut_Off_O
								then
								
								Text8= Text8.. "Strong"
							    Text8=Text8.. " Bullish ";
								Text8=Text8.. " Divergence ";
								end
				     --   end
						
						
--///////////////////////////////////////////////////////////////////////////////////////////

                        x1, x, x = context:positionOfBar (Top2[1]);
					    x2, x, x = context:positionOfBar (Top2[2]);
						x3, x, x = context:positionOfBar (Top2[3]);
						
						visible, y1 = context:pointOfPrice (INDEX[Top2[1]]);
						visible, y2 = context:pointOfPrice (INDEX[Top2[2]]);
						visible, y3 = context:pointOfPrice (INDEX[Top2[3]]);
						
						--a, c = math2d.lineEquation (x1, y1, x3, y3);
						--y = a * x2 + c;
						
						--if y2> y  then	
						
							context:drawLine (1, x1 , y1, x3 ,y3);
							
							
							if source.high[Top2[1]]< source.high[Top2[3]]
							and INDEX[Top2[1]]> INDEX[Top2[3]]
							then
							
						
								Text9=Text9.. " Bearish ";
									Text9=Text9.. " Hidden divergence ";
							end
							
							
							if source.high[Top2[1]]> source.high[Top2[3]]
							and INDEX[Top2[1]]< INDEX[Top2[3]]
							then
							
						            Text10= Text10.. "Strong"
								    Text10=Text10.. " Bearish ";
									Text10=Text10.. " Divergence ";
							end
							
							
								if (source.high[Top2[1]]- source.high[Top2[3]])< Cut_Off_P
							and INDEX[Top2[1]]< INDEX[Top2[3]]
							then
							
						            Text11= Text11.. "Strong"
								    Text11=Text11.. " Bearish ";
									Text11=Text11.. " Divergence ";
							end
							
							
								if source.high[Top2[1]]> source.high[Top2[3]]
							and (INDEX[Top2[1]]- INDEX[Top2[3]])< Cut_Off_O
							then
							
						            Text12= Text12.. "Strong"
								    Text12=Text12.. " Bearish ";
									Text12=Text12.. " Divergence ";
							end
						
					--	end
						
					 
 	
						
						
					 
						x1, x, x = context:positionOfBar (Bottom2[1]);
					    x2, x, x = context:positionOfBar (Bottom2[2]);
						x3, x, x = context:positionOfBar (Bottom2[3]);
						
						visible, y1 = context:pointOfPrice (INDEX[Bottom2[1]]);
						visible, y2 = context:pointOfPrice (INDEX[Bottom2[2]]);
						visible, y3 = context:pointOfPrice (INDEX[Bottom2[3]]);
						
					--	a, c = math2d.lineEquation (x1, y1, x3, y3);
					--	y = a * x2 + c;
						
						--if y2< y   then						
					
								context:drawLine (1, x1 , y1, x3 ,y3);
								
								if source.low[Bottom2[1]]> source.low[Bottom2[3]]
								and  INDEX[Bottom2[1]]< INDEX[Bottom2[3]]
								then
								
								
							    Text13=Text13.. " Bullish ";
								Text13=Text13.. " Hidden divergence ";
								end
								
								if source.low[Bottom2[1]]< source.low[Bottom2[3]]
								and  INDEX[Bottom2[1]]> INDEX[Bottom2[3]]
								then
								
								Text14= Text14.. "Strong"
							    Text14=Text14.. " Bullish ";
								Text14=Text14.. " Divergence ";
								end
								
								
								if ( source.low[Bottom2[1]]- source.low[Bottom2[3]])< Cut_Off_P
								and  INDEX[Bottom2[1]]> INDEX[Bottom2[3]]
								then
								
								Text15= Text15.. "Strong"
							    Text15=Text15.. " Bullish ";
								Text15=Text15.. " Divergence ";
								end
								
								if source.low[Bottom2[1]]< source.low[Bottom2[3]]
								and ( INDEX[Bottom2[1]]- INDEX[Bottom2[3]] )< Cut_Off_O
								then
								
								Text16= Text16.. "Strong"
							    Text16=Text16.. " Bullish ";
								Text16=Text16.. " Divergence ";
								end
				      --  end


--////////////////////////////////////////////////////////////////////////						
						
						
	if Text1== "" and Text2== "" and Text3== "" and Text4== ""  and Text5== "" and Text6== "" and Text7== "" and Text8== "" 
	and  Text9== "" and Text10== "" and Text11== "" and Text12== ""  and Text13== "" and Text14== "" and Text15== "" and Text16== "" 
	then
	Text1= "Divergences are not detected.";
    end
 	
 		
	 
   local i=1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
	local i=2;	 
   width, height = context:measureText (1, Text2, 0);
   context:drawText (1,  Text2, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );		

   local i=3;	 
   width, height = context:measureText (1, Text3, 0);
   context:drawText (1,  Text3, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
	local i=4;	 
   width, height = context:measureText (1, Text4, 0);
   context:drawText (1,  Text4, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	


   local i=5;	 
   width, height = context:measureText (1, Text5, 0);
   context:drawText (1,  Text5, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
	local i=6;	 
   width, height = context:measureText (1, Text6, 0);
   context:drawText (1,  Text6, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	



    local i=7;	 
   width, height = context:measureText (1, Text7, 0);
   context:drawText (1,  Text7, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
	local i=8;	 
   width, height = context:measureText (1, Text8, 0);
   context:drawText (1,  Text8, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	   
   
   
      local i=9;	 
   width, height = context:measureText (1, Text9, 0);
   context:drawText (1,  Text9, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
	local i=10;	 
   width, height = context:measureText (1, Text10, 0);
   context:drawText (1,  Text10, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );		

   local i=11;	 
   width, height = context:measureText (1, Text11, 0);
   context:drawText (1,  Text11, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
	local i=12;	 
   width, height = context:measureText (1, Text12, 0);
   context:drawText (1,  Text12, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	


   local i=13;	 
   width, height = context:measureText (1, Text13, 0);
   context:drawText (1,  Text13, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
	local i=14;	 
   width, height = context:measureText (1, Text14, 0);
   context:drawText (1,  Text14, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	



    local i=15;	 
   width, height = context:measureText (1, Text15, 0);
   context:drawText (1,  Text15, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	
   
	local i=16;	 
   width, height = context:measureText (1, Text16, 0);
   context:drawText (1,  Text16, Label, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0 );	 
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
 