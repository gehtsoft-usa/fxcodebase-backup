-- Id: 1906

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2360

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
    indicator:name("Renko indicator");
    indicator:description("Renko indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Step", "Step", "", 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Step;
local BuffUP=nil;
local BuffDN=nil;
local RenkoBuff;
local RenkoBuffShift;
local i;

function Prepare(nameOnly)
    source = instance.source;
    Step=instance.parameters.Step;
    first = source:first()+2;
    RenkoBuff = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Step .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    BuffUP = instance:addStream("BuffUP", core.Bar, name .. ".BuffUP", "BuffUP", instance.parameters.clrUP, first);
    BuffUP:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffDN = instance:addStream("BuffDN", core.Bar, name .. ".BuffDN", "BuffDN", instance.parameters.clrDN, first);
    BuffDN:setPrecision(math.max(2, instance.source:getPrecision()));
end

function CheckBuff(period)
 local ii;
 if RenkoBuffShift>period then
  for ii=first+1,period,1 do
   RenkoBuff[ii-1]=RenkoBuff[ii];
  end
  RenkoBuffShift=RenkoBuffShift-1;
 end
end

function Update(period, mode)
   if (period>first) then
    RenkoBuffShift=first;
    RenkoBuff[RenkoBuffShift]=source[first];
    for i=first+1,period,1 do
     if RenkoBuffShift==first then
      while source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() do
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+Step*source:pipSize();
      end
      while source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() do
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Step*source:pipSize();
      end
     end
     
     if RenkoBuff[RenkoBuffShift]>RenkoBuff[RenkoBuffShift-1] then
      if source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() then
       while source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+Step*source:pipSize();
       end
      end
      if source[i]<RenkoBuff[RenkoBuffShift]-2.*Step*source:pipSize() then
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-2.*Step*source:pipSize();
       while source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Step*source:pipSize();
       end
      end
     end
     
     if RenkoBuff[RenkoBuffShift]<RenkoBuff[RenkoBuffShift-1] then
      if source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() then
       while source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Step*source:pipSize();
       end
      end
      if source[i]>RenkoBuff[RenkoBuffShift]+2.*Step*source:pipSize() then
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+2.*Step*source:pipSize();
       while source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+Step*source:pipSize();
       end
      end
     end
     
    end
    
    for i=first,period,1 do
     local NewPos=i-period+RenkoBuffShift;
     if NewPos<=first then
      BuffUP[i]=nil;
      BuffDN[i]=nil;
     else
      if RenkoBuff[NewPos]>RenkoBuff[NewPos-1] then
       BuffUP[i]=RenkoBuff[NewPos];
       BuffDN[i]=nil;
      else
       BuffDN[i]=RenkoBuff[NewPos];
       BuffUP[i]=nil;
      end 
     end
    end
    
   end 
end

