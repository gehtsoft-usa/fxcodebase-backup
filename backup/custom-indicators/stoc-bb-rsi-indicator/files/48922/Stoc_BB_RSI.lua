-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27881
-- Id: 8196

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
    indicator:name("Stoc+BB+RSI indicator");
    indicator:description("Stoc+BB+RSI indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("STO_KPeriod", "K period of stochastic", "", 5);
    indicator.parameters:addInteger("STO_DPeriod", "D period of stochastic", "", 3);
    indicator.parameters:addInteger("STO_Slowing", "Slowing of stochastic", "", 3);
    indicator.parameters:addString("STO_K", "STO_K", "Smoothing type for %K", "MVA");
    indicator.parameters:addStringAlternative("STO_K", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("STO_K", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("STO_K", "Fast smoothed", "", "FS");
    indicator.parameters:addString("STO_D", "STO_D", "Smoothing type for %D", "MVA");
    indicator.parameters:addStringAlternative("STO_D", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("STO_D", "EMA", "", "EMA");
    indicator.parameters:addInteger("BB_Period", "Period of Band", "", 10);
    indicator.parameters:addDouble("BB_Deviation", "Deviation of Band", "", 1);
    indicator.parameters:addInteger("RSI_Period", "Period of RSI", "", 8);
    indicator.parameters:addString("RSI_Price", "Price of RSI", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "close", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("RSI_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("RSI_Price", "low", "", "low");
    indicator.parameters:addStringAlternative("RSI_Price", "median", "", "median");
    indicator.parameters:addStringAlternative("RSI_Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("RSI_Price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("STO_Clr", "Stochastic Color", "Stochastic Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("RSI_Clr", "RSI Color", "RSI Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("STO_Signal_Clr", "Stochastic signal Color", "Stochastic signal Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("STO_Sigma_Clr", "Stochastic sigma Color", "Stochastic sigma Color", core.rgb(255, 255, 0));
end

local first;
local source = nil;
local STO_KPeriod;
local STO_DPeriod;
local STO_Slowing;
local STO_K;
local STO_D;
local BB_Period;
local BB_Deviation;
local RSI_Period;
local RSI_Price;
local Stoch;
local RSI;
local MVA;
local StdDev;

local STO_Buff=nil;
local RSI_Buff=nil;
local STO_Signal_Buff=nil;
local STO_Sigma1_Buff=nil;
local STO_Sigma2_Buff=nil;

function Prepare(nameOnly)
    source = instance.source;
    STO_KPeriod=instance.parameters.STO_KPeriod;
    STO_DPeriod=instance.parameters.STO_DPeriod;
    STO_Slowing=instance.parameters.STO_Slowing;
    STO_K=instance.parameters.STO_K;
    STO_D=instance.parameters.STO_D;
    BB_Period=instance.parameters.BB_Period;
    BB_Deviation=instance.parameters.BB_Deviation;
    RSI_Period=instance.parameters.RSI_Period;
    RSI_Price=instance.parameters.RSI_Price;
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.STO_KPeriod .. ", " .. instance.parameters.STO_DPeriod .. ", " .. instance.parameters.STO_Slowing .. ", " .. instance.parameters.STO_K .. ", " .. instance.parameters.STO_D .. ", " .. instance.parameters.BB_Period .. ", " .. instance.parameters.BB_Deviation .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.RSI_Price .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");  
	
    Stoch = core.indicators:create("STOCHASTIC", source, STO_KPeriod, STO_DPeriod, STO_Slowing, STO_K, STO_D);
    
    RSI = core.indicators:create("RSI", source[RSI_Price], RSI_Period);
 
    MVA = core.indicators:create("MVA", RSI.DATA, BB_Period);
    StdDev = core.indicators:create("STDDEV", Stoch.K, BB_Period);
	
    first = math.max(MVA.DATA:first(),StdDev.DATA:first() )
    STO_Buff = instance:addStream("STO", core.Line, name .. ".STO", "STO", instance.parameters.STO_Clr, Stoch.D:first());
    STO_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI_Buff = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSI_Clr, RSI.DATA:first() );
    RSI_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    STO_Signal_Buff = instance:addStream("STO_Signal", core.Line, name .. ".STO_Signal", "STO_Signal", instance.parameters.STO_Signal_Clr, math.max(BB_Period, MVA.DATA:first()));
    STO_Signal_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    STO_Sigma1_Buff = instance:addStream("Plus2Sigma", core.Line, name .. ".Plus2Sigma", "+2Sigma", instance.parameters.STO_Sigma_Clr, math.max(BB_Period, MVA.DATA:first()));
    STO_Sigma1_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    STO_Sigma2_Buff = instance:addStream("Minus2Sigma", core.Line, name .. ".Minus2Sigma", "-2Sigma", instance.parameters.STO_Sigma_Clr, math.max(BB_Period, MVA.DATA:first()));
    STO_Sigma2_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   
    Stoch:update(mode);
    RSI:update(mode);
    MVA:update(mode);
    StdDev:update(mode);
	 
	if period > Stoch.D:first()  then
    STO_Buff[period]=Stoch.K[period];
	end
	
	if period > RSI.DATA:first()  then
    RSI_Buff[period]=RSI.DATA[period];
	end
	
   if period > math.max(BB_Period, MVA.DATA:first())  then   
    STO_Signal_Buff[period]=MVA.DATA[period];
    STO_Sigma1_Buff[period]=MVA.DATA[period]+BB_Deviation*StdDev.DATA[period];
    STO_Sigma2_Buff[period]=MVA.DATA[period]-BB_Deviation*StdDev.DATA[period];
	end
   
end

