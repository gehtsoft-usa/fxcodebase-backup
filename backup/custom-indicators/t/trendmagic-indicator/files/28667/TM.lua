-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=563&start=10

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
    indicator:name("Trend Magic");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CP", "CCI Periods", "", 50);
	 indicator.parameters:addDouble("AP", "ATR Period", "", 5);
    indicator.parameters:addDouble("AM", "ATR Multiplier", "", 1);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local AP, CP, AM;

local first;
local source = nil;
local ATR = nil;
local CCI;

-- Streams block
local OUT = nil;
local UP = nil;
local DN = nil;
local TR = nil;

-- Routine
function Prepare(nameOnly)
    CP = instance.parameters.CP;
    AP = instance.parameters.AP;
	AM = instance.parameters.AM;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. CP .. ", " .. AP .. ", " .. AM .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ATR = core.indicators:create("ATR", source, AP);
	CCI = core.indicators:create("CCI", source, CP);
    first = math.max( ATR.DATA:first(),CCI.DATA:first()) ;
	
	
    UP = instance:addInternalStream(first, 0);
    DN = instance:addInternalStream(first, 0);
    TR = instance:addInternalStream(first, 0);
    OUT = instance:addStream("ST", core.Line, name .. ".Super Trend", "Super Trend", instance.parameters.UP_color, first);    
	OUT:setWidth(instance.parameters.width);
    OUT:setStyle(instance.parameters.style);	
end

-- Indicator calculation routine
function Update(period, mode)
    ATR:update(mode);	
	CCI:update(mode);
	
	 if period <  first then
	return;
	end
           
   
     if CCI.DATA[period] > 0 then
	 TR[period]= 1;
	 OUT[period] = math.max( (source.low[period] - ATR.DATA[period]*AM),  OUT[period-1]);
	 elseif CCI.DATA[period] < 0 then
	  TR[period]= -1;
	  OUT[period] = math.min( (source.high[period] + ATR.DATA[period]*AM),  OUT[period-1]);
	 end
   	
     
            if TR[period] == 1 then               
                 OUT:setColor(period, instance.parameters.UP_color); 				
            end

            if TR[period] == -1 then               
                OUT:setColor(period, instance.parameters.DN_color);				
            end
end
 
