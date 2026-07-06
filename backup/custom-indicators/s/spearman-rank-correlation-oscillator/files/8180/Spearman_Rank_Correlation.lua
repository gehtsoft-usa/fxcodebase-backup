-- Id: 3129
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3427

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Spearman Rank Correlation oscillator");
    indicator:description("Spearman Rank Correlation oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Range", "Range", "", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local Range;
local Buff=nil;
local IntPrice;
local PriceTable={};
local PriceTable2={};
local RealRank={};
local TrueRanks={};

function Prepare(nameOnly)
    source = instance.source;
    Range=instance.parameters.Range;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Range .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    IntPrice = instance:addInternalStream(first, 0);
    Buff = instance:addStream("Buff", core.Line, name .. ".SRC", "SRC", instance.parameters.clr, first+Range);
    Buff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   IntPrice[period]=math.floor(source[period]/source:pipSize());
   if (period>first+Range) then
    local i;
    for i=0,Range-1,1 do
     PriceTable[i]=IntPrice[period-i];
     PriceTable2[i]=IntPrice[period-i];
    end
    table.sort(PriceTable);
    local duplicate;
    local k;
    local m;
    local counter;
    local master;
    local duplicateCounter;
    local averageRank;
    for i=0,Range-1,1 do
     TrueRanks[i]=i+1;
     RealRank[i]=0;
    end
    for i=0,Range-2,1 do
     if PriceTable[i]==PriceTable[i+1] then
      duplicate=PriceTable[i];
      k=i+1;
      counter=1;
      averageRank=i+1;
      while k<Range do
       if PriceTable[k]==duplicate then
        counter=counter+1;
        averageRank=averageRank+k+1;
        k=k+1;
       else
        break;
       end
      end
      duplicateCounter=counter;
      averageRank=averageRank/duplicateCounter;
      for m=i,k-1,1 do
       TrueRanks[m]=averageRank;
      end
      i=k;
     end
    end
    for i=0,Range-1,1 do
     master=PriceTable2[i];
     k=0;
     while k<Range do
      if master==PriceTable[k] then
       RealRank[i]=TrueRanks[k];
       break;
      end
      k=k+1;
     end
    end
    local rankSum=0;
    for i=0,Range-1,1 do
     rankSum=rankSum+math.pow(RealRank[i]-i-1,2);
    end
    Buff[period]=1-6*rankSum/(math.pow(Range,3)-Range);
   end
end

