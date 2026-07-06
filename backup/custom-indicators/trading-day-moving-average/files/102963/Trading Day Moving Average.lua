-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 14963

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Trading Day Moving Average ");
    indicator:description("Trading Day Moving Average ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
   
   
	
   indicator.parameters:addGroup("TDMA Parameters");
  
    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
   
   indicator.parameters:addGroup("Style Parameters");
   indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width","Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    
 
end
  
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
 
local first;
local source = nil;
 
local MA = nil;
local host;
local offset;
local weekoffset;
local s=nil
local e=nil;
local START=nil;
local Price;
 
 
function Prepare(nameOnly)
   Price=instance.parameters.Price; 
    source = instance.source;
    first = source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
   
   host = core.host;
   offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
   
   
    
    MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.color, first);
    MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
   
   

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period< first or not  source:hasData(period) then
	return;
	end
   
    local i;
             if core.getcandle("D1", source:date(period),0, 0) ~= s then
             s, e = core.getcandle("D1", source:date(period),0, 0);
             START = core.findDate (source, s, false);    
             end
    
     local Sum=0;
	 local Number=0;
     for i=  START , period, 1 do
	 Number=Number+1;
	 Sum= Sum+source[Price][i];
     end	 
	 
      MA[period]= Sum /Number;
  
   
end
