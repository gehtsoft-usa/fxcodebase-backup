-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=5142
-- Id: 4281

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
    indicator:name("Parallelogram Tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

     indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
    indicator.parameters:addInteger("Size", "Font Size", "", 20);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("Target Line Style");
	indicator.parameters:addColor("Target_Color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Target_Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Target_Style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Target_Style", core.FLAG_LINE_STYLE);	
	  indicator.parameters:addGroup("Target Line Style");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Time;
local first;
local source = nil;


local DateOne, LevelOne=nil;
local DateTwo, LevelTwo=nil;
local DateThree, LevelThree=nil;
local font1, font2;
local Label;
local Size;
local BAR;
local db;
local ID;


-- Routine
function Prepare(nameOnly)
    Hide=instance.parameters.Hide
    Time=instance.parameters.Time;
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    source = instance.source;
    first = source:first();
	
	 local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
	BAR =e-s;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
		require("storagedb");
    db = storagedb.get_db(name);	
   	
	core.host:execute("addCommand", 1005, "New Parallelogram", "");	
	core.host:execute("addCommand", 1001, "First", "");
    core.host:execute("addCommand", 1002, "Second", "");
	 core.host:execute("addCommand", 1003, "Third", "");
    core.host:execute("addCommand", 1004, "Reset", "");		 
	 core.host:execute("addCommand", 1007, "Delete Last", "");
	 core.host:execute ("setTimer", 1006,  1);
	 
    font1 = core.host:execute("createFont", "Ariel", Size, true, false);
	 font2 = core.host:execute("createFont", "Wingdings", Size, true, false);	 
	
	
	 
	 ID = 0;
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)        
end


local pattern = "([^;]*);([^;]*)";

function Parse(message)
    local level, date;
    level, date = string.match(message, pattern, 0);
	
    if level == nil or date == nil then
        return 0, 0;
    end
	
    return tonumber(date),tonumber(level) ;
end



function Parallel (x,y,  x1 , y1 )

local a = x;
local b = y1-a*x1;

return a, b;

end

function getline(x1, y1, x2, y2)
    local a, b;

    a = ((y2 - y1) / (x2 - x1));
    b = (y1 - a * x1);
    return a, b;
end

-- get line intersection point
function intersect(a1, b1, a2, b2)
    local x, y;

    -- collinear
    if a1 == a2 then
        return nil, nil;
    end

    x = (b2 - b1) / (a1 - a2);
    y = a1 * x + b1;
    return x, y;
end


