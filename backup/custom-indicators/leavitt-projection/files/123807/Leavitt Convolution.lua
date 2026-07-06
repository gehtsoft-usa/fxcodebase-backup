-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67335

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("Leavitt Convolution");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 9, 1, 2000);
 
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period,Length; 
local first;
local source = nil; 
local Projection;  
local Indicator1,Indicator2; 
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period= instance.parameters.Period;
	
	Length=math.floor(math.sqrt(Period));
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
    assert(core.indicators:findIndicator("LEAVITT PROJECTION") ~= nil, "Please, download and install LEAVITT PROJECTION.LUA indicator");
			
    source = instance.source;
   
	
	
	Indicator1 = core.indicators:create("LEAVITT PROJECTION", source, Period);
	Indicator2 = core.indicators:create("LEAVITT PROJECTION", Indicator1.DATA, Length);
	
	 first=Indicator2.DATA:first();
   
	Projection = instance:addStream("Projection" , core.Line, "Projection","Projection",instance.parameters.Up, first+Period);
	Projection:setWidth(instance.parameters.width);
    Projection:setStyle(instance.parameters.style);
    Projection:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

  
	Indicator1:update(mode);
	Indicator2:update(mode);
	
    if period < first then
	return;
	end
	 
     Projection[period]=Indicator2.DATA[period];
	 
	 if Projection[period] > Projection[period-1] then
	 Projection:setColor(period, instance.parameters.Up);
	 else
	 Projection:setColor(period, instance.parameters.Down);
	 end
				  
end


