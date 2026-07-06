
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63044

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
function Init()
    indicator:name("AROON Modification");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period","", 100, 3, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUp", "Up Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthUP", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleUP", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleUP", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrDown", "Down Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthDOWN", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleDOWN", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDOWN", core.FLAG_LEVEL_STYLE);
	
	 
end

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local firstPeriod;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;
local Aroon;
  
-- Routine
function Prepare(nameOnly) 
    N = instance.parameters.N;
    source = instance.source;
	firstPeriod=source:first()+N;
	 
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    UP = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.clrUp, firstPeriod)
    UP:setWidth(instance.parameters.widthUP);
    UP:setStyle(instance.parameters.styleUP);
    UP:setPrecision(2);
    DOWN = instance:addStream("DOWN", core.Line, name .. ".DOWN", "DOWN", instance.parameters.clrDown, firstPeriod)
    DOWN:setWidth(instance.parameters.widthDOWN);
    DOWN:setStyle(instance.parameters.styleDOWN);
    DOWN:setPrecision(2);
	
	 
  
end

 
 

function Update(period )

   
	
	if period < firstPeriod then
	return;
	end
	
	vmin, vmax, pmin, pmax = mathex.minmax(source, period - N + 1, period);
	
	UP[period]=( (100-(period-pmax))/100)*100;
	DOWN[period]= ( (100-(period-pmin))/100)*100;
	
	 
	  
end

 