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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=61244


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Triggerlines");
    indicator:description("Triggerlines");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("length", "length", "length", 25);
    indicator.parameters:addInteger("ma_length", "MA Length", "MA Length", 13);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("WS_color", "Color of WS", "Color of WS", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("MA_color", "Color of MA", "Color of MA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local length;
local ma_length;

local first;
local source = nil;
local lengthvar;
-- Streams block
local WT = nil;
local MA = nil;
local ma;
-- Routine
function Prepare(nameOnly)
    length = instance.parameters.length;
    ma_length = instance.parameters.ma_length;
    source = instance.source;
    first = source:first()+length;
	
	lengthvar = (length + 1);
    lengthvar = lengthvar / 3;
						   
	 
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(length) .. ", " .. tostring(ma_length) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

   
        WT = instance:addStream("WT", core.Line, name .. ".WT", "WT", instance.parameters.WS_color, first);
		WT:setWidth(instance.parameters.width1);
        WT:setStyle(instance.parameters.style1);
		
		ma = core.indicators:create("EMA",WT,  ma_length);
		  
        MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MA_color,  first  + ma_length);
		MA:setWidth(instance.parameters.width2);
        MA:setStyle(instance.parameters.style2);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	 
                        local  sum = 0;
                        for i = length,  1 ,-1  do                        
                           sum= sum+ ( i - lengthvar)* source[period-length+i]; 
                        end
						 
						 
   
    WT[period] = sum*6/(length*(length+1));
	
	ma:update(mode);
	
	if period< first+ ma_length then
    return;
    end
	
	MA[period] =ma.DATA[period];
     
end

