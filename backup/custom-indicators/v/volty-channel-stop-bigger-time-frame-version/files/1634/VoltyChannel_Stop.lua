-- Id: 551
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=893

--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
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


-- The original indicator VoltyChannel_Stop_v2.1.mq4
--  Copyright � 2007, TrendLaboratory
--  http://finance.groups.yahoo.com/group/TrendLaboratory
--  E-mail: igorad2003@yahoo.co.uk
-- v2.1. Modified by
--  MODIFIED BY AVERY T. HORTON, JR. AKA THERUMPLEDONE@GMAIL.COM
-- ---------------------------------------------------------------------
-- This port to lua is made by http://fxcodebase.com team.
-- ---------------------------------------------------------------------
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Volty Channel Stop");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("MA_N", "Moving Average Period", "", 1);
    indicator.parameters:addString("MA_M", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA_M", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_M", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_M", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_M", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_M", "Wilders*", "", "WMA");
    indicator.parameters:addInteger("ATR_N", "ATR period", "", 10);
    indicator.parameters:addDouble("VF", "Volatility's Factor or Multiplier", "", 4);
    indicator.parameters:addInteger("OF", "Offset factor", "", 0);
    indicator.parameters:addString("P", "Price", "The price to the indicator apply to", "C");
    indicator.parameters:addStringAlternative("P", "Open", "", "O");
    indicator.parameters:addStringAlternative("P", "High", "", "H");
    indicator.parameters:addStringAlternative("P", "Low", "", "L");
    indicator.parameters:addStringAlternative("P", "Close", "", "C");
    indicator.parameters:addStringAlternative("P", "Median", "", "M");
    indicator.parameters:addStringAlternative("P", "Typical", "", "T");
    indicator.parameters:addStringAlternative("P", "Weighted", "", "W");
    indicator.parameters:addBoolean("HiLoE", "Use High/Low envelope", "", false);
    indicator.parameters:addBoolean("HiLoB", "Hi/Lo Break", "", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpBuffer_color", "Color of UpBuffer", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnBuffer_color", "Color of DnBuffer", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("UpSignal_color", "Color of UpSignal", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnSignal_color", "Color of DnSignal", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Size", "", 10);
	
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local MA_N;
local MA_M;
local ATR_N;
local VF;
local OF;
local P;
local HiLoE;
local HiLoB;

local first;
local source = nil;

-- Streams block
local UpBuffer = nil;
local DnBuffer = nil;
local UpSignal = nil;
local DnSignal = nil;
local SMin = nil;
local SMax = nil;
local Trend = nil;
local BPRICE;
local SPRICE;
local ATR;
local Size;
-- Routine
function Prepare(nameOnly)  
    MA_N = instance.parameters.MA_N;
    MA_M = instance.parameters.MA_M;
    ATR_N = instance.parameters.ATR_N;
    VF = instance.parameters.VF;
    OF = instance.parameters.OF;
    P = instance.parameters.P;
    HiLoE = instance.parameters.HiLoE;
    HiLoB = instance.parameters.HiLoB;
	
	Size = instance.parameters.Size;
    source = instance.source;

    local bsrc, ssrc;

    if HiLoE then
        bsrc = source.high;
        ssrc = source.low;
    else
        if P == "O" then
            bsrc = source.open;
            ssrc = source.open;
        elseif P == "H" then
            bsrc = source.high;
            ssrc = source.high;
        elseif P == "L" then
            bsrc = source.low;
            ssrc = source.low;
        elseif P == "C" then
            bsrc = source.close;
            ssrc = source.close;
        elseif P == "M" then
            bsrc = source.median;
            ssrc = source.median;
        elseif P == "T" then
            bsrc = source.typical;
            ssrc = source.typical;
        elseif P == "W" then
            bsrc = source.weighted;
            ssrc = source.weighted;
        end
    end
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. MA_N .. ", " .. MA_M .. ", " .. ATR_N .. ", " .. VF .. ", " .. OF .. ", " .. P .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator(MA_M) ~= nil, MA_M .. " indicator must be installed");
    BPRICE = core.indicators:create(MA_M, bsrc, MA_N);
    SPRICE = core.indicators:create(MA_M, ssrc, MA_N);
    ATR = core.indicators:create("ATR", source, ATR_N);

    first = source:first() + MA_N + ATR_N;

    
	
	
    UpBuffer = instance:addStream("UpBuffer", core.Line, name .. ".UpBuffer", "UpBuffer", instance.parameters.UpBuffer_color, first);
    DnBuffer = instance:addStream("DnBuffer", core.Line, name .. ".DnBuffer", "DnBuffer", instance.parameters.DnBuffer_color, first);
	
	
	UpBuffer:setWidth(instance.parameters.width);
    UpBuffer:setStyle(instance.parameters.style);		
	DnBuffer:setWidth(instance.parameters.width);
    DnBuffer:setStyle(instance.parameters.style);
		
    UpSignal = instance:createTextOutput ("UpSignal", "UpSignal", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.UpSignal_color, 0);
    DnSignal = instance:createTextOutput ("DnSignal", "DnSignal", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.DnSignal_color, 0);
    SMin = instance:addInternalStream(0, 0);
    SMax = instance:addInternalStream(0, 0);
    Trend = instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
function Update(period, mode)
    BPRICE:update(mode);
    SPRICE:update(mode);
    ATR:update(mode);
    if period >= first then
        local bprice, sprice, atr;
        bprice = BPRICE.DATA[period];
        sprice = SPRICE.DATA[period];
        atr = ATR.DATA[period];

        SMax[period] = bprice + VF * atr;
        SMin[period] = sprice - VF * atr;
        Trend[period] = Trend[period - 1];
        if (HiLoB) then
            if source.high[period] > SMax[period - 1] then
                Trend[period] = 1;
            end
            if source.low[period] < SMin[period - 1] then
                Trend[period] = -1;
            end
        else
            if bprice > SMax[period - 1] then
                Trend[period] = 1;
            end
            if sprice < SMin[period - 1] then
                Trend[period] = -1;
            end
        end

        if Trend[period] > 0 then
            if SMin[period] < SMin[period - 1] then
                SMin[period] = SMin[period - 1];
            end
            UpBuffer[period] = SMin[period] - (OF - 1) * atr;
            if UpBuffer[period] < UpBuffer[period - 1] and UpBuffer:hasData(period - 1)  then
                UpBuffer[period] = UpBuffer[period - 1];
            end
            if Trend[period] ~= Trend[period - 1] and Trend[period - 1] ~= 0 then
                UpSignal:set(period, UpBuffer[period], "\225");
            end
        elseif Trend[period] < 0 then
            if SMax[period] > SMax[period - 1] then
                SMax[period] = SMax[period - 1];
            end
            DnBuffer[period] = SMax[period] + (OF - 1) * atr;
            if DnBuffer[period] > DnBuffer[period - 1] and DnBuffer:hasData(period - 1) then
                DnBuffer[period] = DnBuffer[period - 1];
            end
            if Trend[period] ~= Trend[period - 1] and Trend[period - 1] ~= 0 then
                DnSignal:set(period, DnBuffer[period], "\226");
            end
        end
    else
        Trend[period] = 0;
    end
end

