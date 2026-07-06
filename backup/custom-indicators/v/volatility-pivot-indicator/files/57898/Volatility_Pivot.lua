-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34059
-- Id: 8871

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
    indicator:name("Volatility Pivot indicator");
    indicator:description("Volatility Pivot indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "", 100);
    indicator.parameters:addInteger("MA_Period", "MA Period", "", 10);
    indicator.parameters:addDouble("ATR_Factor", "ATR factor", "", 3);
    indicator.parameters:addString("Mode", "Mode", "", "EMA");
    indicator.parameters:addStringAlternative("Mode", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Mode", "Delta price", "", "Delta price");
    indicator.parameters:addDouble("DeltaPrice", "Delta price", "", 30);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local ATR_Period;
local MA_Period;
local ATR_Factor;
local Mode;
local DeltaPrice;
local ATR;
local EMA;
local VP=nil;

function Prepare(nameOnly)
    source = instance.source;
    ATR_Period=instance.parameters.ATR_Period;
    MA_Period=instance.parameters.MA_Period;
    ATR_Factor=instance.parameters.ATR_Factor;
    Mode=instance.parameters.Mode;
    DeltaPrice=instance.parameters.DeltaPrice*source:pipSize();
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.ATR_Factor .. ", " .. instance.parameters.Mode .. ", " .. instance.parameters.DeltaPrice .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ATR=core.indicators:create("ATR", source, ATR_Period);
 
    if Mode=="EMA" then
     EMA=core.indicators:create("EMA", ATR.DATA, MA_Period);
    end
	
	 if Mode=="EMA" then
	 first = ATR.DATA:first();
	 else
	 first = EMA.DATA:first();
     end	
    VP = instance:addStream("VP", core.Line, name .. ".VP", "VP", instance.parameters.clr, first);
    VP:setWidth(instance.parameters.widthLinReg);
    VP:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
  
   
    ATR:update(mode);
	

   
    local DeltaStop;
    if Mode=="EMA" then
     EMA:update(mode);
	 
			if period<first then
		   return;
		   end
   
   
     DeltaStop=EMA.DATA[period]*ATR_Factor;
    else
	
	       if period<first then
		   return;
		   end
      
     DeltaStop=DeltaPrice;
    end
 
	
    if source.close[period]==VP[period-1] then
     VP[period]=VP[period-1];
    elseif source.close[period-1]<VP[period-1] and source.close[period]<VP[period-1] then
     VP[period]=math.min(VP[period-1], source.close[period]+DeltaStop);
    elseif source.close[period-1]>VP[period-1] and source.close[period]>VP[period-1] then
     VP[period]=math.max(VP[period-1], source.close[period]-DeltaStop);
    elseif source.close[period]>VP[period-1] then
     VP[period]=source.close[period]-DeltaStop;
    else
     VP[period]=source.close[period]+DeltaStop;
    end

end

