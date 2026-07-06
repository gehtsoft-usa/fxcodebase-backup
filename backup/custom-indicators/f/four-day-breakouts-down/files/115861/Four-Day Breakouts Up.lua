-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65332

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
    indicator:name("Four-Day Breakouts");
    indicator:description("Four-Day Breakouts");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

   
 
    indicator.parameters:addGroup("Style");
 
   indicator.parameters:addColor("clrUP", "Up color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Size", "Size", "Size", 15  );
end

local first;
local source = nil;
--local  Period; 
local Up,Down,Size;
local Pattern;

function Prepare(nameOnly)  
    source = instance.source; 
    Pattern = instance:addInternalStream(0, 0);
	
   -- Period=instance.parameters.Period;
	Size=instance.parameters.Size;
    first = source:first();
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    Up  = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
     Up:setNoData(period);
	 
	 Pattern[period]=0;
	
 if source.close[period] > source.open[period]  
and source.close[period-1] > source.open[period-1] 
and source.close[period-2] > source.open[period-2] 
and source.close[period-3] > source.open[period-3] then
Pattern[period]=1;
end

local NewPatternFound = false;
if Pattern[period]== 1  and   Pattern[period-1]~=1 then
NewPatternFound=true;
end

	
	
	  if NewPatternFound then     
	  Up:set(period, source.high[period], "\217");
	  end
	
 	 
	   
end

