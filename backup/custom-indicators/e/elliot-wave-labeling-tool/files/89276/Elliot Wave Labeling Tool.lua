

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4360#p12563

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Elliot Wave Labeling Tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
     indicator.parameters:addInteger("Size", "Size of Labels", "", 15); 
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local Size;
local counter=0;
local LAST;
local END;
local Label;
local font;


-- Streams block

local Labels={"1", "2", "3", "4", "5"};
local Labels2= { "A", "B", "C"};

local db; 
local name;
-- Routine

local ID=0;

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
   Label=instance.parameters.Label;
   Size=instance.parameters.Size;
    source = instance.source;
    first = source:first();

     
	
	require("storagedb");
    db = storagedb.get_db(name);	
	
	 font = core.host:execute("createFont", "Arial", Size, true, false);
	
	core.host:execute("addCommand", 1, "Add  Impulse Wave", "");
	core.host:execute("addCommand", 4, "Add  Correction Wave"  , "");
	core.host:execute("addCommand", 2, "Delete Last", "");
	core.host:execute("addCommand", 3, "Reset");
	
	 core.host:execute ("setTimer", 1006,  1);
	
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end

-- This method will be called when the command is executed (e.g. when the user clicks the corresponding menu command in the MarketScope).
-- Parameters:
-- cookie - the command identifier previously specified in core.host:execute("addCommand", ..
-- success - always true
-- message - information about the point to which the user clicked to view the menu. The format is: "{rate};{OLE date}"
local pattern = "([^;]*);([^;]*)";
function AsyncOperationFinished(cookie, success, message)
    -- check that this is our "Show marker" command
	
	    local date;
        local level;
        local pos;
		local p;
		
		
	if cookie == 1006 then
	
	 local i;
	   local DATA={};	   	  
	   local INDEX;
	   
	    INDEX=tonumber(db:get (tostring("INDEX"), 0));

		--if INDEX== 0 then
		--return;
		--end
		ID = INDEX;
	   
	   
		   for i= 1 , INDEX , 1 do
		   
		   DATA["Level"]=db:get (tostring(i).."Level", 0);
		   DATA["Sign"]=db:get (tostring(i).."Sign", 0);
		   DATA["Date"]=tonumber(db:get (tostring(i).."Date", 0));
		   
		   
				   if DATA["Level"]~= 0 and DATA["Sign"]~= 0 and DATA["Date"] ~= 0  then
				   
				         core.host:execute("drawLabel1", i, DATA["Date"], core.CR_CHART,tonumber(DATA["Level"]), core.CR_CHART, core.H_Center, core.V_Center,
                             font, Label,tostring(DATA["Sign"]));
				   else
				         core.host:execute ("removeLabel", i);
				   end
		  
		  end 
	
    end	
	
    if cookie == 1 then
	
	counter= counter+1;
	ID=ID+1;
	
	db:put(tostring("INDEX"), tostring(ID));  
	
        -- retrieve the coordinates of the point to which the user clicked
    
         level, date = string.match(message, pattern, pos);
		  p= core.findDate (source, date, true);
		 
		      db:put(tostring(ID).."Level", tostring(level));
			  db:put(tostring(ID).."Sign", tostring(Labels[counter]));
			   db:put(tostring(ID).."Date", tostring(source:date(p)));
			  
			  db:put(tostring("Last"), tostring(ID));
			  db:put(tostring("Count"), tostring(counter));
		 
		 LAST =p;
		 
		   if counter == 5 then
			counter=0;
			end
	 
    elseif cookie == 4 then
	
	counter= counter+1;
	
	  ID=ID+1;
	  
	  db:put(tostring("INDEX"), tostring(ID));  
        -- retrieve the coordinates of the point to which the user clicked
    
         level, date = string.match(message, pattern, pos);
		  p= core.findDate (source, date, true);
		  
		   LAST =p;
		 
		      db:put(tostring(ID).."Level", tostring(level));
			  db:put(tostring(ID).."Sign", tostring(Labels2[counter]));
			   db:put(tostring(ID).."Date", tostring(source:date(p)));
			  
			   db:put(tostring("Last"), tostring(ID));
			   db:put(tostring("Count"), tostring(counter));
		
		    if counter == 3 then
			counter=0;
			end
	 
   elseif cookie == 2 then        
	
	
	local  Last  =db:get (tostring("Last"), 0);
	local Count  =db:get (tostring("Count"), 0);			
	
	counter = tonumber(Count);
	  
	 counter= counter-1;
	 ID=ID-1;
	 
	 local TEMP;
	 TEMP = tonumber(Last);
	 TEMP=TEMP-1;
	 
	  db:put(tostring("Last"), tostring(TEMP));
	
	   core.host:execute ("removeLabel", tonumber(Last));
	  db:put(tostring(Last).."Level", tostring(0));
	 db:put(tostring(Last).."Sign", tostring(0));
	 
	 db:put(tostring("Count"), tostring(counter));
	 
	 
      if   counter < 0 then
     counter=0;
	  end
	  
	   if   ID < 0 then
      ID=0;
	  end
	  
	  db:put(tostring("INDEX"), tostring(ID));  
	 
    elseif cookie == 3 then    

    --local ID=tonumber(db:get (tostring("INDEX"), 0));
	
	local i;
	for i = 1, ID, 1 do
	db:put(tostring(i).."Level", tostring(0));
	db:put(tostring(i).."Sign", tostring(0)); 
     core.host:execute ("removeLabel", i);
	
	 end
	 
	 ID=0;
	 	 
	  db:put(tostring("Count"), tostring(0));
	  db:put(tostring("Last"), tostring(0));
	  
	 counter=0 ;

	  db:put(tostring("INDEX"), tostring(ID));  
   
    end
	
end