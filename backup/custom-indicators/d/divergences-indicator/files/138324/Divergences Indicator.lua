-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70545

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
    indicator:type(core.Indicator);
	
   indicator.parameters:addGroup("Indicator Selection");	
	indicator.parameters:addString("INDICATOR1", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR1",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number1", "Data Stream Number", "", 1, 1 , 100);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
 
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Last;
local first;
local source = nil;
 
local top1,bottom1;
local Top1={};
local Bottom1={};

local top2,bottom2;
local Top2={};
local Bottom2={};

local Number1;
local INDICATOR1;

-- Routine
 function Prepare(nameOnly)   
 
	   source = instance.source; 
	
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
    first=math.max(source:first() +6, Indicator.DATA:first());
	
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
 
 
		 instance:ownerDrawn(true); 
	
end



-- Indicator calculation routine
function Update(period, mode)

  
   Indicator:update(mode);
   
   
  if (period < first) then
  return;
  end
  
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
           


		      bottom1 [period - 1]=1;
        
            
        end
		
		
				---2
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
		
	  
	  
		 
                        x1, x, x = context:positionOfBar (Top1[1]);
					    x2, x, x = context:positionOfBar (Top1[2]);
						x3, x, x = context:positionOfBar (Top1[3]);
						
						visible, y1 = context:pointOfPrice (source.high[Top1[1]]);
						visible, y2 = context:pointOfPrice (source.high[Top1[2]]);
						visible, y3 = context:pointOfPrice (source.high[Top1[3]]);
						
						a, c = math2d.lineEquation (x1, y1, x3, y3);
						y = a * x2 + c;
						
					--	if y3> y  then						
						context:drawLine (1, x1 , y1, x3 ,y3);
					--	end
						
					 
					
   
					
						
						
					 
						x1, x, x = context:positionOfBar (Bottom1[1]);
					    x2, x, x = context:positionOfBar (Bottom1[2]);
						x3, x, x = context:positionOfBar (Bottom1[3]);
						
						visible, y1 = context:pointOfPrice (source.low[Bottom1[1]]);
						visible, y2 = context:pointOfPrice (source.low[Bottom1[2]]);
						visible, y3 = context:pointOfPrice (source.low[Bottom1[3]]);
						
						a, c = math2d.lineEquation (x1, y1, x3, y3);
						y = a * x2 + c;
						
					--	if y3< y   then	
						context:drawLine (1, x1 , y1, x3 ,y3);
				     --   end
						
						
						--///////////////////////////////////////////////////////////////////
						
						
						    x1, x, x = context:positionOfBar (Top2[1]);
					    x2, x, x = context:positionOfBar (Top2[2]);
						x3, x, x = context:positionOfBar (Top2[3]);
						
						visible, y1 = context:pointOfPrice (source.high[Top2[1]]);
						visible, y2 = context:pointOfPrice (source.high[Top2[2]]);
						visible, y3 = context:pointOfPrice (source.high[Top2[3]]);
						
						a, c = math2d.lineEquation (x1, y1, x3, y3);
						y = a * x2 + c;
						
						--if y3> y  then						
						context:drawLine (2, x1 , y1, x3 ,y3);
						--end
						
					 
					
   
					
						
						
					 
						x1, x, x = context:positionOfBar (Bottom2[1]);
					    x2, x, x = context:positionOfBar (Bottom2[2]);
						x3, x, x = context:positionOfBar (Bottom2[3]);
						
						visible, y1 = context:pointOfPrice (source.low[Bottom2[1]]);
						visible, y2 = context:pointOfPrice (source.low[Bottom2[2]]);
						visible, y3 = context:pointOfPrice (source.low[Bottom2[3]]);
						
						a, c = math2d.lineEquation (x1, y1, x3, y3);
						y = a * x2 + c;
						
					--	if y3< y   then	
						context:drawLine (2, x1 , y1, x3 ,y3);
				    --   end
			 
end	
 