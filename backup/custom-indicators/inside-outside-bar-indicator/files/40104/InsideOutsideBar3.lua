
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1838

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
    indicator:name("Inside/outside bar Indicator");
    indicator:description("Inside/outside bar Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addBoolean("ShowInside", "Show inside bar", "", true);
    indicator.parameters:addBoolean("ShowOutside", "Show outside bar", "", true);
    indicator.parameters:addString("Position", "Position", "", "Above");
    indicator.parameters:addStringAlternative("Position", "Above", "", "Above");
    indicator.parameters:addStringAlternative("Position", "Below", "", "Below");
    
    indicator.parameters:addColor("clrIn", "Inside bar color", "Inside bar color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clrOut", "Outside bar color", "Outside bar color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("FontSize", "Font size", "", 10);
end

local first;
local source = nil;
local buffIn;
local buffOut;
local Position;

function Prepare(nameOnly)   
    source = instance.source;
    Position=instance.parameters.Position;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    if Position=="Below" then
     buffIn = instance:createTextOutput ("Inside", "Inside", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.clrIn, first);
     buffOut = instance:createTextOutput ("Outside", "Outside", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.clrOut, first);
    else
     buffIn = instance:createTextOutput ("Inside", "Inside", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.clrIn, first);
     buffOut = instance:createTextOutput ("Outside", "Outside", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.clrOut, first);
    end 
end

function Update(period, mode)
    if (period>first) then
     if source.high[period]>source.high[period-1] and source.low[period]<source.low[period-1] and instance.parameters.ShowOutside then
      if Position=="Above" then
       buffOut:set(period, source.high[period], "O", "");
      else
       buffOut:set(period, source.low[period], "O", "");
      end 
     else 
      buffOut:setNoData(period);
     end
     if source.high[period]<source.high[period-1] and source.low[period]>source.low[period-1] and instance.parameters.ShowInside then
      if Position=="Above" then
       buffIn:set(period, source.high[period], "I", "");
      else
       buffIn:set(period, source.low[period], "I", "");
      end 
     else
      buffIn:setNoData(period);
     end
    end 
end

