-- Id: 1504
-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=2069


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
 

-- original indicator:
-- Traders Dynamic Index.mq4
-- Copyright � 2006, Dean Malone
-- www.compassfx.com


function Init()
    indicator:name("Traders Dynamic Index Indicator");
    indicator:description("This hybrid indicator is developed to assist traders in their ability to decipher and monitor market conditions related to trend direction, market strength, and market volatility.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("RSI_N", "RSI Periods", "Recommended values are in 8-25 range", 13, 2, 1000);
    indicator.parameters:addInteger("VB_N", "Volatility Band", "Number of periods to find volatility band. Recommended value is 20-40", 34, 2, 1000);
    indicator.parameters:addDouble("VB_W", "Volatility Band Width", "", 1.6185, 0, 100);

    indicator.parameters:addInteger("RSI_P_N", "RSI Price Line Periods", "", 2, 1, 1000);
    indicator.parameters:addString("RSI_P_M", "RSI Price Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("RSI_P_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "KAMA(Kaufman)", "", "KAMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "VIDYA", "VIDYA" , "VIDYA");
 


    indicator.parameters:addInteger("TS_N", "Trade Signal Line Periods", "", 7, 1, 1000);
    indicator.parameters:addString("TS_M", "Trade Signal Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TS_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TS_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("TS_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TS_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("TS_M", "KAMA(Kaufman)", "", "KAMA");
	 indicator.parameters:addStringAlternative("TS_M", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("TS_M", "VIDYA", "VIDYA" , "VIDYA");

    local colors = core.colors();

    indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("RSI_P_C", "RSI Price Line Color", "", colors.Green);
    indicator.parameters:addInteger("RSI_P_W", "RSI Price Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("RSI_P_S", "RSI Price Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI_P_S", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("TS_C", "Trade Signal Line Color", "", colors.Red);
    indicator.parameters:addInteger("TS_W", "Trade Signal Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("TS_S", "Trade Signal Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("TS_S", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("VB_C", "Volatility Band Line Color", "", colors.Blue);
    indicator.parameters:addInteger("VB_Wi", "Volatility Band Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("VB_S", "Volatility Band Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("VB_S", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("MB_C", "Market Base Line Color", "", colors.SandyBrown);
    indicator.parameters:addInteger("MB_W", "Market Base Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("MB_S", "Market Base Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MB_S", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("L1", "Low Level", "", 32, 0, 100);
    indicator.parameters:addInteger("L2", "Middle Level", "", 50, 0, 100);
    indicator.parameters:addInteger("L3", "High Level", "", 68, 0, 100);
    indicator.parameters:addColor("L_C", "Level Line Color", "", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:addInteger("L_W", "Market Base Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("L_S", "Market Base Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("L_S", core.FLAG_LEVEL_STYLE);
end

local iRSI, iPMA, iTSMA;
local P, VBU, VBD, TS, MB;

local VB_N, VB_W, L1, L2, L3;
local fP, fVB, fTS;

function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.source:name() .. "," ..
                                        instance.parameters.RSI_N .. "," ..
                                        instance.parameters.VB_N .. "," .. instance.parameters.VB_W .. "," ..
                                        instance.parameters.RSI_P_N .. "," .. instance.parameters.RSI_P_M .. "," ..
                                        instance.parameters.TS_N .. "," .. instance.parameters.TS_M .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    VB_N = instance.parameters.VB_N;
    VB_W = instance.parameters.VB_W;
    L1 = instance.parameters.L1;
    L2 = instance.parameters.L2;
    L3 = instance.parameters.L3;

    iRSI = core.indicators:create("RSI", instance.source, instance.parameters.RSI_N);
    assert(core.indicators:findIndicator(instance.parameters.RSI_P_M) ~= nil, instance.parameters.RSI_P_M .. " indicator must be installed");
    iPMA = core.indicators:create(instance.parameters.RSI_P_M, iRSI.DATA, instance.parameters.RSI_P_N);
    fP = iPMA.DATA:first();
    assert(core.indicators:findIndicator(instance.parameters.TS_M) ~= nil, instance.parameters.TS_M .. " indicator must be installed");
    iTSMA = core.indicators:create(instance.parameters.TS_M, iRSI.DATA, instance.parameters.TS_N);
    fTS = iTSMA.DATA:first();

    fVB = iRSI.DATA:first() + instance.parameters.VB_N - 1;

    P = instance:addStream("RSI_P", core.Line, name .. ".RSI_P", "PriceLine", instance.parameters.RSI_P_C, fP);
    P:setPrecision(math.max(2, instance.source:getPrecision()));
    P:setWidth(instance.parameters.RSI_P_W);
    P:setStyle(instance.parameters.RSI_P_S);

    P:addLevel(L1, instance.parameters.L_S, instance.parameters.L_W, instance.parameters.L_C);
    P:addLevel(L2, instance.parameters.L_S, instance.parameters.L_W, instance.parameters.L_C);
    P:addLevel(L3, instance.parameters.L_S, instance.parameters.L_W, instance.parameters.L_C);

    VBU = instance:addStream("VBU", core.Line, name .. ".VBU", "VolBandUp", instance.parameters.VB_C, fVB);
    VBU:setPrecision(math.max(2, instance.source:getPrecision()));
    VBU:setWidth(instance.parameters.VB_Wi);
    VBU:setStyle(instance.parameters.VB_S);
    --VB_W
    VBD = instance:addStream("VBD", core.Line, name .. ".VBD", "VolBandDn", instance.parameters.VB_C, fVB);
    VBD:setPrecision(math.max(2, instance.source:getPrecision()));
    VBD:setWidth(instance.parameters.VB_Wi);
    VBD:setStyle(instance.parameters.VB_S);

    MB = instance:addStream("MB", core.Line, name .. ".MB", "MktBase", instance.parameters.MB_C, fVB);
    MB:setPrecision(math.max(2, instance.source:getPrecision()));
    MB:setWidth(instance.parameters.MB_W);
    MB:setStyle(instance.parameters.MB_S);

    TS = instance:addStream("TS", core.Line, name .. ".TS", "TrdSig", instance.parameters.TS_C, fTS);
    TS:setPrecision(math.max(2, instance.source:getPrecision()));
    TS:setWidth(instance.parameters.TS_W);
    TS:setStyle(instance.parameters.TS_S);
end

function Update(period, mode)
    iRSI:update(mode);
    iPMA:update(mode);
    iTSMA:update(mode);

    if period >= fP then
        P[period] = iPMA.DATA[period];
    end

    if period >= fTS then
        TS[period] = iTSMA.DATA[period];
    end

    if period >= fVB then
        local stdev, ma;
        stdev = core.stdev(iRSI.DATA, period - VB_N + 1, period);
        ma = core.avg(iRSI.DATA, period - VB_N + 1, period);
        VBU[period] = ma + VB_W * stdev;
        VBD[period] = ma - VB_W * stdev;
        MB[period] = ma;
    end
end

