-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=2069


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
 

-- original indicator:
-- Traders Dynamic Index.mq4
-- Copyright © 2006, Dean Malone
-- www.compassfx.com


function Init()
    indicator:name("Non-standard Time Frame TradersDynamicIndex");
    indicator:description("This hybrid indicator is developed to assist traders in their ability to decipher and monitor market conditions related to trend direction, market strength, and market volatility.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
	

	
	indicator.parameters:addString("TF", "Time frame", "", "Chart");
	

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


local P, VBU, VBD, TS, MB;

local VB_N, VB_W, L1, L2, L3;
local fP, fVB, fTS;

local TF;
local weekoffset, dayoffset;
local loading;
local SourceData,source;
local Indicator;

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
	
	source= instance.source;
	
	
	TF= instance.parameters.TF;
	if TF=="Chart" then
	TF=source:barSize();
	end
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	

	assert(core.indicators:findIndicator("TRADERSDYNAMICINDEX") ~= nil, "Please, download and install TRADERSDYNAMICINDEX.LUA indicator");
  
    L1 = instance.parameters.L1;
    L2 = instance.parameters.L2;
    L3 = instance.parameters.L3;
	
	if TF ~= "Chart"then
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	end
	
	if TF ~= source:barSize() then 
    SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
    loading=true;
	
	
	Indicator = core.indicators:create("TRADERSDYNAMICINDEX", SourceData.close, instance.parameters.RSI_N,instance.parameters.VB_N,instance.parameters.VB_W,instance.parameters.RSI_P_N,instance.parameters.RSI_P_M,instance.parameters.TS_N,instance.parameters.TS_M);

	
	else
	
	Indicator = core.indicators:create("TRADERSDYNAMICINDEX", source, instance.parameters.RSI_N,instance.parameters.VB_N,instance.parameters.VB_W,instance.parameters.RSI_P_N,instance.parameters.RSI_P_M,instance.parameters.TS_N,instance.parameters.TS_M);

	
	end

    

    P = instance:addStream("RSI_P", core.Line, name .. ".RSI_P", "PriceLine", instance.parameters.RSI_P_C, source:first());
    P:setWidth(instance.parameters.RSI_P_W);
    P:setStyle(instance.parameters.RSI_P_S);

    P:addLevel(L1, instance.parameters.L_S, instance.parameters.L_W, instance.parameters.L_C);
    P:addLevel(L2, instance.parameters.L_S, instance.parameters.L_W, instance.parameters.L_C);
    P:addLevel(L3, instance.parameters.L_S, instance.parameters.L_W, instance.parameters.L_C);

    VBU = instance:addStream("VBU", core.Line, name .. ".VBU", "VolBandUp", instance.parameters.VB_C,  source:first());
    VBU:setWidth(instance.parameters.VB_Wi);
    VBU:setStyle(instance.parameters.VB_S);
    --VB_W
    VBD = instance:addStream("VBD", core.Line, name .. ".VBD", "VolBandDn", instance.parameters.VB_C,  source:first());
    VBD:setWidth(instance.parameters.VB_Wi);
    VBD:setStyle(instance.parameters.VB_S);

    MB = instance:addStream("MB", core.Line, name .. ".MB", "MktBase", instance.parameters.MB_C,  source:first());
    MB:setWidth(instance.parameters.MB_W);
    MB:setStyle(instance.parameters.MB_S);

    TS = instance:addStream("TS", core.Line, name .. ".TS", "TrdSig", instance.parameters.TS_C,  source:first());
    TS:setWidth(instance.parameters.TS_W);
    TS:setStyle(instance.parameters.TS_S);
end

function Update(period, mode)
    Indicator:update(mode);

	
	
	if TF ~= "Chart" and  TF ~=  source:barSize()  then
	 local p =  Initialization(period) 
     
        if not p then
        return;
        end
		
		
		if 	Indicator.VBU:hasData(p) then
		P[period]=Indicator.RSI_P[p];
		VBU[period]=Indicator.VBU[p];
		VBD[period]=Indicator.VBD[p];
		MB[period]=Indicator.MB[p];
		TS[period]=Indicator.TS[p];
		end		
	 
	 else
	 
	 
	
	if 	Indicator.VBU:hasData(period) then
	    
		P[period]=Indicator.RSI_P[period];
		VBU[period]=Indicator.VBU[period];
		VBD[period]=Indicator.VBD[period];
		MB[period]=Indicator.MB[period];
		TS[period]=Indicator.TS[period];	
		end
	 
	 
			
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
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
    else return p;    
    end
    
end    


