-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31127
-- Id: 8361

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
    indicator:name("Adaptosctry indicator");
    indicator:description("Adaptosctry indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("nExtr1", "nExtr1", "", 3);
    indicator.parameters:addInteger("nExtr2", "nExtr2", "", 6);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local nExtr1;
local nExtr2;
local Buff1=nil;
local Buff2=nil;
local Buff3=nil;
local FATL;

function Prepare(nameOnly)
    source = instance.source;
    nExtr1=instance.parameters.nExtr1;
    nExtr2=instance.parameters.nExtr2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.nExtr1 .. ", " .. instance.parameters.nExtr2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("FATL") ~= nil, "Please, download and install FATL.LUA indicator");    
	
    FATL = core.indicators:create("FATL", source);
	
	first = FATL.DATA:first();
	
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Buff1", "Buff1", instance.parameters.clr1, first);
    Buff1:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Buff2", "Buff2", instance.parameters.clr2, first);
    Buff2:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff3 = instance:addStream("Buff3", core.Line, name .. ".Buff3", "Buff3", instance.parameters.clr3, first);
    Buff3:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff1:setWidth(instance.parameters.widthLinReg);
    Buff1:setStyle(instance.parameters.styleLinReg);
    Buff2:setWidth(instance.parameters.widthLinReg);
    Buff2:setStyle(instance.parameters.styleLinReg);
    Buff3:setWidth(instance.parameters.widthLinReg);
    Buff3:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
    FATL:update(mode);
    local i=period-1;
    local n=0;
    local Pe1=nil;
    local Pe2=nil;
    while i>first+2 and (Pe1==nil or Pe2==nil) do
     if (FATL.DATA[i]>FATL.DATA[i-1] and FATL.DATA[i-1]<FATL.DATA[i-2]) or (FATL.DATA[i]<FATL.DATA[i-1] and FATL.DATA[i-1]>FATL.DATA[i-2]) then
      n=n+1;
      if n==nExtr1 and Pe1==nil then
       Pe1=period-i;
      end
      if n==nExtr2 and Pe2==nil then
       Pe2=period-i;
      end
     end
     i=i-1; 
    end
    if Pe1~=nil and Pe2~=nil then
     Buff1[period]=RSI(period, Pe1);
     Buff2[period]=RSI(period, Pe2);
     Buff3[period]=(Buff1[period]+Buff2[period])/2;
    end
   end 
end

function RSI(period, Period)
 local i=period;
 local sump=0;
 local sumn=0;
 local d;
 while i>first and period-i<Period do
  d=source[i]-source[i-1];
  if d>0 then
   sump=sump+d;
  else
   sumn=sumn-d;
  end
  i=i-1;
 end
 sump=sump/Period;
 sumn=sumn/Period;
 if sumn==0 then
  return 0;
 else 
  return 100-100/(1+sump/sumn);
 end 
end

