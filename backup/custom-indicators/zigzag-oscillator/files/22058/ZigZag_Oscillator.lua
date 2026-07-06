-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10714
-- Id: 5949

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("ZigZag oscillator");
    indicator:description("ZigZag oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "", 3);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Depth;
local Deviation;
local Backstep;
local Price;
local TickSource;
local ZZ;
local ZigZag_Osc=nil;
local Base;

function Prepare(nameOnly)
    source = instance.source;
    Depth=instance.parameters.Depth;
    Deviation=instance.parameters.Deviation;
    Backstep=instance.parameters.Backstep;
    Price=instance.parameters.Price;
    if Price=="open" then
     TickSource=source.open;
    elseif Price=="high" then
     TickSource=source.high;
    elseif Price=="low" then
     TickSource=source.low;
    elseif Price=="close" then
     TickSource=source.close;
    elseif Price=="median" then
     TickSource=source.median;
    elseif Price=="typical" then
     TickSource=source.typical;
    else
     TickSource=source.weighted;
    end
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Depth .. ", " .. instance.parameters.Deviation .. ", " .. instance.parameters.Backstep .. ", " .. instance.parameters.Price .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Base=instance:addInternalStream(first, 0);
    assert(core.indicators:findIndicator("ZZ_SEMAFOR") ~= nil, "ZZ_SEMAFOR" .. " indicator must be installed");
    ZZ = core.indicators:create("ZZ_SEMAFOR", source, Depth, Deviation, Backstep);
    ZigZag_Osc = instance:addStream("ZigZag_Osc", core.Bar, name .. ".ZigZag_Osc", "ZigZag_Osc", instance.parameters.UPclr, first);
    ZigZag_Osc:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first) then
    local i;
    ZZ:update(mode);
    local Start=period;
    Base[period-1]=Base[period-2];
    if ZZ.DATA[period-1]~=0 then
     Base[period-1]=ZZ.DATA[period-1];
     if Base[period-1]*Base[period-2]<0 then
      Start=period;
     else
      local PrevB=FindPrevBase(period-2);
      if PrevB==nil then
       Start=period;
      else
       for i=PrevB+1,period-1,1 do
        Base[i]=Base[i-1];
       end
       Start=PrevB;
      end
     end
    end 
    Start=Start-2;
    Base[period]=Base[period-1];
    for i=Start,period,1 do
       if Base[i]~=nil then
        local AbsBase=math.abs(Base[i]);
        ZigZag_Osc[i]=100*(TickSource[i]-AbsBase)/AbsBase;
        if ZigZag_Osc[i]>=ZigZag_Osc[i-1] then
         ZigZag_Osc:setColor(i,instance.parameters.UPclr);
        else
         ZigZag_Osc:setColor(i,instance.parameters.DNclr);
        end 
       end
    end
   end
end

function FindPrevBase(period)
    local i=period;
    while i>first do
        if ZZ.DATA[i]~=0 and Base[i]==ZZ.DATA[i] then
            return i;
        end
        i=i-1;
    end
    return nil;
end

