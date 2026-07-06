-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68171

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
    indicator:name("Bryant Adaptive Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("length", "Length", "", 14, 1, 2000);
	indicator.parameters:addInteger("maxLength", "max Length", "", 100, 1, 2000);
    indicator.parameters:addDouble("trendParam", "Trend Parameter", "",-1); 
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local length; 
local maxLength;
local trendParam;
local first;
local source = nil;
 
local Line;  
local Delta;


-- Routine
 function Prepare(nameOnly)   
 
 
 
    length = instance.parameters.length;
	maxLength= instance.parameters.maxLength;
	trendParam= instance.parameters.trendParam;
	
	
	local Parameters= length ..  ", " .. maxLength ..  ", " .. trendParam;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    first=source:first()+length;
  
    Delta = instance:addInternalStream(0, 0);   
 
	Line = instance:addStream("Line" , core.Line, " Line"," Line",instance.parameters.Up, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Delta[period]=math.abs(source[period]-source[period-1]);
	
	
    if period < first then
	return;
	end
	local change= source[period]-source[period-length+1];
	local mom = math.abs(change);
	
	
	
	volatility = mathex.sum( Delta, period- length+1, period)
	
	-- Efficiency Ratio
	local er =0;
    if volatility ~= 0  then
	er= mom / volatility;
	end
	

    -- Variable Efficiency Ratio
     ver = math.pow(er - (2 * er - 1) / 2 * (1 - trendParam) + 0.5, 2)

    local vlength = (length - ver + 1) / ver;
	 
    if vlength > maxLength then
	 vlength=maxLength; 
    end
	
    valpha = 2 / (vlength + 1);

	
		
     Line[period]=valpha * source[period] + (1 - valpha) * Line[period-1];
	 
	 if Line[period]> Line[period-1] then
	 Line:setColor(period, instance.parameters.Up);
	 else
	 Line:setColor(period, instance.parameters.Down);
	 end
				  
end
 