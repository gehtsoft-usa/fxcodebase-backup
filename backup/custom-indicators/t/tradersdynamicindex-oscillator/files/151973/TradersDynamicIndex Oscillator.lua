-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74010

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


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
	
    indicator.parameters:addGroup("Control Calculation");	
	indicator.parameters:addString("TF", "Control Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	

    local colors = core.colors();

    indicator.parameters:addGroup("Bar Style");
    indicator.parameters:addColor("Up", "Up Color", "", colors.Green);
    indicator.parameters:addColor("Down", "Down Color", "", colors.Red);
    indicator.parameters:addColor("Neutral", "Neutral Color", "", colors.Blue); 

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("BL", "Buy Level", "", 50, 0, 100);
    indicator.parameters:addInteger("BEL", "Buy Exit Level", "", 80, 0, 100);
    indicator.parameters:addInteger("SL", "Sell Level", "", 50, 0, 100); 
    indicator.parameters:addInteger("SEL", "Sell Exit Level", "", 20, 0, 100);
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
	
	BL = instance.parameters.BL;
	BEL = instance.parameters.BEL;
	SL = instance.parameters.SL;
	SEL = instance.parameters.SEL;
	
    Up = instance.parameters.Up;
	Down = instance.parameters.Down
	Neutral = instance.parameters.Neutral

    iRSI = core.indicators:create("RSI", instance.source, instance.parameters.RSI_N);
    assert(core.indicators:findIndicator(instance.parameters.RSI_P_M) ~= nil, instance.parameters.RSI_P_M .. " indicator must be installed");
    iPMA = core.indicators:create(instance.parameters.RSI_P_M, iRSI.DATA, instance.parameters.RSI_P_N);
    fP = iPMA.DATA:first();
    assert(core.indicators:findIndicator(instance.parameters.TS_M) ~= nil, instance.parameters.TS_M .. " indicator must be installed");
    iTSMA = core.indicators:create(instance.parameters.TS_M, iRSI.DATA, instance.parameters.TS_N);
    fTS = iTSMA.DATA:first();

    fVB = iRSI.DATA:first() + instance.parameters.VB_N - 1;

 
    VBU  = instance:addInternalStream(0, 0); 
    VBD  = instance:addInternalStream(0, 0); 
    MB  = instance:addInternalStream(0, 0); 
    TS  = instance:addInternalStream(0, 0);
	P   = instance:addInternalStream(0, 0);	
	
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(instance.source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");

	SourceData = core.host:execute("getSyncHistory", instance.source:instrument(), TF, instance.source:isBid(), 0, 100, 101);
	loading=true;	
	
	
    Signal = instance:addStream("Signal", core.Bar, name, "Signal", Up, 0 );
    Signal:setPrecision(math.max(2, instance.source:getPrecision())); 
    Signal:addLevel(0);		
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, instance.source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < instance.source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


function Update(period, mode)
    iRSI:update(mode);
    iPMA:update(mode);
    iTSMA:update(mode);

    if period <= fP then
	return;
	end
        P[period] = iPMA.DATA[period];
 

    if period <= fTS then
	return;
	end
	
        TS[period] = iTSMA.DATA[period];
 

    if period <= fVB then
	return;
	end
	
        local stdev, ma;
        stdev = core.stdev(iRSI.DATA, period - VB_N + 1, period);
        ma = core.avg(iRSI.DATA, period - VB_N + 1, period);
        VBU[period] = ma + VB_W * stdev;
        VBD[period] = ma - VB_W * stdev;
        MB[period] = ma;
		

    local p =  Initialization(period) 
     
	if not p
	or not SourceData.close:hasData(p)
	then
	return;
	end
	
		
		
	if P[period]>MB[period]
	and MB[period] > BL
	and MB[period] < BEL
    and SourceData.close[p]>SourceData.open[p] 	
	then
	Signal[period]=1;
 	Signal:setColor(period,  Up); 	
	elseif P[period]<MB[period]
	and MB[period] < SL
	and MB[period] > SEL	
    and SourceData.close[p]<SourceData.open[p] 		
	then
	Signal[period]=-1;
 	Signal:setColor(period,  Down); 	
	else
	Signal[period]=0;
 	Signal:setColor(period,  Neutral);	
	end
		

	
	 
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	
    return core.ASYNC_REDRAW ;	
end




--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+