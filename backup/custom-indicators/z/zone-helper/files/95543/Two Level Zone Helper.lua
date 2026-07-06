-- Id: 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61069

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
    indicator:name("Two Level Zone Helper");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 
	
	
    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 0, 0)); 
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addDouble("transparency", "Transparency", "", 50); 
	indicator.parameters:addInteger("ID", "ID", "", 1);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local Color; 
local db; 
local name; 
local init=false; 
local Cell;
local transparency;
local ID;
--local Extend;
function Prepare(nameOnly)
   Color=instance.parameters.Color;
   ID=instance.parameters.ID;
    
    source = instance.source;
    first = source:first(); 

    name = profile:id() .. "(" .. source:name() .. ", "..  ID ..  ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	core.host:execute("addCommand", 1, "Set 1. Zone Point", "");
	core.host:execute("addCommand", 2, "Set 2. Zone Point", ""); 
	core.host:execute("addCommand", 3, "Reset");

	
	require("storagedb");
    db = storagedb.get_db(profile:id() ..   source:name().. ID );	

   instance:ownerDrawn(true);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end

function Draw(stage, context)
    if stage == 2 then
	return;
	end
	
	local AL=db:get ("AL", 0); 
	local BL=db:get ("BL", 0);
	 
	
        if not init then  
		    transparency= context:convertTransparency (instance.parameters.transparency) 
            context:createPen (1, context:convertPenStyle (instance.parameters.style), context:pointsToPixels (instance.parameters.width), Color);
			context:createSolidBrush (2, Color) 	
            init = true;
        end
		
	
	  
		
	
		
		local   y1= Add(context,AL );
	    local   y2=Add(context,BL );
 
		
		if AL== 0 or BL==0 
		then
		return;
		end
		 
		points1= ownerdraw_points.new (); 
		points1:add ( context:left (), y1);
		points1:add ( context:right (),y1);
		points1:add ( context:right() , y2);
	    points1:add ( context:left() , y2);
		

		 
		
		Zone(context,points1);
  
end		
 
function Zone ( context,points)  
context:drawPolygon (-1, 2, points, transparency)
end

function Add(context,L )
    
		 
		 if  L==0 
		 then
		 return nil ; 
		 end
 
		 visible, y1 = context:pointOfPrice (L);
		  
 
	 	context:drawLine (1, context:left (), y1, context:right (), y1 );
		
		return  y1;
end

 
local pattern = "([^;]*);([^;]*)";
function AsyncOperationFinished(cookie, success, message)
 
	
	    local date;
        local level;
      
		 level, date = string.match(message, pattern, pos);
		
          
        if cookie == 1 then
		db:put( "AL", tostring(level)); 
		elseif cookie == 2 then
		db:put( "BL", tostring(level)); 
		elseif cookie == 3 then
		
		db:put( "AL", tostring(0)); 
		db:put( "BL", tostring(0)); 
		end 
			 
end