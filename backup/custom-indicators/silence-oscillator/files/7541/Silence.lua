-- Id: 2919

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3194

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
    indicator:name("Silence oscillator");
    indicator:description("Silence oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 12);
    indicator.parameters:addInteger("InterpolationPeriod", "Interpolation period", "", 288);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Aclr", "Aggressiveness Color", "Aggressiveness Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Vclr", "Volatility Color", "Volatility Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local InterpolationPeriod;
local ABuff=nil;
local VBuff=nil;
local SizeArray;
local Aggress;
local Volat;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    InterpolationPeriod=instance.parameters.InterpolationPeriod;
    first = source:first()+1;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.InterpolationPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    SizeArray = instance:addInternalStream(first, 0);
    Aggress = instance:addInternalStream(first, 0);
    Volat = instance:addInternalStream(first, 0);
    
	
    ABuff = instance:addStream("ABuff", core.Line, name .. ".Aggressiveness", "Aggressiveness", instance.parameters.Aclr, first+Period);
    ABuff:setPrecision(math.max(2, instance.source:getPrecision()));
    VBuff = instance:addStream("VBuff", core.Line, name .. ".Volatility", "Volatility", instance.parameters.Vclr, first+Period);
    VBuff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first) then
    SizeArray[period]=math.abs(source[period]-source[period-1]);
    if period>first+Period then
     local B=core.avg(SizeArray,core.rangeTo(period,Period));
     local i;
     dAmount=0;
     for i=period-Period+1,period,1 do
      dAmount=dAmount+math.pow(source[i]-core.avg(source,core.rangeTo(period,Period)),2);
     end
     dAmount=dAmount/Period;
     Aggress[period]=B/source:pipSize();
     Volat[period]=math.sqrt(dAmount);
     local min=core.min(Aggress,core.rangeTo(period,math.min(InterpolationPeriod,period-first)));
     local max=core.max(Aggress,core.rangeTo(period,math.min(InterpolationPeriod,period-first)));
     ABuff[period]=Inter(max,min,100,0,Aggress[period]);
     min=core.min(Volat,core.rangeTo(period,math.min(InterpolationPeriod,period-first)));
     max=core.max(Volat,core.rangeTo(period,math.min(InterpolationPeriod,period-first)));
     VBuff[period]=Inter(max,min,100,0,Volat[period]);
    end
   end 
end

function Inter(a,b,c,d,X)
 if a==b then
  return 1000000000;
 else
  return (d-(b-X)*(d-c)/(b-a));
 end
end
