-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2801


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
-- initializes the indicator
function Init()
    indicator:name("Percentage Price Follower"); -- % Slow moving price follower
    indicator:description("Percentage Price Follower");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
--    indicator:setTag("group", "Custom");

    indicator.parameters:addGroup("Calculation");
    
	indicator.parameters:addString("Type", "Two", "", "One");
    indicator.parameters:addStringAlternative("Type", "One", "", "One");
    indicator.parameters:addStringAlternative("Type", "Two", "", "Two");
	
	indicator.parameters:addInteger("N", "One  % movement", "Percentage", 10, 1, 100);
	indicator.parameters:addInteger("M", "Two  % movement", "Percentage", 90, 1, 100);
		
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrDIP", "Color", "Color", core.rgb(255, 0, 255));
    indicator.parameters:addInteger("widthDIP", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("styleDIP", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDIP", core.FLAG_LINE_STYLE);
end

local Type;
local first;
local n;
local source = nil;
local out = nil;
-- initializes the instance of the indicator
function Prepare(nameOnly)    
    source = instance.source;   
	Type=instance.parameters.Type;	 
	if Type == "One" then
	n = instance.parameters.N;
	else
	n = instance.parameters.M;
	end
	 
    first = n + source:first() - 1;
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    out = instance:addStream("SMPF", core.Line, name, "SMPF", instance.parameters.clrDIP, first)
    out:setWidth(instance.parameters.widthDIP);
    out:setStyle(instance.parameters.styleDIP);
end

-- calculate the value
function Update(period)
   
   
   if period < 2 then 
   out[period]=source.close[period];
   return;
   end
   
   if Type == "One" then
	   
		   if  out[period-1] < source.close[period] then
			  out[period] = out[period-1] +(((source.high[period] - source.low[period])/100)*n);
		   elseif out[period-1] > source.close[period] then
			out[period] = out[period-1] -(((source.high[period] - source.low[period])/100)*n)
			else
			out[period] = out[period-1];
		   end   
   else 
 
    out[period] = out[period-1] +(((source.close[period] - source.open[period])/100)*n);    
	end

    
end