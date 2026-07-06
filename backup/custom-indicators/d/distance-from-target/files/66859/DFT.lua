-- Id: 9277
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=40833

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Distance from Target");
    indicator:description("Distance from Target");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addString("Method", "Method", "Method" , "Pip");
    indicator.parameters:addStringAlternative("Method", "Pip", "Pip" , "Pip");
    indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");

     indicator.parameters:addInteger("Size", "Font Size", "", 20); 
    indicator.parameters:addColor("Color", "Line Color ", " ", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;

local first;
local source = nil;

-- Streams block
local Color = nil;
local db;
local font;
local Size;
-- Routine
function Prepare(nameOnly)
    Color = instance.parameters.Color;
	Size = instance.parameters.Size;
	Method = instance.parameters.Method;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Method  .. ")";
    instance:name(name);

    if nameOnly then
        return;
    end
    core.host:execute("addCommand", 1 , "Select Level",  "Select Level");
    core.host:execute("addCommand", 2 , "Reset",  "Reset");
		require("storagedb");
    db = storagedb.get_db(name);
	
	core.host:execute ("setTimer", 3, 1);
	
	 font = core.host:execute("createFont", "Ariel", Size, true, false);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  
end

function AsyncOperationFinished(cookie, success, message)
       if cookie == 1 then
           local t, c;
           t, c = core.parseCsv(message, ";");
		   
		        db:put(  "Level", tostring(t[0]));			  
			 	             
       elseif cookie == 2 then   
	    db:put(  "Level", tostring(0));	
		core.host:execute ("removeAll")
       end
	   
	   local Level;	    
	   Level=tonumber(db:get (tostring("Level"), 0));
	   
	   
	  if Level ~= 0 then
	   core.host:execute("drawLine", 1, source:date(first), Level, source:date(source:size()-1), Level,  Color);
	   
	   core.host:execute("drawLabel1", 2, -100, core.CR_RIGHT,   100, core.CR_TOP, core.H_Center, core.V_Bottom,
                             font , Color, "Target : " ..   string.format("%." .. 5 .. "f", Level) );
							 
		local Distance;
		 
	   if Method == "Pip" then
	   Distance= (source[source:size()-1]-Level)/ source:pipSize();
	   else
	   Distance= source[source:size()-1]-Level;
	   end
		
 		
		core.host:execute("drawLabel1", 3, -100, core.CR_RIGHT,   100+Size*2, core.CR_TOP, core.H_Center, core.V_Bottom,
                             font , Color, "Distance : " ..  string.format("%." .. 5 .. "f", Distance)    );					 

	  end
	  
 end
 
function ReleaseInstance()
core.host:execute("deleteFont", font);      
core.host:execute ("killTimer", 1)
end

