-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71262

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Reverse Engineered Zero Lag MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("FMA", "Fast EMA periods", "", 12, 1, 5000);
    indicator.parameters:addInteger("SMA", "Slow EMA Periods", "", 24, 1, 5000);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Source_color", "Color of Source", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local FMA;
local SMA;
local SigMA;

local FMA_I;
local SMA_I;
local FMA_I2;
local SMA_I2;
local SigMA_I;
local SigMA_I2;

local firstMACD, firstSIG;
local source = nil;

-- Streams block
local Source = nil;
 

-- Routine
function Prepare(nameOnly)
    FMA = instance.parameters.FMA;
    SMA = instance.parameters.SMA;
    SigMA = instance.parameters.SigMA;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. FMA  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    MACD= instance:addInternalStream(0, 0);
    k = 2.0 / (FMA + 1.0);
		
    FMA_I = core.indicators:create("EMA", source, FMA);
    SMA_I = core.indicators:create("EMA", source, SMA);
    FMA_I2 = core.indicators:create("EMA", FMA_I.DATA, FMA);
    SMA_I2 = core.indicators:create("EMA", SMA_I.DATA, SMA);
	EMA = core.indicators:create("EMA", source, FMA);

    firstMACD = math.max(FMA_I2.DATA:first(), SMA_I2.DATA:first());

    Source = instance:addStream("Source", core.Line, name .. ".Source", "Source", instance.parameters.Source_color, firstMACD);	
    Source:setWidth(instance.parameters.width1);
    Source:setStyle(instance.parameters.style1);
 
end

-- Indicator calculation routine
function Update(period, mode)
    FMA_I:update(mode);
    FMA_I2:update(mode);
    SMA_I:update(mode);
    SMA_I2:update(mode);
	EMA:update(mode);
 
    if period < firstMACD then
	return;
	end
	 
    MACD[period] = (2 * FMA_I.DATA[period] - FMA_I2.DATA[period]) -
                       (2 * SMA_I.DATA[period] - SMA_I2.DATA[period]);
   
     Source[period] = -(( (- FMA_I2.DATA[period]) - (2 * SMA_I.DATA[period] - SMA_I2.DATA[period])- MACD[period])/2+ (1 - k) * FMA_I.DATA[period])/k;
end

