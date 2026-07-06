-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34068
-- Id: 8887

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Trend continuation oscillator");
    indicator:description("Trend continuation oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addString("SMethod", "Smooth method", "", "MVA");
    indicator.parameters:addStringAlternative("SMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SMethod", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("SPeriod", "Smooth period", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local Period;
local SMethod;
local SPeriod;
local Pbuff=nil;
local Mbuff=nil;
local Count={};
local Change_p={};
local Change_n={};
local CF_p={};
local CF_n={};
local k_p;
local k_n;
local MAp, MAn;
local pipSize;
local count=1;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    SMethod=instance.parameters.SMethod;
    SPeriod=instance.parameters.SPeriod;
    first = source:first()+1;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.SMethod .. ", " .. instance.parameters.SPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    k_p = instance:addInternalStream(first, 0);
    k_n = instance:addInternalStream(first, 0);
    MAp = core.indicators:create("AVERAGES", k_p, SMethod, SPeriod, false);
    MAn = core.indicators:create("AVERAGES", k_n, SMethod, SPeriod, false);
    Pbuff = instance:addStream("Pbuff", core.Line, name .. ".Pbuff", "Pbuff", instance.parameters.UPclr,  MAp.DATA:first() );
    Pbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Mbuff = instance:addStream("Mbuff", core.Line, name .. ".Mbuff", "Mbuff", instance.parameters.UPclr,  MAp.DATA:first() );
    Mbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createChannelGroup("TC","TC" , Pbuff, Mbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
    local i;
    pipSize=source:pipSize();
    for i=0, Period+1, 1 do
     Count[i]=0;
     Change_p[i]=0;
     Change_n[i]=0;
     CF_p[i]=0;
     CF_n[i]=0;
    end
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    local dprice=source[period]-source[period-1];
    local i0=Count[0];
    local i1=Count[1];
    Change_p[i0]=0;
    CF_p[i0]=0;
    Change_n[i0]=0;
    CF_n[i0]=0;
    if dprice>0 then
     Change_p[i0]=-dprice;
     CF_p[i0]=Change_p[i0]+CF_p[i1];
    elseif dprice<0 then
     Change_n[i0]=dprice;
     CF_n[i0]=Change_n[i0]+CF_n[i1];
    end
    local ch_p, ch_n = 0, 0;
    local cff_p, cff_n = 0, 0;
    local i;
    for i=0, Period, 1 do
     ch_p=ch_p+Change_p[i];
     ch_n=ch_n+Change_n[i];
     cff_p=cff_p+CF_p[i];
     cff_n=cff_n+CF_n[i];
    end
    k_p[period]=ch_p-cff_n;
    k_n[period]=ch_n-cff_p;
	
    MAp:update(mode);
    MAn:update(mode);
	
	if period < MAp.DATA:first() then
	return;
	end
	
    Pbuff[period]=MAp.DATA[period]/pipSize;
    Mbuff[period]=MAn.DATA[period]/pipSize;
    
    if period~=source:size()-1 then
     count=count-1;
     if count<0 then
      count=Period-1;
     end
     for i=0, Period-1, 1 do
      if i+count>Period-1 then
       Count[i]=i+count-Period;
      else
       Count[i]=i+count;
      end
     end
    end
    
    if Pbuff[period]>Mbuff[period] then
     Pbuff:setColor(period, instance.parameters.UPclr);
     Mbuff:setColor(period, instance.parameters.UPclr);
    else
     Pbuff:setColor(period, instance.parameters.DNclr);
     Mbuff:setColor(period, instance.parameters.DNclr);
    end
 
end