function AsyncOperationFinished(cookie, success, message)

   local ID;


    if cookie == 1001 then
	
         DateOne, LevelOne  = Parse(message);
		 
		  ID=tonumber(db:get (tostring("ID"), 0));
	
	     if LevelOne~= 0 then 
		        db:put(tostring(ID).."LevelOne", tostring(LevelOne));			  
			   db:put(tostring(ID).."DateOne", tostring(DateOne));		             
    	 end
    

    elseif cookie == 1007 then
	
	 ID=tonumber(db:get (tostring("ID"), 0));
	 
	 		
			
			 core.host:execute ("removeLabel", ID);
			  core.host:execute ("removeLabel", ID+1000);
			  core.host:execute ("removeLabel", ID+2000);
			  core.host:execute ("removeLabel", ID+3000);
			  
			   core.host:execute ("removeAll");	
			  
		 LevelOne= 0;
        LevelTwo= 0;
		LevelThree= 0;	  
			 
	 	 
	 ID = ID -1;
	 
	  if ID < 0 then
	 ID = 0;
	 end	
	 
	   db:put(tostring("ID"), tostring(ID));
	
	elseif cookie == 1002 then
      
        DateTwo, LevelTwo  = Parse(message); 	
		
		  ID=tonumber(db:get (tostring("ID"), 0));
	
	     if  LevelTwo~= 0  then 
		                      
                 db:put(tostring(ID).."LevelTwo", tostring(LevelTwo));			  
			   db:put(tostring(ID).."DateTwo", tostring(DateTwo));	 			  
    	 end
		 
	 	
	 elseif cookie == 1003 then
      
        DateThree, LevelThree  = Parse(message);  
		
		 ID=tonumber(db:get (tostring("ID"), 0));
	
	     if  LevelThree~= 0 then 
		       
			   db:put(tostring(ID).."LevelThree", tostring(LevelThree));			  
			   db:put(tostring(ID).."DateThree", tostring(DateThree));	 			  
    	 end
		 	
	 elseif cookie == 1005 then	
	 
	  ID=tonumber(db:get (tostring("ID"), 0));
	  ID=ID+1;
	  db:put(tostring("ID"), tostring(ID));
	  
	    LevelOne= 0;
        LevelTwo= 0;
		LevelThree= 0;
	  
	
     	 	
	elseif cookie == 1004 then
	
	
      
        core.host:execute ("removeAll");	
		
		    ID=tonumber(db:get (tostring("ID"), 0));
			
			
			local i;
			for i = 0, ID+1, 1 do
			db:put(tostring(i).."LevelOne", tostring(0));			
			db:put(tostring(i).."DateOne", tostring(0)); 
			
			db:put(tostring(i).."LevelTwo", tostring(0));
			db:put(tostring(i).."DateTwo", tostring(0)); 
			
			db:put(tostring(i).."LevelThree", tostring(0));
			db:put(tostring(i).."DateThree", tostring(0)); 
			
					
			 end
			 
			 ID=0;
			 id=0;
         
			 
             db:put(tostring("ID"), tostring(0));
			  
		LevelOne= 0;
        LevelTwo= 0;
		LevelThree= 0;
		
	elseif cookie == 1006  then
   DRAW();	 	
		
	end		
	
	
    
		  
	
	
	
end

