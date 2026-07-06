
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
    
    indicator.parameters:addColor("clrIn", "Inside bar color", "Inside bar color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clrOut", "Outside bar color", "Outside bar color", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local buffIn;
local buffOut;

function Prepare(nameOnly)   
    source = instance.source;
    Percent=instance.parameters.Percent;
    MaxPeriod=instance.parameters.MaxPeriod;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    buffIn = instance:createTextOutput ("Inside", "Inside", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.clrIn, first);
    buffOut = instance:createTextOutput ("Outside", "Outside", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.clrOut, first);
end

function Update(period, mode)
  if (period>first) then
    buffOut:setNoData(period);
    buffIn:setNoData(period);
    if source.high[period]>source.high[period-1] and source.low[period]<source.low[period-1] and instance.parameters.ShowOutside then
      buffOut:set(period, source.high[period], "\159", "");
    end
    if source.high[period]<source.high[period-1] and source.low[period]>source.low[period-1] and instance.parameters.ShowInside then
      buffIn:set(period, source.low[period], "\159", "");
    end
  end 
end

