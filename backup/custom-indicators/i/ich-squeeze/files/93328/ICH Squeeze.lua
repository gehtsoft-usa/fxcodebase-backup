-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 11410

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("ICH Squeeze");
    indicator:description("ICH Squeeze");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");	

	
	indicator.parameters:addGroup("Ichimoku Calculation");	
	indicator.parameters:addInteger("TS", "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000);
    indicator.parameters:addInteger("KS", "Kijun-sen period", "Kijun-sen period", 26, 1, 1000);
    indicator.parameters:addInteger("SS", "Senkou Span B period", "Senkou Span B period", 52, 1, 1000);
	indicator.parameters:addInteger("FlatSE", "FlatSE", "FlatSE", 7);
	
	 indicator.parameters:addGroup("1. Buffer Style");
    indicator.parameters:addColor("Color1", " Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line Width ","", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	
    indicator.parameters:addGroup("2. Buffer Style");
    indicator.parameters:addColor("Color2", " Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line Width ","", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	
	indicator.parameters:addGroup("3. Buffer Style"); 
    indicator.parameters:addColor("Color3", " Line Color","", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width3", "Line Width ","", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
	
	
    indicator.parameters:addGroup("4. Buffer Style");
    indicator.parameters:addColor("Color4", " Line Color","", core.rgb(255, 0, 255));
    indicator.parameters:addInteger("width4", "Line Width ","", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addGroup("Cloud Style");
    indicator.parameters:addInteger("Transparency", "Transparency","", 80, 0, 100);
    indicator.parameters:addColor("Color", "Color","", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local TS, KS,SS;
local first;
local source = nil;
local ICH; 
local TenkanSen,KijunSen,SenkouSpanA,SenkouSpanB,ChinkouSpan;
local Buffer1, Buffer2;
local  maBuffer1, maBuffer2;
local  MABuffer1, MABuffer2;
local Color1, Color2, Color3, Color4;
local FlatSE;
local Top, Bottom;
local Transparency;
local Color;
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
	first=source:first();
	FlatSE = instance.parameters.FlatSE;
	KS = instance.parameters.KS;
	TS = instance.parameters.TS;
	SS = instance.parameters.SS;
	Color1 = instance.parameters.Color1;
	Color2 = instance.parameters.Color2;
	Color3 = instance.parameters.Color3;
	Color4 = instance.parameters.Color4;
	Transparency = instance.parameters.Transparency;
	Color= instance.parameters.Color;
	
    local name = profile:id() .. "(" .. source:name()   .. ", " .. tostring(KS) .. ", " .. tostring(TS) .. ", " .. tostring(SS).. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	ICH = core.indicators:create("ICH", source,  TS , KS , SS);
	TenkanSen= instance:addInternalStream(first,0);
    KijunSen = instance:addInternalStream(first,0);
	SenkouSpanA= instance:addInternalStream(first+KS,KS);
	SenkouSpanB= instance:addInternalStream(first+KS,KS);
	
	Top= instance:addInternalStream(first,0);	
	Bottom= instance:addInternalStream(first,0);	
	
	 instance:createChannelGroup("SA-SB", "SA-SB", Top, Bottom, Color, 100 - Transparency);
	
	
	Buffer1 =instance:addStream("Buffer1", core.Line, name .. ".Buffer1", "Buffer1", Color1,  first+KS)
	Buffer1:setWidth(instance.parameters.width1);
    Buffer1:setStyle(instance.parameters.style1);
	Buffer2= instance:addStream("Buffer2", core.Line, name .. ".Buffer2", "Buffer2", Color2,  first+KS, KS)
	Buffer2:setWidth(instance.parameters.width2);
    Buffer2:setStyle(instance.parameters.style2);
	
	maBuffer1= core.indicators:create("LWMA", Buffer1,  KS);
	maBuffer2= core.indicators:create("LWMA", Buffer1,  SS);
	
	MABuffer1 =instance:addStream("MABuffer1", core.Line, name .. ".MA of Buffer1", "Buffer1", Color3,  first+KS)
	MABuffer1:setWidth(instance.parameters.width3);
    MABuffer1:setStyle(instance.parameters.style3);
	MABuffer2= instance:addStream("MABuffer2", core.Line, name .. ".MA of Buffer2", "Buffer2", Color4,  first+KS)
	MABuffer2:setWidth(instance.parameters.width4);
    MABuffer2:setStyle(instance.parameters.style4);
	

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 	
	ICH:update(mode);	
	
    if period < first + KS then
	return;
	end
	
	TenkanSen[period]=ICH:getStream (0)[period];
    KijunSen[period]=ICH:getStream (1)[period];
	
	SenkouSpanA[period+KS]=ICH:getStream (3)[period+KS];
	SenkouSpanB[period+KS]=ICH:getStream (4)[period+KS];
	
	
	Buffer1[period]=(TenkanSen[period]+KijunSen[period]+SenkouSpanA[period]+SenkouSpanB[period])/4;
    Buffer2[period+KS]=(SenkouSpanA[period+KS]+SenkouSpanB[period+KS])/2;
	maBuffer1:update(mode);
	maBuffer2:update(mode);
	
	if period < maBuffer1.DATA:first() then
	return;
	end
	
	MABuffer1[period]=maBuffer1.DATA[period];
	
	if period < maBuffer2.DATA:first() then
	return;
	end	
	
	MABuffer2[period]=maBuffer2.DATA[period];
	
	
	 if(math.abs(((Buffer1[period]-MABuffer1[period])+(Buffer1[period]- MABuffer2[period])+(MABuffer1[period]-MABuffer2[period]))/3)<FlatSE*source:pipSize()) then   
     Top[period]=MABuffer1[period]+FlatSE*source:pipSize();
     Bottom[period]=MABuffer1[period]-FlatSE*source:pipSize();       
	 else
	 Top[period]=nil;
     Bottom[period]=nil;
     end

end

