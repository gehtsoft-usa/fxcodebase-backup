-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60364
-- Id: 11235

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
    indicator:name("iAnchMom oscillator");
    indicator:description("iAnchMom oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SMA_Period", "SMA period", "", 34);
    indicator.parameters:addInteger("EMA_Period", "EMA period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Positive Up color", "Positive Up color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Positive Dn color", "Positive Dn color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Negative Up color", "Negative Up color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clr4", "Negative Dn color", "Negative Dn color", core.rgb(255, 0, 255));
end

local first;
local source = nil;
local SMA_Period;
local EMA_Period;
local SMA, EMA;
local iAnchMom=nil;

function Prepare(nameOnly)
    source = instance.source;
    SMA_Period=instance.parameters.SMA_Period;
    EMA_Period=instance.parameters.EMA_Period;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.SMA_Period .. ", " .. instance.parameters.EMA_Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SMA = core.indicators:create("MVA", source, SMA_Period);
    EMA = core.indicators:create("EMA", source, EMA_Period);
	
	 first = math.max(SMA.DATA:first(),EMA.DATA:first());
    iAnchMom = instance:addStream("iAnchMom", core.Bar, name .. ".iAnchMom", "iAnchMom", instance.parameters.clr1, first);
	
	iAnchMom:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    SMA:update(mode);
    EMA:update(mode);
    if SMA.DATA[period]~=0 then
     iAnchMom[period]=100*(EMA.DATA[period]/SMA.DATA[period]-1);
    else
     iAnchMom[period]=nil;
    end 
    if iAnchMom[period]>0 then
     if iAnchMom[period]>iAnchMom[period-1] then
      iAnchMom:setColor(period, instance.parameters.clr1);
     else
      iAnchMom:setColor(period, instance.parameters.clr2);
     end
    else
     if iAnchMom[period]>iAnchMom[period-1] then
      iAnchMom:setColor(period, instance.parameters.clr3);
     else
      iAnchMom:setColor(period, instance.parameters.clr4);
     end
    end
  
end

