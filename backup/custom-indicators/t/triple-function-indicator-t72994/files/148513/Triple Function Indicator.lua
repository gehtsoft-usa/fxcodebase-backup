-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72994 

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
    indicator:name("Triple Function Indicator");
    indicator:description("Triple Function Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("SMI Calculation");
    indicator.parameters:addInteger("Period_Q", "Period_Q", "Period_Q", 14);
    indicator.parameters:addInteger("Period_R", "Period_R", "Period_R", 3);
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
	
    indicator.parameters:addGroup("CCI Calculation");
    indicator.parameters:addInteger("CCI", "Period", "Period", 17);
 
    indicator.parameters:addGroup("RSI Calculation");
    indicator.parameters:addInteger("RSI", "Period", "Period", 5);
	

    indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("color1", "Line Color", "Line Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
 
    indicator.parameters:addGroup("Levels");	 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		 
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
	
    SMI = instance:addInternalStream(0, 0);	
	
    RSI = core.indicators:create("RSI", source.close, instance.parameters.RSI);
    CCI = core.indicators:create("CCI", source, instance.parameters.CCI);	

    Line = instance:addStream("Line", core.Line, name .. ".Line", "Line", instance.parameters.color1, math.max(SM_MA_S.DATA:first(),HQ_MA_S.DATA:first()));
	Line:setWidth(instance.parameters.width1);
    Line:setStyle(instance.parameters.style1);
	Line:setPrecision (2);		
	
	Line:addLevel(math.sin(math.atan(1)), instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Line:addLevel(math.sin(math.atan(-1)), instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	 
   
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
     RSI:update(mode);	 
     CCI:update(mode);		 
	 
	 if period <= first+Period_Q+Period_R+Period_S then 
	 return;
	end
	
	 if period <= first+instance.parameters.RSI
	 or period <= first+instance.parameters.CCI
	 then 
	 return;
	end	
	 
    SMI[period] =100.*SM_MA_S.DATA[period]/(0.5*HQ_MA_S.DATA[period]);
	
	 
	local Sum =0;
	
    if SMI[period]> 40 then
	Sum=Sum+1;
	elseif SMI[period]<-40 then
	Sum=Sum-1;	
	end
	
	
    if CCI.DATA[period]> 100 then
	Sum=Sum+1;
	elseif CCI.DATA[period]<-100 then
	Sum=Sum-1;	
	end	
	
	
    if RSI.DATA[period]> 70 then
	Sum=Sum+1;
	elseif RSI.DATA[period]<-30 then
	Sum=Sum-1;	
	end	
	
	Line[period]=math.sin(math.atan(Sum));
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