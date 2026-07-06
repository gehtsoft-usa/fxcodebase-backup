
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63455

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




function Init()
    indicator:name("Alternative ZigZag");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Delta", "Delta", "", 100);
    indicator.parameters:addBoolean("Extend", "Trend Continuation", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end

local Previous
local Current;
local Trend;
local first;
local Delta;
local first;
local source;
local Up, Down;
local Extend;
function Prepare(onlyName)
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Extend=instance.parameters.Extend;
    Delta=instance.parameters.Delta;
	source = instance.source; 
	first=source:first();
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. Delta .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end 

    out = instance:addStream("out", core.Line, name, "out", Up, first);
    out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);

    Previous=nil;
	Current=nil;
end

function Update(period)
  
  
    period= period-1;
	
    if period < first then
	return;
	end
	
	if Current== nil then
	Current=period;	
	Previous=period;	
	end
	
	if math.abs( (source[Current] - source[period]))> (Delta*source:pipSize()) then		 
		if not Extend then
		Previous=Current;		
		else
        FindFractal(period);		
		end
		
		Current=period; 
	
	Draw(); 
	end
     
end

function FindFractal(period)

if source[Current] > source[Previous] and  source[period] > source[Current]then
	return;
elseif source[Current] < source[Previous] and source[period] < source[Current]  then
	 return
else
Previous=Current;		
end


end


function Draw()

 if Current==nil or Previous==nil then
 return;
 end
 
 if source[Current]> source[Previous]then
 Color=Up;
 else
 Color=Down;
 end
	core.drawLine(out, core.range(Previous, Current), source[Previous], Previous, source[Current], Current, Color);
 end
