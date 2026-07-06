-- More information about this indicator can be found at:
-- http://fxcodebase.com/ 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Active Support and resistances");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
 	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("Zone", "Zone (in Pips)", "", 5);
 
 	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Top", "Support Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "Resistances Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
    local Zone;	 
	local first;
	local source = nil; 
    local Top,Bottom; 
    local TopEnd,BottomEnd; 
    local Loading=true;
 
function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 

    source = instance.source;

    if   (nameOnly) then
        return;
    end
   
    Zone=instance.parameters.Zone; 
	
    Top = instance:addInternalStream(0, 0);	
    Bottom = instance:addInternalStream(0, 0);	 
    TopEnd = instance:addInternalStream(0, 0);	
    BottomEnd = instance:addInternalStream(0, 0);	
     
    Loading=true;
	 core.host:execute ("setTimer", 1, 5);
 
    instance:setLabelColor(instance.parameters.Top);
    instance:ownerDrawn(true);  
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


  if cookie == 1 then
    Loading=true;
	 
    for i= 1, source:size()-1, 1 do
	
		if Top[i]== 1 then
		TopEnd[i]=FindTheTop(i);
		end
		
		if Bottom[i]== 1 then
		BottomEnd[i]=FindTheBottom(i);		
		end	
		
		
	end
	
	 Loading=false;
 
  end
  
    return core.ASYNC_REDRAW ;
end

function FindTheTop(period)

local Return=0;

    for i= period+1, source:size()-1, 1 do
	
	  if Top[i]== 1 
	  and source.high[i]<= source.high[period] + Zone*source:pipSize()
	  and source.high[i]>= source.high[period] - Zone*source:pipSize()
	  then
	  Return =i;
	  break;
	  end
	 
	end
	
return Return;
end

function FindTheBottom(period)

local Return=0;

    for i= period+1, source:size()-1, 1 do
      if Bottom[i]== 1 
	  and source.low[i]<= source.low[period] + Zone*source:pipSize()
	  and source.low[i]>= source.low[period] - Zone*source:pipSize()
	  then
	  Return =i;
	  break;	  
	  end
    end   

return Return;
end
 
local Last=0;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

  if period < 6 then
  return;
  end
  
  if Last~= source:size()-1  then
  Last= source:size()-1;
  Loading=true;
  end
 
    Top[period]=-1; 
    Bottom[period]=-1;  
    TopEnd[period]=-1; 
    BottomEnd[period]=-1; 	
	
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then
        Top[period - 2]=1;
        TopEnd[period - 2]=-1;		
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then         
        Bottom[period - 2]=1; 
        BottomEnd[period - 2]=-1; 		
        end

  
end


local init = false;

function Draw (stage, context)

    if stage  ~= 0 
    or Loading   	
	then
	return;
	end
	 
   
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context:convertPenStyle (instance.parameters.style), context:pixelsToPoints (instance.parameters.width), instance.parameters.Top)     
			 context:createPen (2, context:convertPenStyle (instance.parameters.style), context:pixelsToPoints (instance.parameters.width), instance.parameters.Bottom)     
		 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
     
			    for i= first, last, 1 do	 

			   
			    
				 if Top[i]== 1 and TopEnd[i]>=0 then
			     x1, x, x = context:positionOfBar (i);
			     x2, x, x = context:positionOfBar (source:size()-1);
				 
				 
				 				 if TopEnd[i]~= 0 then	
								 x2, x, x = context:positionOfBar (TopEnd[i]);				 
								 end	
								 visible, y = context:pointOfPrice (source.high[i]); 
				 				 context:drawLine (1, x1, y, x2, y);
					 			 
                 end				 
				   
			 
				 

			    
				 if Bottom[i]== 1 and BottomEnd[i]>=0 then
			     x1, x, x = context:positionOfBar (i);
			     x2, x, x = context:positionOfBar (source:size()-1);	

								 if BottomEnd[i]~= 0 then	
								 x2, x, x = context:positionOfBar (BottomEnd[i]);				 
								 end	
								 visible, y = context:pointOfPrice (source.low[i]); 								 
				 				 context:drawLine (2, x1, y, x2, y);						 
                 end		 		 
				 
	
			 
			 end
			 
 
	   
	 
end


