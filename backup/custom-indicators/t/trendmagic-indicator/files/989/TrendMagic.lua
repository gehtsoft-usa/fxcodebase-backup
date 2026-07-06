-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=563

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
    indicator:name("TrendMagic Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("CCI", "CCI", "No description", 50);
    indicator.parameters:addInteger("ATR", "ATR", "No description", 5);

    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
end

local pCCI;
local pATR;

local first;
local source = nil;
local ATR = nil;
local CCI = nil;

local thisCCI, lastCCI;

function Prepare(nameOnly)
    pCCI = instance.parameters.CCI;
    pATR = instance.parameters.ATR;
    source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. pATR .. ", " .. pCCI .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ATR = core.indicators:create("ATR", source, pATR);
    CCI = core.indicators:create("CCI", source, pCCI);
    first = math.max( ATR.DATA:first(),CCI.DATA:first());
	
	
    bufferUp = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.UP_color, first);
    bufferDn = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.DN_color, first);
end

function Update(period, mode)
    ATR:update(mode);
    CCI:update(mode);
    if (period>=first) then
     thisCCI=CCI.DATA[period];
     lastCCI=CCI.DATA[period-1];
     if (thisCCI>=0 and lastCCI<0) then bufferUp[period-1]=bufferDn[period-1] end
     if (thisCCI<=0 and lastCCI>0) then bufferDn[period-1]=bufferUp[period-1] end

     if (thisCCI>=0) then
       bufferUp[period]=source.low[period]-ATR.DATA[period];
       if (bufferUp[period]<bufferUp[period-1]) then
        bufferUp[period]=bufferUp[period-1];
       end
     end
     if (thisCCI<=0) then
       bufferDn[period]=source.high[period]+ATR.DATA[period];
       if (bufferDn[period]>bufferDn[period-1]) then
        bufferDn[period]=bufferDn[period-1];
       end 
      end 
      else
      bufferDn[period]=0;
      bufferUp[period]=0;     
    end
end

