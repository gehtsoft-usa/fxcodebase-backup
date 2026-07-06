-- Id: 4585
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6487

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bands fill indicator");
    indicator:description("Bands fill indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 10000);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2.0, 0.0001, 1000.0);

    indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Show", "Show Cental Line", "", true);
	indicator.parameters:addBoolean("ShowTop", "Show Top Line", "", true);
	indicator.parameters:addBoolean("ShowBottom", "Show Bottom Line", "", true);
	
    indicator.parameters:addColor("TopClr", "Top line color", "Top line color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("BottomClr", "Bottom line color", "Bottom line color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("MiddleClr", "Middle line color", "Middle line color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("UPClr", "UP Color", "UP Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNClr", "DN Color", "DN Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("NEClr", "NE Color", "NE Color", core.rgb(255, 255, 128));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
end

local first;
local source = nil;
local Period;
local Deviation;
local BB;
local BB_Top=nil;
local BB_Bottom=nil;
local BB_Middle=nil;
local hStream=nil;
local lStream=nil;
local Trigger=nil;
local Show;
function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
	Show=instance.parameters.Show;
    Deviation=instance.parameters.Deviation;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    BB = core.indicators:create("BB", source, Period, Deviation);
	first = BB.DATA:first();
	
    hStream=instance:addInternalStream(first, 0);
    lStream=instance:addInternalStream(first, 0);
    Trigger=instance:addInternalStream(first, 0);
	
	if instance.parameters.ShowTop then
    BB_Top = instance:addStream("BB_Top", core.Line, name .. ".BB_Top", "BB_Top", instance.parameters.TopClr, first);
	BB_Top:setWidth(instance.parameters.width1);
    BB_Top:setStyle(instance.parameters.style1);
	else
	BB_Top = instance:addStream("BB_Top", core.Line, name .. ".BB_Top", "BB_Top", instance.parameters.TopClr, first);
	BB_Top:setStyle(core.LINE_NONE );
	end
	
	if instance.parameters.ShowBottom then
    BB_Bottom = instance:addStream("BB_Bottom", core.Line, name .. ".BB_Bottom", "BB_Bottom", instance.parameters.BottomClr, first);
	BB_Bottom:setWidth(instance.parameters.width2);
    BB_Bottom:setStyle(instance.parameters.style2);
	else
	BB_Bottom = instance:addStream("BB_Bottom", core.Line, name .. ".BB_Bottom", "BB_Bottom", instance.parameters.BottomClr, first);
	BB_Bottom:setStyle(core.LINE_NONE );
	end
	
	
	if Show then
    BB_Middle = instance:addStream("BB_Middle", core.Line, name .. ".BB_Middle", "BB_Middle", instance.parameters.MiddleClr, first);
	BB_Middle:setWidth(instance.parameters.width3);
    BB_Middle:setStyle(instance.parameters.style3);
	else
	BB_Middle = instance:addStream("BB_Middle", core.Line, name .. ".BB_Middle", "BB_Middle", instance.parameters.MiddleClr, first);
	BB_Middle:setStyle(core.LINE_NONE );
	end
    instance:createChannelGroup("BBGroup","BB" , hStream, lStream, instance.parameters.UPClr, 100-instance.parameters.Transparency);
	
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    BB:update(mode);
    BB_Top[period]=BB.TL[period];
    BB_Bottom[period]=BB.BL[period];
    BB_Middle[period]=BB.AL[period];
    Trigger[period]=Trigger[period-1];
    if Trigger[period]==1 and source[period]<BB_Middle[period] then
     Trigger[period]=0;
    elseif Trigger[period]==-1 and source[period]>BB_Middle[period] then
     Trigger[period]=0; 
    end
    if source[period]>=BB_Top[period] then
     Trigger[period]=1;
    elseif source[period]<=BB_Bottom[period] then
     Trigger[period]=-1; 
    end
    hStream[period]=BB_Top[period];
    lStream[period]=BB_Bottom[period];
    if Trigger[period]==1 then
     hStream:setColor(period,instance.parameters.UPClr);
    elseif Trigger[period]==-1 then
     hStream:setColor(period,instance.parameters.DNClr);
    else
     hStream:setColor(period,instance.parameters.NEClr);
    end
 
end

