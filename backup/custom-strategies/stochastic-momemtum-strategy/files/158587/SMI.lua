-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=31&t=75707

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

function Init()
    indicator:name("SMI indicator");
    indicator:description("SMI indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period_Q", "Period_Q", "Period_Q", 2);
    indicator.parameters:addInteger("Period_R", "Period_R", "Period_R", 8);
    indicator.parameters:addInteger("Period_S", "Period_S", "Period_S", 5);
    indicator.parameters:addInteger("Period_Signal", "Period_Signal", "Period_Signal", 5);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DATAclr", "Color of DATA line", "Color of DATA line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNALclr", "Color of SIGNAL line", "Color of SIGNAL line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 40);
    indicator.parameters:addDouble("oversold","Oversold Level","", -40);
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
local Period_Signal;
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
    Period_Signal=instance.parameters.Period_Signal;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period_Q .. ", " .. instance.parameters.Period_R .. ", " .. instance.parameters.Period_S .. ", " .. instance.parameters.Period_Signal 
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
    DataBuff = instance:addStream("DataBuff", core.Line, name .. ".Data", "Data", instance.parameters.DATAclr, math.max(SM_MA_S.DATA:first(),HQ_MA_S.DATA:first()));
	DataBuff:setWidth(instance.parameters.width1);
    DataBuff:setStyle(instance.parameters.style1);
	DataBuff:setPrecision (2);	
	
	 sig = core.indicators:create("EMA", DataBuff, Period_Signal);
	 
	 
    SignalBuff = instance:addStream("SignalBuff", core.Line, name .. ".Signal", "Signal", instance.parameters.SIGNALclr, sig.DATA:first());
	SignalBuff:setWidth(instance.parameters.width2);
    SignalBuff:setStyle(instance.parameters.style2);
	SignalBuff:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	SignalBuff:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	SignalBuff:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	SignalBuff:setPrecision (2);	
   
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
	 
	 if period <= SM_MA_S.DATA:first()  or  period <= HQ_MA_S.DATA:first() then 
	 return;
	end
	 
     DataBuff[period]=100.*SM_MA_S.DATA[period]/(0.5*HQ_MA_S.DATA[period]);
	 
     sig:update(mode);
	 
	  if period <= sig.DATA:first()then 
	  return;
	  end
     SignalBuff[period]=sig.DATA[period];
    
end

-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=31&t=75707

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 