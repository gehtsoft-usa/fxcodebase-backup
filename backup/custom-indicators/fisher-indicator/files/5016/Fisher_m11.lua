-- Id: 1866
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1729

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
    indicator:name("Fisher_m11 indicator");
    indicator:description("Fisher_m11 indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("RangePeriods", "RangePeriods", "RangePeriods", 35);
    indicator.parameters:addDouble("PriceSmoothing", "PriceSmoothing", "PriceSmoothing", 0.3, 0, 0.9999);
    indicator.parameters:addDouble("IndexSmoothing", "IndexSmoothing", "IndexSmoothing", 0.3, 0, 0.9999);

    indicator.parameters:addColor("clrUP", "UP trend", "UP trend", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "DN trend", "DN trend", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local RangePeriods;
local PriceSmoothing;
local IndexSmoothing;
local buffUP=nil;
local buffDN=nil;
local buff1;
local buff2;
local buffAll;

function Prepare(nameOnly)
    source = instance.source;
    RangePeriods=instance.parameters.RangePeriods;
    PriceSmoothing=instance.parameters.PriceSmoothing;
    IndexSmoothing=instance.parameters.IndexSmoothing;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RangePeriods .. ", " .. instance.parameters.PriceSmoothing .. ", " .. instance.parameters.IndexSmoothing .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	
    buff1 = instance:addInternalStream(0, 0);
    buff2 = instance:addInternalStream(0, 0);
    first = source:first()+2;
    
	
	
	buffALL = instance:addStream("Full", core.Bar, name .. "", "", instance.parameters.clrDN, first+2*RangePeriods+4);
    buffALL:setPrecision(math.max(2, instance.source:getPrecision()));
    buffUP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.clrUP, first+2*RangePeriods+4);
    buffUP:setPrecision(math.max(2, instance.source:getPrecision()));
    buffDN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.clrDN, first+2*RangePeriods+4);
    buffDN:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

function Update(period, mode)
    if (period>first+2*RangePeriods+4) then
     local LowestLow=core.min(source.low,core.rangeTo(period,RangePeriods));
     local HighestHigh=core.max(source.high,core.rangeTo(period,RangePeriods));
     if HighestHigh-LowestLow<0.1*source:pipSize() then
      HighestHigh=LowestLow+0.1*source:pipSize();
     end
     local GreatestRange=HighestHigh-LowestLow;
     local MidPrice=(source.high[period]+source.low[period])/2.;
     local PriceLocation=0.;
     if GreatestRange~=0. then
      PriceLocation=(MidPrice-LowestLow)/GreatestRange;
      PriceLocation=2.*PriceLocation-1.;
     end
     buff2[period]=PriceSmoothing*buff2[period-1]+(1.-PriceSmoothing)*PriceLocation;
     local SmoothedLocation=buff2[period];
     SmoothedLocation=math.min(SmoothedLocation,0.99);
     SmoothedLocation=math.max(SmoothedLocation,-0.99);
     local FishIndex=0.;
     if 1.-SmoothedLocation~=0. then
      FishIndex=math.log((1.+SmoothedLocation)/(1.-SmoothedLocation));
     end
     buff1[period]=IndexSmoothing*buff1[period-1]+(1.-IndexSmoothing)*FishIndex;
     local SmoothedFish=buff1[period];
	 
	 buffALL[period]=SmoothedFish;
	 
     if SmoothedFish>0. then
      buffUP[period]=SmoothedFish;
     else
      buffDN[period]=SmoothedFish;	 
     end
    end 
end

