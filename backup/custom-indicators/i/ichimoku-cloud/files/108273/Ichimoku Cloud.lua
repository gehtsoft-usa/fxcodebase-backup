
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63901

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
    indicator:name("Ichimoku Cloud");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("X", "Tenkan-sen period","", 9, 1, 10000);
    indicator.parameters:addInteger("Y", "Kijun-sen period","", 26, 1, 10000);
    indicator.parameters:addInteger("Z", "Senkou Span period","", 52, 1, 10000);
	
	indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("clrW", "Up Trend color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrN", "Down Trend color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
	indicator.parameters:addInteger("transp", "Cloud transparency","", 80, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
 
 
local X, Y, Z;
local first;
local source = nil;

local A,B;
local ICH;
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
	X= instance.parameters.X;
	Y= instance.parameters.Y;
	Z= instance.parameters.Z; 
	ICH= core.indicators:create("ICH", source, X, Y, Z);
    first = source:first()+Y;

       local name = string.format("(%s, %s)", profile:id(), source:name());
    instance:name(name);
    
    
	if   (nameOnly) then
        return;
    end
    
    -- BAND LINE
	
	 
	  A = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrW, first, Y);
	  A:setWidth(instance.parameters.width);
      A:setStyle(instance.parameters.style);
	  
	  B = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrN, first, Y);
	  B:setWidth(instance.parameters.width);
      B:setStyle(instance.parameters.style);
	  
	   instance:createChannelGroup("SA-SB", "SA-SB", A, B, instance.parameters.clrN, 100 - instance.parameters.transp);
 
end

-- Indicator calculation routine
function Update(period,mode)

 
    ICH:update(mode);
 
    if(period<first) then
	return;
	end
	
    A[period+Y] = ICH.SA[period+Y];
	B[period+Y] = ICH.SB[period+Y];
	
	if A[period] > B[period-1] then
	A:setColor(period, instance.parameters.clrW);
	B:setColor(period, instance.parameters.clrW);
	else 
	A:setColor(period, instance.parameters.clrN);
	B:setColor(period, instance.parameters.clrN);
	end  
	
end





