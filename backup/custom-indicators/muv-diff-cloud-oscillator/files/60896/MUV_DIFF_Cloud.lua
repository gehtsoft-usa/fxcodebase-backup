-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36269
-- Id: 9101

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
    indicator:name("MUV_DIFF_Cloud oscillator");
    indicator:description("MUV_DIFF_Cloud oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA_Period", "MA period", "", 14);
    indicator.parameters:addInteger("Momentum", "Momentum", "", 1);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local MA_Period;
local Momentum;
local MA1;
local MA2;
local Pbuff=nil;
local Mbuff=nil;
local pipSize;

function Prepare(nameOnly)
    source = instance.source;
    MA_Period=instance.parameters.MA_Period;
    Momentum=instance.parameters.Momentum;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.Momentum .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
	assert(core.indicators:findIndicator("XMUV") ~= nil, "Please, download and install XMUV.LUA indicator");  
   
    MA1 = core.indicators:create("XMUV", source, "MVA", MA_Period);
    MA2 = core.indicators:create("XMUV", source, "EMA", MA_Period);
	
	first = MA1.DATA:first();
    Pbuff = instance:addStream("Pbuff", core.Line, name .. ".Pbuff", "Pbuff", instance.parameters.UPclr, first+Momentum );
    Pbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    Mbuff = instance:addStream("Mbuff", core.Line, name .. ".Mbuff", "Mbuff", instance.parameters.UPclr, first+Momentum );
    Mbuff:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createChannelGroup("TC","TC" , Pbuff, Mbuff, instance.parameters.UPclr, 100-instance.parameters.Transparency);
    pipSize=source:pipSize();
end

function Update(period, mode)
  
   
    MA1:update(mode);
    MA2:update(mode);
	
   if period<first+Momentum then
   return;
   end
   
   
    Pbuff[period]=(MA2.DATA[period]-MA2.DATA[period-Momentum])/pipSize;
    Mbuff[period]=(MA1.DATA[period]-MA1.DATA[period-Momentum])/pipSize;
    if Pbuff[period]>Mbuff[period] then
     Pbuff:setColor(period, instance.parameters.UPclr);
     Mbuff:setColor(period, instance.parameters.UPclr);
    else
     Pbuff:setColor(period, instance.parameters.DNclr);
     Mbuff:setColor(period, instance.parameters.DNclr);
    end
  
end

