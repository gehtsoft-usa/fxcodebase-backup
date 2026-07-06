-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=973
-- Id: 17883

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Super Trend oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Alpha;
local Buff1=nil;
local Buff4=nil;
local bufferUp=nil;
local bufferDn=nil;
local var4=0.;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+100;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return
    end
    bufferUp = instance:addStream("UP", core.Bar, name .. ".ST", "ST", instance.parameters.UP_color, first);
    bufferUp:setPrecision(math.max(2, instance.source:getPrecision()));

    Alpha=core.makeArray(100);
    
    Buff1 = instance:addInternalStream(0, 0);
    Buff4 = instance:addInternalStream(0, 0);
    
    local var1;
    local var2;
    local var3;
    for i1=0,97,1 do
     if i1<=18 then
      var1=i1/18.;
     else
      var1=(i1-18.)*7./79.+1.;
     end
     var2=math.cos(math.pi*var1);
     var3=1./(3.+math.pi*var1+1.);
     if var1<=0.5 then
      var3=1.;
     end 
     Alpha[i1]=var3*var2;
     var4=var4+Alpha[i1];
    end
    
end

function Update(period, mode)
    if (period<first) then
	return;
	end
	
     local var5=0.;
     local var6;
     for i3=0,98,1 do
      var6=source.close[period-i3];
      var5=var5+Alpha[i3]*var6;
     end
     if var4>0. then
      Buff1[period]=var5/var4;
     end
     Buff4[period]=Buff4[period-1];
     if Buff1[period]>Buff1[period-1] then
      Buff4[period]=1;
     end
     if Buff1[period]<Buff1[period-1] then
      Buff4[period]=-1;
     end
	 
	 bufferUp[period]=Buff1[period];
	  if bufferUp[period] > bufferUp[period-1] then
	   
	  bufferUp:setColor(period, instance.parameters.UP_color);
	  else
	  bufferUp:setColor(period, instance.parameters.DN_color);
	  end
 
end