function DRAW()
	local i;
		      local DATA={};	   	  

		   
		    	ID=tonumber(db:get (tostring("ID"), 0));

				   
			   for i= 0 , ID+1 , 1 do
			   DATA[i] ={};
						   
			   
			   DATA[i]["LevelOne"]= tonumber(db:get (tostring(i).."LevelOne", 0));		  
			   DATA[i]["DateOne"]=tonumber(db:get (tostring(i).."DateOne", 0));
			   
				DATA[i]["LevelTwo"]=tonumber(db:get (tostring(i).."LevelTwo", 0));		   
			   DATA[i]["DateTwo"]=tonumber(db:get (tostring(i).."DateTwo", 0));
			   
				DATA[i]["LevelThree"]=tonumber(db:get (tostring(i).."LevelThree", 0));		  
			   DATA[i]["DateThree"]=tonumber(db:get (tostring(i).."DateThree", 0));
			   
			   
			   if DATA[i]["LevelOne"] ~= 0 then
		        core.host:execute("drawLabel1",ID+6000, DATA[i]["DateOne"], core.CR_CHART, DATA[i]["LevelOne"], core.CR_CHART, core.H_Center, core.V_Top,
								 font2, instance.parameters.color, "\129");
				  end
				  
				 if DATA[i]["LevelTwo"] ~= 0 then
				  core.host:execute("drawLabel1", ID+7000, DATA[i]["DateTwo"], core.CR_CHART, DATA[i]["LevelTwo"], core.CR_CHART, core.H_Center, core.V_Top,
								 font2, instance.parameters.color, "\130");
				 end
				  
				  
				 if  DATA[i]["LevelThree"] ~= 0 then
				  core.host:execute("drawLabel1", ID+8000, DATA[i]["DateThree"], core.CR_CHART, DATA[i]["LevelThree"], core.CR_CHART, core.H_Center, core.V_Top,
								 font2, instance.parameters.color, "\131");
				 end				 
				
				if DATA[i]["LevelThree"] ~= 0  and DATA[i]["LevelTwo"] ~= 0  and DATA[i]["LevelOne"] ~= 0  then
					
				core.host:execute("drawLine", ID, DATA[i]["DateOne"], DATA[i]["LevelOne"], DATA[i]["DateTwo"], DATA[i]["LevelTwo"],
								  instance.parameters.color, instance.parameters.style, instance.parameters.width);
						
				core.host:execute("drawLine", ID+1000, DATA[i]["DateOne"], DATA[i]["LevelOne"], DATA[i]["DateThree"], DATA[i]["LevelThree"],
								  instance.parameters.color, instance.parameters.style, instance.parameters.width);	
				

				
				
				 local x1, y1, x2, y2, x3, y3, x4, y4;
			x1= DATA [i]["LevelOne"];			
			if DATA[i] ["DateOne"]  <= source:date(source:size()-1) then
			y1=core.findDate (source, DATA [i]["DateOne"] , false);
			else
			y1= source:size()-1 + ( DATA [i]["DateOne"]  -source:date(source:size()-1) ) /BAR;
			end
			
		
			x2= DATA[i] ["LevelTwo"] ; 		
			if DATA [i]["DateTwo"]  <= source:date(source:size()-1) then
			y2=core.findDate (source, DATA[i] ["DateTwo"] , false);
			else
			y2= source:size()-1 + ( DATA[i] ["DateTwo"]  -source:date(source:size()-1) ) /BAR;
			end
			
			
			
			x3= DATA[i] ["LevelThree"] ;
			if DATA [i]["DateThree"]  <= source:date(source:size()-1) then
			y3=core.findDate (source, DATA[i] ["DateThree"] , false);
			else
			y3= source:size()-1 + ( DATA [i]["DateThree"]  -source:date(source:size()-1) ) /BAR;
			end
			
			 
		     local a1, b1 ;
			 local a2, b2 ;
			 local ia1, ib1 ;
			 local ia2, ib2 ;
 
			 ia1, ib1 =  getline(x1, y1,x2, y2)
			 ia2, ib2  = getline(x1, y1,x3, y3)
			 
				a1, b1  = Parallel ( ia1, ib1 , x3, y3)
				a2, b2  = Parallel (ia2, ib2 , x2, y2)
				
				x4 ,y4  = intersect(a1, b1, a2, b2) ;
				
				if  x4== nil then
				return;
				end
				 DATA[i]["LevelFour"] = x4;

                 if  y4	 <= source:size()-1 then
				 DATA [i]["DateFour"] = source:date(y4) ;
				 else
				 DATA [i]["DateFour"] = source:date(source:size()-1) +(y4-source:size()-1 )*BAR ;
				 end
				
								  
				core.host:execute("drawLine", ID+2000, DATA[i]["DateThree"], DATA[i]["LevelThree"], DATA[i]["DateFour"], DATA[i]["LevelFour"],
								  instance.parameters.color, instance.parameters.style, instance.parameters.width);
						
				core.host:execute("drawLine", ID+3000, DATA[i]["DateTwo"], DATA[i]["LevelTwo"], DATA[i]["DateFour"], DATA[i]["LevelFour"],
								  instance.parameters.color, instance.parameters.style, instance.parameters.width);		

						  
			 			  
                 core.host:execute("drawLine", ID+4000, DATA[i]["DateFour"], DATA[i]["LevelFour"], source:date(source:size()-1), DATA[i]["LevelFour"],
								  instance.parameters.Target_Color, instance.parameters.Target_Style, instance.parameters.Target_Width);	
								  
				  core.host:execute("drawLabel1", ID+5000,  DATA[i]["DateFour"], core.CR_CHART,DATA [i]["LevelFour"], core.CR_CHART, core.H_Right, core.V_Bottom,
                             font1, instance.parameters.color, string.format("%." .. 5 .. "f",  DATA[i]["LevelFour"]));				  
                 
				
				  
								 
				   core.host:execute("drawLabel1", ID+9000, DATA[i]["DateFour"], core.CR_CHART, DATA[i]["LevelFour"], core.CR_CHART, core.H_Center, core.V_Top,
                  font2, instance.parameters.color, "\132");				 
				
				 
				 end  								  
								
					  
		   
		   
	      end 
end


function ReleaseInstance()
        core.host:execute("deleteFont", font1);    
       core.host:execute("deleteFont", font2);    
     
 end