-- Id: 1360
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1927

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

function Init()
    indicator:name("RSI Candle");
    indicator:description("RSI Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "RSI period", "RSI Period", 14);	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addDouble("OB", "OB Level", "OB Level", 70);
    indicator.parameters:addDouble("OS", "OS Level", "OS Level", 30);
	
	indicator.parameters:addBoolean("Show", "Show OB/OS Zone", "", true);
	indicator.parameters:addInteger("transp", "Zone Transparency %","", 80, 0, 100);
	
	indicator.parameters:addColor("Top", "OB Zone Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "OS Zone Color","", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local Show;
local first;
local source = nil;

-- Streams block
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;

local RSIOpen = nil;
local RSIClose = nil;
local RSIHigh = nil;
local RSILow = nil;
local OB,OS;
local UpLow,UpHigh,DownLow,DownHigh;
local Top,Bottom;
-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
	Show = instance.parameters.Show;
	Top = instance.parameters.Top;
	Bottom = instance.parameters.Bottom;
    source = instance.source;
   
	
	OB = instance.parameters.OB;
	OS = instance.parameters.OS;
     
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RSIOpen = core.indicators:create("RSI", source.open, Frame);
	RSIHigh = core.indicators:create("RSI", source.high, Frame);
	RSILow = core.indicators:create("RSI", source.low, Frame);
	RSIClose = core.indicators:create("RSI", source.close, Frame);	
	
	 first = RSIClose.DATA:first() ;
    Open = instance:addStream("Open", core.Line, name .. "", "", core.COLOR_LABEL, first);
    Close = instance:addStream("Close", core.Line, name .. "", "", core.COLOR_LABEL, first);
    High = instance:addStream("High", core.Line, name .. "", "", core.COLOR_LABEL, first);
    Low = instance:addStream("Low", core.Line, name .. "", "", core.COLOR_LABEL, first);
	
	Open:setPrecision(math.max(2, instance.source:getPrecision()));
	Close:setPrecision(math.max(2, instance.source:getPrecision()));
	High:setPrecision(math.max(2, instance.source:getPrecision()));
	Low:setPrecision(math.max(2, instance.source:getPrecision()));
	
	instance:createCandleGroup("RSI", "RSI Candle", Open, High, Low, Close);
	
	UpLow = instance:addStream("UpLow", core.Line, name .. "", "", core.COLOR_LABEL, first);
    DownLow = instance:addStream("DownLow", core.Line, name .. "", "", core.COLOR_LABEL, first);
    UpHigh = instance:addStream("UpHigh", core.Line, name .. "", "", core.COLOR_LABEL, first);
    DownHigh = instance:addStream("DownHigh", core.Line, name .. "", "", core.COLOR_LABEL, first);
	
	UpLow:setPrecision(math.max(2, instance.source:getPrecision()));
	DownLow:setPrecision(math.max(2, instance.source:getPrecision()));
	UpHigh:setPrecision(math.max(2, instance.source:getPrecision()));
	DownHigh:setPrecision(math.max(2, instance.source:getPrecision()));
	
	if Show then
	instance:createChannelGroup("UP", "UP", UpLow, UpHigh, Top,100 - instance.parameters.transp);
	instance:createChannelGroup("DOWN", "DOWN", DownLow, DownHigh, Bottom, 100 - instance.parameters.transp);
	end
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    RSIOpen:update(mode);
	RSIClose:update(mode);
	RSIHigh:update(mode);
	RSILow:update(mode);
 
	
    if period < first or not  source:hasData(period) then
	return;
	end
	
	UpLow[period] = OB;
    DownLow[period] = 0;
    UpHigh[period] = 100;
    DownHigh[period] = OS;
	
        Open[period] = RSIOpen.DATA[period];
        Close[period] = RSIClose.DATA[period];
        High[period] = math.max(Open[period],Close[period],RSIHigh.DATA[period]) ;
        Low[period] = math.min(Open[period],Close[period],RSILow.DATA[period]) ;
   
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