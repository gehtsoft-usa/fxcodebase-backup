-- Id: 10517
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59974


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
    indicator:name("SI oscillator");
    indicator:description("SI oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 15);
    indicator.parameters:addString("Method", "Method", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local Method;
local D;
local MA;
local SI=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
    D = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
    MA = core.indicators:create("AVERAGES", D, Method, Period, false);
	
	 first = MA.DATA:first() ;
    
    SI = instance:addStream("SI", core.Bar, name .. ".SI", "SI", instance.parameters.UPclr, first);
	SI:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<source:first()+1 then
   return;
   end
   
    local R1=math.abs(source.high[period]-source.close[period-1]);
    local R2=math.abs(source.low[period]-source.close[period-1]);
    local R3=math.abs(source.high[period]-source.low[period]);
    local R4=math.abs(source.close[period-1]-source.open[period-1]);
    local K=math.max(R1, R2);
    local R=0;
    if R1>=math.max(R2, R3) then
     R=R1-R2/2+R4/4;
    elseif R2>=math.max(R1, R3) then
     R=R2-R1/2+R4/4;
    else
     R=R3+R4/4;
    end
    if R==0 then
     D[period]=0;
    else
     local X=0.25*source.open[period]-1.5*source.close[period-1]+0.75*source.close[period]+0.5*source.open[period-1];
     D[period]=50*X*K/R;
    end 
	
	
    MA:update(mode);
    SI[period]=MA.DATA[period]; 
    if SI[period]>=SI[period-1] then
     SI:setColor(period, instance.parameters.UPclr);
    else
     SI:setColor(period, instance.parameters.DNclr);
    end
  
end

