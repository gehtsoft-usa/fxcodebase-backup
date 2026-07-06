
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2529

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
    indicator:name("NCandle indicator");
    indicator:description("NCandle indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "N", "", 10);
    indicator.parameters:addBoolean("IncludeCurrentBar", "Include current bar", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("HIGH", "Color for High", "Color for High", core.rgb(0,0,255));
    indicator.parameters:addColor("LOW", "Color for Low", "Color for Low", core.rgb(255,0,255));
    indicator.parameters:addColor("UP", "Color for UP", "Color for UP", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Color for DOWN", "Color for DOWN", core.rgb(255,0,0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 3, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local N;
local High;
local Low;
local hUP=nil;
local hDN=nil;
local lUP=nil;
local lDN=nil;

function Prepare(nameOnly) 
    source = instance.source;
    N=instance.parameters.N;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    High = instance:addStream("High", core.Line, name .. ".High", "High", instance.parameters.HIGH, 0);
    Low = instance:addStream("Low", core.Line, name .. ".Low", "Low", instance.parameters.LOW, 0);
    hUP=instance:addInternalStream(0, 0);
    hDN=instance:addInternalStream(0, 0);
    lUP=instance:addInternalStream(0, 0);
    lDN=instance:addInternalStream(0, 0);
    High:setWidth(instance.parameters.widthLinReg);
    High:setStyle(instance.parameters.styleLinReg);
    Low:setWidth(instance.parameters.widthLinReg);
    Low:setStyle(instance.parameters.styleLinReg);
    instance:createChannelGroup("UpGroup","Up" , hUP, hDN, instance.parameters.UP, 100-instance.parameters.Transparency);
    instance:createChannelGroup("DnGroup","Dn" , lUP, lDN, instance.parameters.DOWN, 100-instance.parameters.Transparency);
end

function Update(period, mode)
   if (period>source:size()-N) and (period>=first+N) then
    local MaxBar;
    if instance.parameters.IncludeCurrentBar then
     MaxBar=source:size()-1;
    else
     MaxBar=source:size()-2;
    end
	
	
    local Max=core.max(source.high,core.rangeTo(MaxBar,N));
    local Min=core.min(source.low,core.rangeTo(MaxBar,N));
    core.drawLine(High,core.range(MaxBar+1-N,period),Max,MaxBar+1-N,Max,period);
    core.drawLine(Low,core.range(MaxBar+1-N,period),Min,MaxBar+1-N,Min,period);
    High[MaxBar-N]=nil;
    Low[MaxBar-N]=nil;
    local Open=source.open[MaxBar+1-N];
    local Close=source.close[MaxBar];
    if Open>Close then
     core.drawLine(lUP,core.range(MaxBar+1-N,period),Open,MaxBar+1-N,Open,period);
     core.drawLine(lDN,core.range(MaxBar+1-N,period),Close,MaxBar+1-N,Close,period);
     core.drawLine(hUP,core.range(MaxBar+1-N,period),0,MaxBar+1-N,0,period);
     core.drawLine(hDN,core.range(MaxBar+1-N,period),0,MaxBar+1-N,0,period);
     lUP[MaxBar-N]=nil;
     lDN[MaxBar-N]=nil;
     hUP[MaxBar-N]=nil;
     hDN[MaxBar-N]=nil;
    else
     core.drawLine(hUP,core.range(MaxBar+1-N,period),Close,MaxBar+1-N,Close,period);
     core.drawLine(hDN,core.range(MaxBar+1-N,period),Open,MaxBar+1-N,Open,period);
     core.drawLine(lUP,core.range(MaxBar+1-N,period),0,MaxBar+1-N,0,period);
     core.drawLine(lDN,core.range(MaxBar+1-N,period),0,MaxBar+1-N,0,period);
     lUP[MaxBar-N]=nil;
     lDN[MaxBar-N]=nil;
     hUP[MaxBar-N]=nil;
     hDN[MaxBar-N]=nil;
    end
   else
    High[period]=nil;
    Low[period]=nil; 
   end
    
end

