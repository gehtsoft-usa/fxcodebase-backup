-- Id: 567

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=901

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
    indicator:name("Williams Accumulation/Distribution (WAD)");
    indicator:description("Williams Accumulation/Distribution (WAD)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addColor("clrWAD_Up", "Color of WAD Up", "Color of WAD", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clrWAD_Down", "Color of WAD Down", "Color of WAD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);

end

local first;
local source = nil;
local WAD;
local Zero;
function Prepare(nameOnly)
    source = instance.source;
    first=source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    WAD = instance:addStream("WAD", core.Line, name .. ".WAD", "WAD", instance.parameters.clrWAD_Up, first);
    WAD:setPrecision(math.max(2, instance.source:getPrecision()));
	Zero = instance:addInternalStream(first, 0);
    instance:createChannelGroup("Channel", "Channel", WAD, Zero, instance.parameters.clrWAD_Up, 100 - instance.parameters.transparency);
   
end


function Update(period, mode)

    Zero[period]=0;
	
    if (period<first+1) then
	return;
	end
	
	
     local TRH=math.max(source.high[period],source.close[period-1]);
     local TRL=math.min(source.low[period],source.close[period-1]);
     local AD;
     if source.close[period]>source.close[period-1]+source:pipSize() then
      AD=source.close[period]-TRL;
     elseif source.close[period]<source.close[period-1]-source:pipSize() then
      AD=source.close[period]-TRH;
     else
      AD=0.;
     end
     WAD[period]=WAD[period-1]+AD;
   
   
   
     if WAD[period]> 0 then
	 WAD:setColor(period,  instance.parameters.clrWAD_Up);
	 else 
	 WAD:setColor(period,  instance.parameters.clrWAD_Down);
	 end
	
	
end

