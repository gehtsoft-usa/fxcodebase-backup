-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71256

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+


-- The indicator corresponds to the ADX indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 23 "Risk Control" (page 609-611)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Smoothed DMI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend Strength");
	
	
	    indicator.parameters:addGroup("Pre-Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 1000);
 
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");


    indicator.parameters:addGroup("DMI Calculation");
    indicator.parameters:addInteger("Period1", "Period", "", 14, 1, 1000);
 
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Post-Smoothing Calculation");
	indicator.parameters:addInteger("Period2", "MA Period", "Period" , 14);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrDIP", "DIP Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthDIP", "Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleDIP","Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDIP", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrDIM", "DIM Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthDIM","Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleDIM","Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDIM", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period1,Method1;

local first;
local source = nil;
local avgPlusDM = nil;
local avgMinusDM = nil;
local tAbs = math.abs;

-- Streams block
local DIP = nil;
local DIM = nil;
local emaDIP = nil;
local emaDIM = nil;
local sfirst;
local Period2, Method2, PMA, NMA;
local Raw_DIP, Raw_DIM;
local Period,Method, High,Low;
-- Routine
function Prepare(onlyName)
    Period1 = instance.parameters.Period1;
	Method1 = instance.parameters.Method1;
	        
	Method2=instance.parameters.Method2;
	Period2=instance.parameters.Period2;
	
	Period=instance.parameters.Period;
	Method=instance.parameters.Method;
	
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Method.. ", " .. Period1 .. ", " .. Method1.. ", " .. Period2 .. ", " .. Method2.. ")";
    instance:name(name);
    if onlyName then
        return ;
    end



	
	
	High = core.indicators:create(Method, source.high, Period);
    Low = core.indicators:create(Method, source.low, Period);
 
	 sfirst = High.DATA:first()+1  ;

    avgPlusDM = instance:addInternalStream(sfirst, 0);
    avgMinusDM = instance:addInternalStream(sfirst, 0);
	
    emaDIP = core.indicators:create(Method1, avgPlusDM, Period1);
    emaDIM = core.indicators:create(Method1, avgMinusDM, Period1);
    first = math.max(emaDIP.DATA:first(), emaDIM.DATA:first());
	
	Raw_DIP = instance:addInternalStream(0, 0);
	Raw_DIM = instance:addInternalStream(0, 0);
	
	PMA = core.indicators:create(Method2, Raw_DIP, Period2);
	NMA = core.indicators:create(Method2, Raw_DIM, Period2);
	 
	

    DIP = instance:addStream("DIP", core.Line, name .. ".DIP", "DI+", instance.parameters.clrDIP, first)
    DIP:setWidth(instance.parameters.widthDIP);
    DIP:setStyle(instance.parameters.styleDIP);
    DIP:setPrecision(4);
    DIM = instance:addStream("DIM", core.Line, name .. ".DIM", "DI-", instance.parameters.clrDIM, first)
    DIM:setWidth(instance.parameters.widthDIM);
    DIM:setStyle(instance.parameters.styleDIM);
    DIM:setPrecision(4);

 
end

function TrueRangeCustom(period)
    local num1 = tAbs(source.high[period] - source.low[period]);
    local num2 = tAbs(source.high[period] - source.close[period - 1]);
    local num3 = tAbs(source.close[period - 1] - source.low[period]);
    return math.max(num1, num2, num3);
end

-- Indicator calculation routine
 

function Update(period, mode)
    avgPlusDM[period] = 0;
    avgMinusDM[period] = 0;
	
	
	High:update(mode);
    Low:update(mode);

    if period < sfirst then
	return;
	end
	
        local upperMove = 0;
        local lowerMove = 0;
        local TR = 0;

        upperMove = High.DATA[period] - High.DATA[period - 1];
        lowerMove = Low.DATA[period - 1] - Low.DATA[period];
        if (upperMove < 0) then upperMove = 0 end
        if (lowerMove < 0) then lowerMove = 0 end
        if (upperMove == lowerMove) then
            upperMove = 0;
            lowerMove = 0;
        elseif (upperMove < lowerMove) then
            upperMove = 0;
        elseif (lowerMove < upperMove) then
            lowerMove = 0;
        end

        TR = TrueRangeCustom(period);
        if (TR == 0) then
            avgPlusDM[period] = 0;
            avgMinusDM[period] = 0;
        else
            avgPlusDM[period] = 100 * upperMove / TR;
            avgMinusDM[period] = 100 * lowerMove / TR;
        end
 

    if period <= first then
	return;
	end
	
	
        emaDIP:update(mode);
        emaDIM:update(mode);

        Raw_DIP[period] = emaDIP.DATA[period];
        Raw_DIM[period] = emaDIM.DATA[period];
		
	PMA:update(mode);
	NMA:update(mode);
	
	if period <= first+Period2 then
	return;
	end
	
	DIP[period] = PMA.DATA[period];
	DIM[period] = NMA.DATA[period];
end

 