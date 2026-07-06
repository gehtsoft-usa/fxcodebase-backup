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
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
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
local first;
-- Routine
function Prepare(nameOnly)

    up= instance.parameters.up;
	down= instance.parameters.down;
    source = instance.source;
	first=source:first();
	Start= instance.parameters.Start;
	End= instance.parameters.End;

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
    
    if nameOnly then
		return;
	end



end

-- Indicator calculation routine
function Update(period)

if period < source:size()-1 then
return;
end

core.host:execute ("removeAll");

Draw();
   
end

 
local id=0;

function Draw()

   
    local Firstx = core.findDate (source, Start, false);
	local Lastx = core.findDate (source, End, false);
    
	 
	if Firstx== -1
	or Lastx ==-1
	then
	return; 
	end
 
	id=0;
	
    for i= Firstx , Lastx , 1 do   
	id=id+1;
	core.host:execute("drawLine", id, source:date(first), source.open[i], source:date(source:size()-1),  source.open[i], up, instance.parameters.style, instance.parameters.width,  win32.formatNumber(source.open[i], false, source:getPrecision()));
	id=id+1;
    core.host:execute("drawLine", id, source:date(first), source.close[i], source:date(source:size()-1), source.close[i], down, instance.parameters.style, instance.parameters.width,  win32.formatNumber(source.close[i], false, source:getPrecision()));
	end 
  
        
end


