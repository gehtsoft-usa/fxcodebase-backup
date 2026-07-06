-- Id: 20569


-- More information about this indicator can be found at:
-- --http://fxcodebase.com/code/viewtopic.php?f=17&t=896

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Detrended Momentum");
    indicator:description("Detrended Momentum");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Momentum Calculation");
    indicator.parameters:addInteger("N1", "N1", "Period", 14);
	
	  indicator.parameters:addGroup("MA Calculation");
    indicator.parameters:addInteger("N2", "N2", "Period", 14);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");   
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Detrended Momentum Color Up in Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("clr2", "Detrended Momentum Color Down in Up Trend", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("clr3", "Detrended Momentum Color Up in Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("clr4", "Detrended Momentum Color Down in Down Trend", "", core.rgb(200, 0, 0));

 
end

local first;
local source = nil;
local N1,N2, Method;
local Indicator, Momentum, MA,DetrendedMomentum;
function Prepare(nameOnly)
    source = instance.source;
    N1=instance.parameters.N1;
	 N2=instance.parameters.N2;
	 Method=instance.parameters.Method;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N1.. ", " .. N2.. ", " .. Method .. ")";
    instance:name(name);
	
 
	if   (nameOnly) then
        return;
    end
	
		assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "Please, download and install Momentum.LUA indicator");
	
	Momentum = core.indicators:create("MOMENTUM", source, N1);
	MA = core.indicators:create(Method, Momentum.DATA, N2);
	    first = MA.DATA:first() ;
	
    DetrendedMomentum = instance:addStream("DetrendedMomentum", core.Bar, name .. ".Detrended Momentum", "Detrended Momentum", instance.parameters.clr1, first);
    
	DetrendedMomentum:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)

    Momentum:update(mode);
	MA:update(mode);
	
    if (period<first) then
	return;
	end
	
    DetrendedMomentum[period]=Momentum.DATA[period]-MA.DATA[period];
	
	if Momentum.DATA[period]> 100 then
		if Momentum.DATA[period]> MA.DATA[period] then
		DetrendedMomentum:setColor(period, instance.parameters.clr1);
		else
		DetrendedMomentum:setColor(period, instance.parameters.clr2);
		end
	else	
	    if Momentum.DATA[period]> MA.DATA[period] then
		DetrendedMomentum:setColor(period, instance.parameters.clr3);
		else
		DetrendedMomentum:setColor(period, instance.parameters.clr4);
		end
	end
  
end

