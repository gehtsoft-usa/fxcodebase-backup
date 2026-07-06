
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65034

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
    indicator:name("Candle number");
    indicator:description("Candle number");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Label", "Label Color", "Label Color", core.COLOR_LABEL );
    indicator.parameters:addInteger("Size", "Font Size", "Size", 10 );
    indicator.parameters:addString("Font", "Font", "Font", 	"Arial" );

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local db;
local Label;
local Size;
local Font;
-- Streams block
local pattern = "([^;]*);([^;]*)";

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Label=instance.parameters.Label;
	Size=instance.parameters.Size;
	Font=instance.parameters.Font;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
	require("storagedb");
    db = storagedb.get_db(name);	
	
	core.host:execute("addCommand", 1, "Start");
	core.host:execute("addCommand", 2, "End");
    core.host:execute("addCommand", 3, "Reset");
	
	instance:ownerDrawn(true);

end


function AsyncOperationFinished(cookie, success, message)
    
    Level, Date = string.match(message, pattern, 0);
	
	if cookie == 1 then
	db:put("Start", tostring(Date));  	
	elseif cookie == 2 then
	db:put("End", tostring(Date));   
	elseif cookie == 3 then
	db:put("Start", tostring(0));   	
    db:put("End", tostring(0));   
	     
	end
	
end
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
end


local init= false;

function Draw(stage, context)
    if stage ~= 2 then
        return ;
    end
	
	if not init then 
  
    context:createFont (1, Font, context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
    init= true; 
	end
	
	local Start = tonumber(db:get("Start", 0));  
    local End = tonumber(db:get("End", 0));  
	
	
	if Start ==0  then
	return;
	end
	
	
	local X1=-1;

	
	

	X1= core.findDate (source, Start, false);	
	X2= core.findDate (source, End, false);
	
		if X1 ==-1 	then
		return;
		end
		
		local Last;
		
		
		if  End < Start and End ~= 0  then
		return;
		end
		
		
		if X2==-1 or End ==0   then
		Last=context:lastBar ();
		else
		Last=X2;
		end
		
		
		for p= X1, Last, 1 do 
		 Add(context, p, X1) 
		end
   
end

function Add(context, p, Start) 

  Test=(p-Start)+1;
  
  
  
  width, height = context:measureText (1, Test, 0);
  
   x, x1, x2 = context:positionOfBar (p);   
   visible, y =context:pointOfPrice (source.high[p]);
  context:drawText (1, Test, Label, -1, x- width/2, y-height, x+ width/2, y, context.CENTER +context.TOP , 0);

  
end
