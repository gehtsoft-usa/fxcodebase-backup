-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10252
-- Id: 5347

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("KST&Bands indicator");
    indicator:description("KST&Bands indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    AddParam(1, "First", 9, 6);
    AddParam(2, "Second", 12, 6);
    AddParam(3, "Third", 18, 6);
    AddParam(4, "Fourth", 24, 9);
    indicator.parameters:addInteger("BB_Period", "Bands Period", "", 20);
    indicator.parameters:addDouble("BB_Deviation", "Bands Deviation", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("KST_Clr", "KST Color", "KST Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Bands_Clr", "Bands Color", "Bands Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Cross_Clr", "Cross Color", "Cross Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local KST_Ind;
local BB_Ind;
local KST=nil;
local Top_Band=nil;
local Bottom_Band=nil;
local Top_Cross=nil;
local Bottom_Cross=nil;

function AddParam(id, name, defROC, defMA)
    indicator.parameters:addInteger("ROC" .. id, name .. " ROC Periods", "", defROC, 2, 300);
    indicator.parameters:addInteger("MA" .. id, name .. " MA Periods", "The methods marked with (*) must be downloaded and installed", defMA, 1, 300);
    indicator.parameters:addString("MET" .. id, name .. " Method", "", "MVA");
    indicator.parameters:addStringAlternative("MET" .. id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MET" .. id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MET" .. id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MET" .. id, "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MET" .. id, "SMMA(*)", "", "SMMA");
    indicator.parameters:addStringAlternative("MET" .. id, "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MET" .. id, "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MET" .. id, "Wilders*", "", "WMA");
end


function Prepare(nameOnly)
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("KST") ~= nil, "Please, download and install KST.LUA indicator");    
	
    KST_Ind=core.indicators:create("KST", source, instance.parameters.ROC1, instance.parameters.MA1, instance.parameters.MET1, instance.parameters.ROC2, instance.parameters.MA2, instance.parameters.MET2, instance.parameters.ROC3, instance.parameters.MA3, instance.parameters.MET3, instance.parameters.ROC4, instance.parameters.MA4, instance.parameters.MET4, 2, "MVA");
    BB_Ind=core.indicators:create("BB", KST_Ind.KST, instance.parameters.BB_Period, instance.parameters.BB_Deviation);
    
	first = math.max(BB_Ind.DATA:first(), KST_Ind.DATA:first());
	
	KST = instance:addStream("KST", core.Line, name .. ".KST", "KST", instance.parameters.KST_Clr, first);
    KST:setPrecision(math.max(2, instance.source:getPrecision()));
    Top_Band = instance:addStream("Top_Band", core.Line, name .. ".Top_Band", "Top_Band", instance.parameters.Bands_Clr, first);
    Top_Band:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom_Band = instance:addStream("Bottom_Band", core.Line, name .. ".Bottom_Band", "Bottom_Band", instance.parameters.Bands_Clr, first);
    Bottom_Band:setPrecision(math.max(2, instance.source:getPrecision()));
    KST:setWidth(instance.parameters.widthLinReg);
    KST:setStyle(instance.parameters.styleLinReg);
    Top_Band:setWidth(instance.parameters.widthLinReg);
    Top_Band:setStyle(instance.parameters.styleLinReg);
    Bottom_Band:setWidth(instance.parameters.widthLinReg);
    Bottom_Band:setStyle(instance.parameters.styleLinReg);
    Top_Cross = instance:addStream("Top_Cross", core.Dot, name .. ".Top_Cross", "Top_Cross", instance.parameters.Cross_Clr, first);
    Top_Cross:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom_Cross = instance:addStream("Bottom_Cross", core.Dot, name .. ".Bottom_Cross", "Bottom_Cross", instance.parameters.Cross_Clr, first);
    Bottom_Cross:setPrecision(math.max(2, instance.source:getPrecision()));
    Top_Cross:setWidth(instance.parameters.DotSize);
    Bottom_Cross:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    KST_Ind:update(mode);
    BB_Ind:update(mode);
    KST[period]=KST_Ind.KST[period];
    Top_Band[period]=BB_Ind.TL[period];
    Bottom_Band[period]=BB_Ind.BL[period];
    if (KST[period-1]-Top_Band[period-1])*(KST[period]-Top_Band[period])<0 then
     Top_Cross[period]=KST[period];
    end
    if (KST[period-1]-Bottom_Band[period-1])*(KST[period]-Bottom_Band[period])<0 then
     Bottom_Cross[period]=KST[period];
    end
   
end

