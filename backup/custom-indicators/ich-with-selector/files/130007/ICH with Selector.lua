-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69173

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Ichimoku");
    indicator:description("Enables to quickly discern and filter  at a glance  the low-probability trading setups from those of higher probability.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
	
	indicator.parameters:addGroup("Selector");  
    indicator.parameters:addBoolean("Show_SL", "Show Tenkan-sen Line", "", false);
	indicator.parameters:addBoolean("Show_TL", "Show Kijun-sen Line", "", true);
	indicator.parameters:addBoolean("Show_CS", "Show Chinkou Span Line", "", false);
	indicator.parameters:addBoolean("Show_SA", "Show Cloud", "", false);
 
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("X", "Tenkan-sen period","", 9, 1, 10000);
    indicator.parameters:addInteger("Y", "Kijun-sen period","", 26, 1, 10000);
    indicator.parameters:addInteger("Z","Senkou Span B period","", 52, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrTS", "Tenkan-sen Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthSL", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSL","Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrKS", "Kijun-sen Line Color","", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthTL", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleTL", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrCS", "Chinkou Span Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthCS", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleCS", " Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCS", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSA", "Senkou span A Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSSA", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSSA", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSA", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSB", "Senkou span B Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSSB", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSSB", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSB", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addInteger("transp", "Cloud transparency %","", 80, 0, 100);
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Tenkan;
local Kijun;
local Senkou;

local firstPeriod;
local source = nil;

local csFirst = nil;
local slFirst = nil;
local tlFirst = nil;
local saFirst = nil;
local sbFirst = nil;
local chFirst = nil;

-- Streams block
local SL = nil;
local TL = nil;
local CS = nil;
local SA = nil;
local SB = nil;
local SA1 = nil;
local SB2 = nil;
local clrSSA, clrSSB;
local Show_SA, Show_CS, Show_TL, Show_SL;


-- Routine
function Prepare(nameOnly)
    Tenkan = instance.parameters.X;
    Kijun = instance.parameters.Y;
    Senkou = instance.parameters.Z;
    source = instance.source;
	
   Show_SA = instance.parameters.Show_SA;
   Show_CS = instance.parameters.Show_CS;
   Show_TL = instance.parameters.Show_TL;
   Show_SL = instance.parameters.Show_SL;
	
    firstPeriod = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Tenkan .. ", " .. Kijun .. ", " .. Senkou .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	if Show_SL then
    SL = instance:addStream("SL", core.Line, name .. ".TL", "TL", instance.parameters.clrTS, firstPeriod + Tenkan - 1)
    SL:setWidth(instance.parameters.widthSL);
    SL:setStyle(instance.parameters.styleSL);
	else
	SL = instance:addInternalStream(  firstPeriod + Tenkan - 1,0);
	end
	
	if Show_TL then
    TL = instance:addStream("TL", core.Line, name .. ".KL", "KL", instance.parameters.clrKS, firstPeriod + Kijun - 1)
    TL:setWidth(instance.parameters.widthTL);
    TL:setStyle(instance.parameters.styleTL);
	else
	TL = instance:addInternalStream(firstPeriod + Kijun - 1,0);
	end
	
	if Show_CS then
    CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS, firstPeriod, -Kijun)
    CS:setWidth(instance.parameters.widthCS);
    CS:setStyle(instance.parameters.styleCS);	
	else
	CS = instance:addInternalStream( firstPeriod, -Kijun);
	end
	

	if Show_SA then
    SA = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrSSA, math.max(SL:first(), TL:first()), Kijun)
    SA:setWidth(instance.parameters.widthSSA);
    SA:setStyle(instance.parameters.styleSSA);
    SB = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrSSB, firstPeriod + Senkou - 1, Kijun)
    SB:setWidth(instance.parameters.widthSSB);
    SB:setStyle(instance.parameters.styleSSB);
	else
	SA = instance:addInternalStream( firstPeriod + Senkou - 1, Kijun);
	SB = instance:addInternalStream( firstPeriod + Senkou - 1, Kijun);
	end
	

    csFirst = CS:first() + Kijun;
    slFirst = SL:first();
    tlFirst = TL:first();
    saFirst = SA:first();
    sbFirst = SB:first();

    chFirst = math.max(saFirst, sbFirst);
    SA1 = instance:addInternalStream(chFirst, Kijun);
    SB1 = instance:addInternalStream(chFirst, Kijun);
	
	if Show_SA then
    instance:createChannelGroup("SA-SB", "SA-SB", SA1, SB1, instance.parameters.clrSSA, 100 - instance.parameters.transp);
	end
    clrSSA = instance.parameters.clrSSA;
    clrSSB = instance.parameters.clrSSB;
	
end





 function Update(period)

  if (period < chFirst) then
	return;
	end
 
  Calculation(period);
   
 end
 
   
 
function Calculation(period)
    if (period < csFirst) then
	return;
	end
        CS[period - Kijun] = source.close[period];
     

    local p, hh, ll;

    if (period < slFirst) then
	return;
	end
        ll, hh = mathex.minmax(source, period - Tenkan + 1, period);
        SL[period] = (hh + ll) / 2;
    
    if (period < tlFirst) then
	return;
	end
	
        ll, hh = mathex.minmax(source, period - Kijun + 1, period);
        TL[period] = (hh + ll) / 2;
     

    local p = period + Kijun;

    if (period < saFirst) then
	return;
	end
        SA[p] = (SL[period] + TL[period]) / 2;
   

    if (period < sbFirst) then
	return;
	end
	
        ll, hh = mathex.minmax(source, period - Senkou + 1, period);
        SB[p] = (hh + ll) / 2;
     

    if (period < chFirst) then
	return;
	end
        SA1[p] = SA[p];
        SB1[p] = SB[p];
        if (SA[p] > SB[p]) then
            SA1:setColor(p, clrSSB);
        else
            SA1:setColor(p, clrSSA);
        end
    
end


