-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72992

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


function Init()
    indicator:name("Zex-Indicator");
    indicator:description("Zex-Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("SMI Calculation");
    indicator.parameters:addInteger("Period_Q", "Period_Q", "Period_Q", 12);
    indicator.parameters:addInteger("Period_R", "Period_R", "Period_R", 6);
    indicator.parameters:addInteger("Period_S", "Period_S", "Period_S", 5); 
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("TMA Calculation");
    indicator.parameters:addInteger("Period1", "Period", "Period", 5);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");	

    indicator.parameters:addGroup("SMI Style");
    indicator.parameters:addColor("DATAclr", "Color of SMI line", "Color of SMI line", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addGroup("Signal Style");
    indicator.parameters:addColor("color2", "Color of Signal line", "Color of Signal line", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Histogram Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));	 
end

local first;
local source = nil;
local Period_Q;
local Period_R;
local Period_S; 
local HQ;
local SM;
local HQ_MA_R;
local HQ_MA_S;
local SM_MA_R;
local SM_MA_S;
local sig;
local Method;
local SignalBuff;
local DataBuff;

function Prepare(nameOnly)
    source = instance.source;
	Method=instance.parameters.Method;
    Period_Q=instance.parameters.Period_Q;
    Period_R=instance.parameters.Period_R;
    Period_S=instance.parameters.Period_S; 
	Period1=instance.parameters.Period1;
	Method1=instance.parameters.Method1;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period_Q .. ", " .. instance.parameters.Period_R .. ", " .. instance.parameters.Period_S  
	.. ", " .. instance.parameters.Method.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    HQ = instance:addInternalStream(0, 0);
    SM = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    HQ_MA_R = core.indicators:create(Method, HQ, Period_R);
    HQ_MA_S = core.indicators:create(Method, HQ_MA_R.DATA, Period_S);
    SM_MA_R = core.indicators:create(Method, SM, Period_R);
    SM_MA_S = core.indicators:create(Method, SM_MA_R.DATA, Period_S);

    SMI = instance:addStream("SMI", core.Line, name .. ".SMI", "SMI", instance.parameters.DATAclr, math.max(SM_MA_S.DATA:first(),HQ_MA_S.DATA:first()));
	SMI:setWidth(instance.parameters.width1);
    SMI:setStyle(instance.parameters.style1);
	SMI:setPrecision (2);		
	
	
	
    MVA = core.indicators:create(Method1, SMI, Period1);		


    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.color2, math.max(SM_MA_S.DATA:first(),HQ_MA_S.DATA:first()));
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
	Signal:setPrecision (2);	
	
    ZEX = instance:addStream("ZEX", core.Bar, name .. ".ZEX", "ZEX", instance.parameters.Up, math.max(SM_MA_S.DATA:first(),HQ_MA_S.DATA:first())); 
	ZEX:setPrecision (2);	
	
	
 
	
	
   
end

function Update(period, mode)
    if period<=first+Period_Q then
	return;
	end
	
     HQ[period]=core.max(source.high,core.rangeTo(period,Period_Q))-core.min(source.low,core.rangeTo(period,Period_Q));	
     SM[period]=source.close[period]-(core.max(source.high,core.rangeTo(period,Period_Q))+core.min(source.low,core.rangeTo(period,Period_Q)))/2.;
	 
	
     HQ_MA_R:update(mode);
	 HQ_MA_S:update(mode);  
	 SM_MA_R:update(mode);        
     SM_MA_S:update(mode);
	 
	 if period <= first+Period_Q+Period_R+Period_S then 
	 return;
	end
	 
    SMI[period] =100.*SM_MA_S.DATA[period]/(0.5*HQ_MA_S.DATA[period]);
	
	
    MVA:update(mode);
	
    if period<= first+Period_Q+Period_R+Period_S+Period1*2 then
	return;
	end	
	Signal[period]=mathex.sum(MVA.DATA, period-Period1+1, period) /Period1;
	
    ZEX[period]= 1.682*(SMI[period]-Signal[period])
	
	if ZEX[period]> 0 then
	ZEX:setColor(period,  instance.parameters.Up);	
	else
	ZEX:setColor(period,  instance.parameters.Down);	
    end	
    
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+