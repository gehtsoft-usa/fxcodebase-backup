-- Id: 19263
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65176

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
    indicator:name("Volume Index");
    indicator:description("Volume Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("Show", "Show Components", "", false);
    indicator.parameters:addColor("PVI", "PVI Line Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("NVI", "NVI Line Color", "Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DELTA", "Delta Bar Color", "Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local PVI, NVI,Delta;
local Show;

function Prepare(nameOnly) 
    source = instance.source;
    Show=instance.parameters.Show;
    first = source:first()+1;
    local name = profile:id() .. "(" .. source:name()    .. ")";
    instance:name(name);
	 
	 if   (nameOnly) then
        return;
    end
	 
	if Show then 
	PVI = instance:addStream("PVI", core.Line, name .. ".PVI", "PVI", instance.parameters.PVI, first);
    PVI:setPrecision(math.max(2, instance.source:getPrecision()));
    PVI:setWidth(instance.parameters.width);
    PVI:setStyle(instance.parameters.style);
	
	NVI = instance:addStream("NVI", core.Line, name .. ".NVI", "NVI", instance.parameters.NVI, first);
    NVI:setPrecision(math.max(2, instance.source:getPrecision()));
    NVI:setWidth(instance.parameters.width);
    NVI:setStyle(instance.parameters.style);
	else
	
	NVI = instance:addInternalStream(first, 0);
	PVI = instance:addInternalStream(first, 0);
	end
	
	if Show then 
	Delta = instance:addStream("Delta", core.Line, name .. ".Delta", "Delta", instance.parameters.DELTA, first);
    Delta:setWidth(instance.parameters.width);
    Delta:setStyle(instance.parameters.style);
	else
	Delta = instance:addStream("Delta", core.Bar, name .. ".Delta", "Delta", instance.parameters.DELTA, first);
	end
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

function Update(period, mode)
 if period < first then
 PVI[period]=1;
 NVI[period]=1;
 return;
 end
   if source.volume[period]>source.volume[period-1] then
   PVI[period]=PVI[period-1]*(1+((source.close[period]-source.close[period-1])/source.close[period-1]));
   else
   PVI[period]=PVI[period-1];
   end
   
   if source.volume[period]<source.volume[period-1] then
   NVI[period]=NVI[period-1]*(1+(source.close[period]-source.close[period-1])/source.close[period-1]);
   else
   NVI[period]=NVI[period-1];
   end
   
   
   Delta[period]=PVI[period]-NVI[period];
   
   if Show then 
   Delta[period]= math.min(NVI[period], PVI[period])+math.abs(Delta[period])/2;
   end
    
   
end

