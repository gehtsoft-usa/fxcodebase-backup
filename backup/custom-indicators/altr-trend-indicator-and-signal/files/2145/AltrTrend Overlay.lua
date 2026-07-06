
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
    indicator:name("Altr Trend indicator Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("K", "K", "", 30);
    indicator.parameters:addDouble("KStop", "KStop", "", 0.5);
    indicator.parameters:addInteger("Kperiod", "Kperiod", "", 150);
    indicator.parameters:addInteger("PerADX", "PerADX", "", 14);

     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
end

local K;
local KStop;
local Kperiod;
local PerADX;

local first;
local source = nil;
local ADX;
local buffUp=nil;
--local buffDn=nil;
--local uptrend=nil;
local old=nil;


local Up,Down, Neutral;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local volume=nil;

local Trend;

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
    first = ADX.DATA:first()+Kperiod;
	
  
    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
	volume = instance:addStream("volume", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close, volume);
	
	Trend = instance:addInternalStream(first, 0);
end

function Update(period, mode)


    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	volume[period] = source.volume[period];
	
	
	ADX:update(mode);
	
    if (period<first) then
	open:setColor(period, Neutral);	
	return;
	end	
     
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
     
	 Trend[period]=Trend[period-1];
	 
     if source.close[period]<smin then
     Trend[period]=-1;
     end
     if source.close[period]>smax then
     Trend[period]=1;
     end
	 
	  
	 
	 if Trend[period]== 1 then
	 open:setColor(period, Up);	
	 elseif Trend[period]== -1 then
	 open:setColor(period, Down);
	 else
	 open:setColor(period, Neutral);	
	 end
     
end

