-- Id: 10601

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60026

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
    indicator:name("Smoothed Stochastic Inverse Fisher Transform");
    indicator:description("Smoothed Stochastic Inverse Fisher Transform");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 30);
    indicator.parameters:addInteger("Slowing", "Slowing", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("IFTclr", "IFT Stoch color", "IFT Stoch color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("IFTwidth", "IFT Stoch width", "IFT Stoch width", 1, 1, 5);
    indicator.parameters:addInteger("IFTstyle", "IFT Stoch style", "IFT Stoch style", core.LINE_SOLID);
    indicator.parameters:setFlag("IFTstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("RBWclr", "RBW Stoch color", "RBW Stoch color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("RBWwidth", "RBW Stoch width", "RBW Stoch width", 1, 1, 5);
    indicator.parameters:addInteger("RBWstyle", "RBW Stoch style", "RBW Stoch style", core.LINE_SOLID);
    indicator.parameters:setFlag("RBWstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Slowing;
local Rainbow;
local Stoch;
local SMA;
local IFT=nil;
local RBW=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Slowing=instance.parameters.Slowing;
    first = source:first()+10;
    Rainbow = instance:addInternalStream(0, 0);
    Stoch = instance:addInternalStream(0, 0);
    SMA = core.indicators:create("MVA", Stoch, Slowing);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Slowing .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
    IFT = instance:addStream("IFT", core.Line, name .. ".IFT", "IFT", instance.parameters.IFTclr,  SMA.DATA:first());
    IFT:setWidth(instance.parameters.IFTwidth);
    IFT:setStyle(instance.parameters.IFTstyle);
    RBW = instance:addStream("RBW", core.Line, name .. ".RBW", "RBW", instance.parameters.RBWclr, SMA.DATA:first());
    RBW:setWidth(instance.parameters.RBWwidth);
    RBW:setStyle(instance.parameters.RBWstyle);
	
	IFT:setPrecision(math.max(2, instance.source:getPrecision()));
	RBW:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    Rainbow[period]=(20*source[period]+75*source[period-1]+180*source[period-2]+336*source[period-3]+463*source[period-4]+462*source[period-5]+330*source[period-6]+165*source[period-7]+55*source[period-8]+11*source[period-9]+source[period-10])/2098;
    
	if period<first+Period then
	return;
	end
	
     local Min, Max = mathex.minmax(Rainbow, period-Period+1, period);
     Stoch[period] = 100*(Rainbow[period]-Min)/(Max-Min);
     SMA:update(mode);
	 if period < SMA.DATA:first() then
	 return;
	 end
	 
     RBW[period]=SMA.DATA[period];
     local x=(RBW[period]-50)/5;
     IFT[period]=((math.exp(x)-1)/(math.exp(x)+1)+1)*50;
   
 
end

