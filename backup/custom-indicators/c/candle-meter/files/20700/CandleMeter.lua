-- Id: 5283

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9706

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
    indicator:name("Candle meter");
    indicator:description("Candle meter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Count", "Count Doji", "", true);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
	
	
end

local first;
local source = nil;
local CandleMeter=nil;
local Count;
function Prepare(nameOnly)
    source = instance.source;
	Count= instance.parameters.Count;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    CandleMeter = instance:addStream("CandleMeter", core.Bar, name .. ".CandleMeter", "CandleMeter", instance.parameters.UPclr, first);
    CandleMeter:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    if (period<=first) then
    CandleMeter[period]=0;
   end	
   
    local Direction;
    if source.close[period]>source.open[period]	
	or
	(Count and (source.close[period] - source.open[period])==0 and CandleMeter[period-1]>0 )
	then
		 if CandleMeter[period-1]>0 then
		  CandleMeter[period]=CandleMeter[period-1]+1;
		 else
		  CandleMeter[period]=1;
		 end
		 CandleMeter:setColor(period,instance.parameters.UPclr);
    elseif source.close[period]<source.open[period]
	or
	(Count and (source.close[period] - source.open[period])==0 and CandleMeter[period-1]<0 )
	then
		 if CandleMeter[period-1]<0 then
		  CandleMeter[period]=CandleMeter[period-1]-1;
		 else
		  CandleMeter[period]=-1;
		 end
		 CandleMeter:setColor(period,instance.parameters.DNclr);
    else
	        
			
        	CandleMeter[period]=CandleMeter[period-1];
		 
		 
		 if CandleMeter[period]>0 then
		  CandleMeter:setColor(period,instance.parameters.UPclr);
		 else
		  CandleMeter:setColor(period,instance.parameters.DNclr);
		 end
    end 
   
end

