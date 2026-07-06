-- Id: 21794
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66423


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
    indicator:name("ABCD Price Target");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
     indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addInteger("Indicator_ID", "Indicator D", "", 1);
 
    indicator.parameters:addString("Method", "Calculation Method", "Method" , "A");
    indicator.parameters:addStringAlternative("Method", "D=C+(B-A)", "D=C+(B-A)" , "A");
    indicator.parameters:addStringAlternative("Method", "D=B+(B-C)", "D=B+(B-C)" , "B");
    indicator.parameters:addStringAlternative("Method", "D=B+(B-A)", "D=B+(B-A)" , "C");
    indicator.parameters:addStringAlternative("Method", "D=C+(C-A)", "D=C+(C-A)" , "D");
	
 
	
	
	indicator.parameters:addGroup("Style");
  	indicator.parameters:addInteger("Size", "Font Size", "", 10); 
	indicator.parameters:addColor("Line", "Line Color", "",  core.COLOR_LABEL );
	indicator.parameters:addColor("Cycle", "Cycle Color", "", core.COLOR_LABEL );
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
 
local db; 
local pattern = "([^;]*);([^;]*)";
local Indicator_ID;
local Size;
local AD,BD,CD;
local AL, BL, CL;
local Method;
-- Routine
function Prepare(nameOnly)
  
    source = instance.source;
    first = source:first();
	
	
	
	local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	Indicator_ID= instance.parameters.Indicator_ID;
	Size= instance.parameters.Size;
	Method= instance.parameters.Method;
	 
 
    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name); 
	
	
    instance:ownerDrawn(true);
  	
	require("storagedb");
    db = storagedb.get_db(Indicator_ID .. name);	
	
    core.host:execute("addCommand", 1, "A Point");
	core.host:execute("addCommand", 2, "B Point");
	core.host:execute("addCommand", 3, "C Point"); 
    core.host:execute("addCommand", 4, "Reset");
	
	core.host:execute("setTimer", 10, 1);
	

end

function ReleaseInstance()
core.host:execute ("killTimer", 10);
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
	
	
	
	if not init then 
	 context:createPen (1, context:convertPenStyle(instance.parameters.style), instance.parameters.width,  instance.parameters.Line); 
	 context:createFont(2, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), context.NORMAL); 
	 context:createFont(3, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), context.NORMAL); 
 
	init = true;
	end
	
	   width, height = context:measureText (3, "\108", context.CENTER);
     
		
        if AD~=0 and AD~=nil then
		xA, x = context:positionOfDate (AD);
		visible, yA = context:pointOfPrice (AL);
		context:drawText (3,  "\108", instance.parameters.Cycle, -1, xA-width/2, yA-height/2, xA+width/2, yA+height/2, context.CENTER);
	    end
		
		
		if BD~=0 and BD~=nil  then
		xB, x = context:positionOfDate (BD);
		visible, yB =  context:pointOfPrice (BL);
		
		context:drawText (3,  "\108", instance.parameters.Cycle, -1, xB-width/2, yB-height/2, xB+width/2, yB+height/2, context.CENTER);
	    end
		
		
		if CD~=0 and CD~=nil  then
		xC, x = context:positionOfDate (CD);
		visible, yC = context:pointOfPrice (CL);
		context:drawText (3,  "\108", instance.parameters.Cycle, -1, xC-width/2, yC-height/2, xC+width/2, yC+height/2, context.CENTER);
	    end

		
		 if AD==0 or BD==0 or CD==0 or AD==nil or BD==nil  or CD==nil then
		 return;
		 end
		 
		 
		 
        
			
			if  AD< BD then
			context:drawLine (1, xA, yA, xB, yB );
			else	
            core.host:execute ("setStatus", "B. should be preceded by A.")			
			end
			 
			if BD< CD then
			 context:drawLine (1, xB, yB, xC, yC );
			 else
			 core.host:execute ("setStatus", "C. should be preceded by D.")			
			end
			 
			 if  AL> BL  and  CL< BL then	 	
            core.host:execute ("setStatus", "C. should be below B.")			
			end
			 if  AL< BL  and  CL> BL then	 	
            core.host:execute ("setStatus", "C. should be above B.")			
			end 
			 
		  
		  local xD=0;
		  local yD=0;
		  
	 
  
  
	local Target;     
  		  
		  xT=  xC+(xB-xA) ;       
		  yT=yC-(yA-yB);
		  
		  --"D=C+(B-A)"	
		  if Method== "A" then
		  Target = yT;
		  end
		  --"D=B+(B-C)"	  
		  if Method== "B" then
		  Target = yB-(yC-yB);
		  end
		  
		  --"D=B+(B-A)"  
		  if Method== "C" then
		  Target = yB-(yA-yB);
		  end 
		  
		   --"D=C+(C-A)"		   
		  if Method== "D" then
		  Target = yC-(yA-yC);
		  end
		  		  
          xD, yD = math2d.lineIntersection (xC, yC, xT, yT, context:left(), Target, context:right(), Target);
         

		  
	
		 
		 
		 if yD~= 0 then
		 context:drawLine (1, xC, yC, xD, yD);
		 context:drawText (3,  "\108", instance.parameters.Cycle, -1, xD-width/2, yD-height/2, xD+width/2, yD+height/2, context.CENTER);
		 end 
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 


		
		
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie, success, message)
  
       
	    if cookie== 1 or cookie == 2 or cookie == 3 then
	    level, date = string.match(message, pattern, 0);
		  
			if cookie == 1 then
			db:put( "AL", tostring(level));
			db:put("AD", tostring(date));
			elseif cookie == 2 then
		    db:put( "BL", tostring(level));
			db:put("BD", tostring(date));
			elseif cookie == 3 then
			db:put( "CL", tostring(level));
			db:put("CD", tostring(date));
			elseif cookie == 4 then
			db:put("AD", tostring(0));
			db:put("BD", tostring(0));
			db:put("CD", tostring(0)); 
			end
		
		end
		
		if cookie == 10 then
		AD=tonumber(db:get( "AD", 0));
		AL=tonumber(db:get( "AL", 0)); 
		
		BD=tonumber(db:get( "BD", 0));
		BL=tonumber(db:get( "BL", 0)); 
		
		
		CD=tonumber(db:get( "CD", 0));
		CL=tonumber(db:get( "CL", 0)); 
		
		
		
		end
		
		
end


