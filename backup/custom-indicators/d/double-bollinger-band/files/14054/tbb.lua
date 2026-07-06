-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6008

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Triple Bollinger Bands");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bollinger");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 1, 10000);
    indicator.parameters:addDouble("D1", "Deviation for inner band", "", 1.0, 0.00001, 10000);
    indicator.parameters:addDouble("D2", "Deviation for mid band", "", 2.0, 0.00001, 10000);
    indicator.parameters:addDouble("D3", "Deviation for outer band", "", 3.0, 0.00001, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("CS", "Midline Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("CS", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("CW", "Midline Width", "", 1, 1, 5);
    indicator.parameters:addColor("CC", "Midline Color", "", core.rgb(255, 0, 255));

    indicator.parameters:addInteger("IS", "Inner Band Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("IS", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("IW", "Inner Band Width", "", 1, 1, 5);
    indicator.parameters:addColor("IC", "Inner Band Color", "", core.rgb(127, 0, 0));

    indicator.parameters:addInteger("MS", "Mid Band Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MS", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("MW", "Mid Band Width", "", 1, 1, 5);
    indicator.parameters:addColor("MC", "Mid Band Color", "", core.rgb(255, 128, 64));
    
    
    indicator.parameters:addInteger("OS", "Outer Band Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("OS", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("OW", "Outer Band Width", "", 1, 1, 5);
    indicator.parameters:addColor("OC", "Outer Band Color", "", core.rgb(255, 128, 64));

    indicator.parameters:addBoolean("HF", "Mid Area Between Bands", "", true);
    indicator.parameters:addColor("HC", "Mid Area Color", "", core.rgb(255, 255, 0)); 

    indicator.parameters:addColor("HC1", "Other Area Color", "", core.rgb(255, 255, 0));
    
    indicator.parameters:addInteger("HT", "Highlight Area Trasnsparency", "0 - opaque, 100 - transparent", 80, 0, 100);
end

local N, D1, D2;
local first;
local source;
local M, OU, OD, IU, ID, OU1, OD1, IU1, ID1;
local HF;
local MU1, MD1;
local OU2, OD2;
local MU, MD;

function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.N .. "," ..  instance.parameters.D1 .. ","  .. instance.parameters.D2 .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    source = instance.source;
    N = instance.parameters.N;
    D1 = instance.parameters.D1;
    D2 = instance.parameters.D2;
    D3 = instance.parameters.D3;
    first = source:first() + N - 1;

    M = instance:addStream("Mid", core.Line, name .. ".Mid", "Mid", instance.parameters.CC, first);
    M:setStyle(instance.parameters.CS);
    M:setWidth(instance.parameters.CW);
    IU = instance:addStream("InUp", core.Line, name .. ".InUp", "InUp", instance.parameters.IC, first);
    IU:setStyle(instance.parameters.IS);
    IU:setWidth(instance.parameters.IW);
    ID = instance:addStream("InDn", core.Line, name .. ".InDn", "InDn", instance.parameters.IC, first);
    ID:setStyle(instance.parameters.IS);
    ID:setWidth(instance.parameters.IW);
    OU = instance:addStream("OutUp", core.Line, name .. ".OutUp", "OutUp", instance.parameters.OC, first);
    OU:setStyle(instance.parameters.OS);
    OU:setWidth(instance.parameters.OW);
    OD = instance:addStream("OutDn", core.Line, name .. ".OutDn", "OutDn", instance.parameters.OC, first);
    OD:setStyle(instance.parameters.OS);
    OD:setWidth(instance.parameters.OW);
    
    MU = instance:addStream("MidUp", core.Line, name .. ".MidUp", "MidUp", instance.parameters.MC, first);
    MU:setStyle(instance.parameters.MS);
    MU:setWidth(instance.parameters.MW);
    MD = instance:addStream("MidDn", core.Line, name .. ".MidDn", "MidDn", instance.parameters.MC, first);
    MD:setStyle(instance.parameters.MS);
    MD:setWidth(instance.parameters.MW);

    HF = instance.parameters.HF;

    if HF then
        IU1 = instance:addInternalStream(first, 0);        
        ID1 = instance:addInternalStream(first, 0);  
        MU1 = instance:addInternalStream(first, 0);        
        MD1 = instance:addInternalStream(first, 0);   	
        OU1 = instance:addInternalStream(first, 0);        
        OD1 = instance:addInternalStream(first, 0);
        OU2 = instance:addInternalStream(first, 0);        
        OD2 = instance:addInternalStream(first, 0);         
        instance:createChannelGroup("MU", "U", MU1, IU1, instance.parameters.HC, 100 - instance.parameters.HT);
        instance:createChannelGroup("MD", "D", ID1, MD1, instance.parameters.HC, 100 - instance.parameters.HT);
	
	instance:createChannelGroup("OU", "U", OU1, OU2, instance.parameters.HC1, 100 - instance.parameters.HT);
        instance:createChannelGroup("OD", "D",  OD1,  OD2, instance.parameters.HC1, 100 - instance.parameters.HT);
    end
end

function Update(period, mode)
    if period >= first then
        local m = core.avg(source, period - N + 1, period);
        local d = mathex.stdev(source, period - N + 1, period);

        M[period] = m;
        IU[period] = m + d * D1;
        ID[period] = m - d * D1;
	MU[period] = m + d * D2;
        MD[period] = m - d * D2;
        OU[period] = m + d * D3;
        OD[period] = m - d * D3;
        if HF then
            IU1[period] = m + d * D1;
            ID1[period] = m - d * D1;
	    MU1[period] = m + d * D2;
            MD1[period] = m - d * D2;
	    
            OU1[period] = m + d * D2;
            OD1[period] = m - d * D2;
	    
	    OU2[period] = m + d * D3;
            OD2[period] = m - d * D3;
        end
    end
end




