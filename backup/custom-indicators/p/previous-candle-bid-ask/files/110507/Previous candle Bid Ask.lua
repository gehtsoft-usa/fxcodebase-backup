-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64295

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

 function Init()
       indicator:name("Previous candle Bid Ask");
       indicator:description("");
       indicator:requiredSource(core.Bar);
       indicator:type(core.Indicator);
	   
	   
	   indicator.parameters:addBoolean("Historical"  , "Show Historical" , "", true);
	   
	   
	indicator.parameters:addColor("color1", "High Color", "High Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

	
    indicator.parameters:addColor("color2", "Low Color", "Low Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

	
	
   end
 
   local ask;
   local bid;
   local first;
   local Historical;
   local High,Low;
    local source;
 function Prepare(nameOnly)
      source = instance.source;
       Historical=instance.parameters.Historical;
	   
	   
	     local name = profile:id() .. "(" .. source:name() .. ")";
       instance:name(name);
	   
	   if   (nameOnly) then
        return;
       end
 
       first = source:first();
 
       if source:isBid() then
           bid = source;
           ask = core.host:execute("getAskPrice");
       else
           ask = source;
           bid = core.host:execute("getBidPrice");
       end
 
     
 
    if Historical then
    High = instance:addStream("High", core.Line, name, "High", instance.parameters.color1, first);
	High:setWidth(instance.parameters.width1);
    High:setStyle(instance.parameters.style1);
    Low = instance:addStream("Low", core.Line, name, "Low", instance.parameters.color2, first);
	Low:setWidth(instance.parameters.width2);
    Low:setStyle(instance.parameters.style2);
    end
	
 end
 
 function Update(period, mode)
 
 
if Historical then
High[period] =  ask.high[period-1];
Low[period] =  bid.low[period-1];
else
High =  ask.high[period-1];
Low =  bid.low[period-1];

core.host:execute ("drawLine", 1, source:date(source:size()-2), High, source:date(source:size()-1), High, instance.parameters.color1, instance.parameters.style1, instance.parameters.width1, win32.formatNumber(High, false, source:getPrecision()));
core.host:execute ("drawLine", 2, source:date(source:size()-2), Low, source:date(source:size()-1), Low, instance.parameters.color2, instance.parameters.style2,  instance.parameters.width2, win32.formatNumber(Low, false, source:getPrecision()));
end


     
 end