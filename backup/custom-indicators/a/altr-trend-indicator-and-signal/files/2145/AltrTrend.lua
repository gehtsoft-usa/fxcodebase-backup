
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1123

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
    indicator:name("Altr Trend indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("K", "K", "No description", 30);
    indicator.parameters:addDouble("KStop", "KStop", "No description", 0.5);
    indicator.parameters:addInteger("Kperiod", "Kperiod", "No description", 150);
    indicator.parameters:addInteger("PerADX", "PerADX", "No description", 14);

    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
end

local K;
local KStop;
local Kperiod;
local PerADX;

local first;
local source = nil;
local ADX;
local buffUp=nil;
local buffDn=nil;
local uptrend=nil;
local old=nil;

function Prepare(nameOnly) 
    K = instance.parameters.K;
    KStop = instance.parameters.KStop;
    Kperiod = instance.parameters.Kperiod;
    PerADX = instance.parameters.PerADX;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. K .. ", " .. KStop .. ", " .. Kperiod .. ", " .. PerADX .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
	
    ADX=core.indicators:create("ADX", source, PerADX);
    first = ADX.DATA:first();
    
	
	
    buffUp = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, first+Kperiod);
    buffDn = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, first+Kperiod);
end

function Update(period, mode)
    if (period>first+Kperiod) then
     ADX:update(mode);
     local SSP=math.ceil(Kperiod/ADX.DATA[period-1]);
     local AvgRange=0.;
     for i=period-SSP,period,1 do
      AvgRange=AvgRange+math.abs(source.high[i]-source.low[i]);
     end
     local Range=AvgRange/(SSP+1);
     local SsMax=core.max(source.high,core.rangeTo(period,SSP-1));
     local SsMin=core.min(source.low,core.rangeTo(period,SSP-1));
     local smin=SsMin+(SsMax-SsMin)*K/100.;
     local smax=SsMax-(SsMax-SsMin)*K/100.;
     
     if source.close[period]<smin then
      uptrend=false;
     end
     if source.close[period]>smax then
      uptrend=true;
     end
     
     if uptrend~=old and uptrend==true then
      buffUp:set(period, source.low[period]-Range*KStop, "\225", "");
     end
     if uptrend~=old and uptrend==false then
      buffDn:set(period, source.high[period]+Range*KStop, "\226", "");
     end
     old=uptrend;

    end
end

