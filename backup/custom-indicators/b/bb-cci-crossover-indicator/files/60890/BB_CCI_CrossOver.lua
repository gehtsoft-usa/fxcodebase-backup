-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36263
-- Id: 9093

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
    indicator:name("BB_CCI_CrossOver indicator");
    indicator:description("BB_CCI_CrossOver indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCI_Period", "CCI period", "", 21);
    indicator.parameters:addDouble("CCI_Min", "CCI Min", "", -80);
    indicator.parameters:addDouble("CCI_Max", "CCI Max", "", 80);
    indicator.parameters:addInteger("MM_Period", "MM period", "", 14);
    indicator.parameters:addInteger("BB_Period", "BB period", "", 21);
    indicator.parameters:addDouble("BB_Desvio", "BB desvio", "", 2);
    indicator.parameters:addInteger("Pip_Desvio_Max", "Pip desvio max", "", 10);
    indicator.parameters:addInteger("Pip_Desvio_Min", "Pip desvio min", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 10);
end

local first;
local source = nil;
local CCI_Period;
local CCI_Min;
local CCI_Max;
local MM_Period;
local BB_Period;
local BB_Desvio;
local Pip_Desvio_Max;
local Pip_Desvio_Min;
local UP=nil;
local DN=nil;
local CCI;
local ATR;
local BB;
local MM;

function Prepare(nameOnly)
    source = instance.source;
    CCI_Period=instance.parameters.CCI_Period;
    CCI_Min=instance.parameters.CCI_Min;
    CCI_Max=instance.parameters.CCI_Max;
    MM_Period=instance.parameters.MM_Period;
    BB_Period=instance.parameters.BB_Period;
    BB_Desvio=instance.parameters.BB_Desvio;
    Pip_Desvio_Max=instance.parameters.Pip_Desvio_Max*source:pipSize();
    Pip_Desvio_Min=instance.parameters.Pip_Desvio_Min*source:pipSize();
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CCI_Period .. ", " .. instance.parameters.CCI_Min .. ", " .. instance.parameters.CCI_Max .. ", " .. instance.parameters.MM_Period .. ", " .. instance.parameters.BB_Period .. ", " .. instance.parameters.BB_Desvio .. ", " .. instance.parameters.Pip_Desvio_Max .. ", " .. instance.parameters.Pip_Desvio_Min .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    CCI=core.indicators:create("CCI", source, CCI_Period);
    ATR=core.indicators:create("ATR", source, 10);
    BB=core.indicators:create("BB", source.weighted, BB_Period, BB_Desvio);
    MM=core.indicators:create("EMA", CCI.DATA, MM_Period);
	
	first = math.max(CCI.DATA:first(), ATR.DATA:first(), BB.DATA:first(), MM.DATA:first());
    UP = instance:createTextOutput ("UP", "UP", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.UPclr, 0);
    DN = instance:createTextOutput ("DN", "DN", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.DNclr, 0);
end

function Update(period, mode)
  
    CCI:update(mode);
    ATR:update(mode);
    BB:update(mode);
    MM:update(mode);
	
	 if period<first then
	 return;
	 end
	 
    local Range=ATR.DATA[period]*3/8;
    if CCI.DATA[period]>CCI_Max then
     if CCI.DATA[period]<MM.DATA[period] then
      if source.high[period]<=BB.TL[period] then
       if source.high[period-1]>source.high[period] and BB.TL[period]-source.high[period]<=Pip_Desvio_Max then
        DN:set(period, source.high[period]+Range, "\226");
       end
      elseif source.high[period-1]>source.high[period] then
       DN:set(period, source.high[period]+Range, "\226");
      end
     end
    end
    
    if CCI.DATA[period]<CCI_Min then
     if CCI.DATA[period]>MM.DATA[period] then
      if source.low[period]>=BB.BL[period] then
       if source.low[period-1]<source.low[period] and source.low[period]-BB.BL[period]<=Pip_Desvio_Min then
        UP:set(period, source.low[period]-Range, "\225");
       end
      elseif source.low[period-1]<source.low[period] then
       UP:set(period, source.low[period]-Range, "\225");
      end
     end
    end
 
end

