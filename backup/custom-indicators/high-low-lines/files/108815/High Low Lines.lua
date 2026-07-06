-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64028

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
function Init()
    indicator:name("High Low Lines");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDate ("Start", "Start Date", "", 0);
	indicator.parameters:setFlag("Start", core.FLAG_DATETIME);

	indicator.parameters:addDate ("End", "End Date", "", 0)
	indicator.parameters:setFlag("End", core.FLAG_DATETIME);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("up", "Line Color","", core.rgb(0, 255, 0)); 	
	indicator.parameters:addColor("down", "Line Color","", core.rgb(255, 0, 0)); 	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("transparency", "Line Transparency","", 50);  
	
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Start, End;
local source = nil;
-- Streams block
local transparency;
local up,down;
-- Routine
function Prepare(nameOnly)

    up= instance.parameters.up;
	down= instance.parameters.down;
    source = instance.source;
	Start= instance.parameters.Start;
	End= instance.parameters.End;

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
 

	instance:ownerDrawn(true);

end

-- Indicator calculation routine
function Update(period)
   
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 0 then
	return;
	end
	
	
        if not init then
		   context:createPen (1, context:convertPenStyle (instance.parameters.style),  context:pointsToPixels (instance.parameters.width), up);
		   context:createPen (2, context:convertPenStyle (instance.parameters.style),  context:pointsToPixels (instance.parameters.width), down);
           transparency= context:convertTransparency ( instance.parameters.transparency);
            init = true;
        end
  
   
    local Firstx = core.findDate (source, Start, false);
	local Lastx = core.findDate (source, End, false);
    
	
	if Firstx== -1 then
	Firstx=context:firstBar ();
	end

	if Lastx ==-1 then
    Lastx=context:lastBar ();
	end
	
	
    for i=math.max(Firstx,context:firstBar ()), math.min(Lastx,context:lastBar ()), 1 do    
	
	visible, y1 = context:pointOfPrice (source.high[i]);
	visible, y2 = context:pointOfPrice (source.low[i]);
	
	context:drawLine (1, context:left (), y1, context:right (), y1, transparency);
	context:drawLine (2, context:left (), y2, context:right (), y2, transparency);
     
 
	end 
  
        
end


