-- Id: 7889
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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RSI Candle");
    indicator:description("RSI Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
 	indicator.parameters:addGroup("Selector");	   
	indicator.parameters:addBoolean("wicks", "Show Wicks", "", true);
	indicator.parameters:addBoolean("zone", "Show OB/OS Zones", "", true);	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Frame", "RSI period", "", 14);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("OB", "OB Color", "", core.rgb(255,0, 0));
    indicator.parameters:addColor("OS", "OS Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Transparency", "Transparency", "", 80);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;
local wicks;
-- Streams block
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;
local OB,OS;
local RSIOpen = nil;
local RSIClose = nil;
local RSIHigh = nil;
local RSILow = nil;
local Transparency;
local UpLow,UpHigh,DownLow,DownHigh;

-- Routine
function Prepare(nameOnly)
    wicks = instance.parameters.wicks;
	zone = instance.parameters.zone;
    Frame = instance.parameters.Frame;
    source = instance.source;
    first = source:first()+Frame;
	Transparency = ( 100 - instance.parameters.Transparency);
    
	OB = instance.parameters.OB;
	OS = instance.parameters.OS;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
    RSIOpen = core.indicators:create("RSI", source.open, Frame);
	RSIHigh = core.indicators:create("RSI", source.high, Frame);
	RSILow = core.indicators:create("RSI", source.low, Frame);
	RSIClose = core.indicators:create("RSI", source.close, Frame);	
	
    
	
    Open = instance:addStream("Open", core.Line, name .. "", "", core.COLOR_LABEL, first);
    Close = instance:addStream("Close", core.Line, name .. "", "", core.COLOR_LABEL, first);
    High = instance:addStream("High", core.Line, name .. "", "", core.COLOR_LABEL, first);
    Low = instance:addStream("Low", core.Line, name .. "", "", core.COLOR_LABEL, first);
	Open:setPrecision(math.max(2, instance.source:getPrecision()));
	Close:setPrecision(math.max(2, instance.source:getPrecision()));
	High:setPrecision(math.max(2, instance.source:getPrecision()));
	Low:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	instance:createCandleGroup("RSI", "RSI Candle", Open, High, Low, Close);
    if zone then		
	UpLow = instance:addStream("UpLow", core.Line, name .. "", "", core.COLOR_LABEL, first);
    DownLow = instance:addStream("DownLow", core.Line, name .. "", "", core.COLOR_LABEL, first);
    UpHigh = instance:addStream("UpHigh", core.Line, name .. "", "", core.COLOR_LABEL, first);
    DownHigh = instance:addStream("DownHigh", core.Line, name .. "", "", core.COLOR_LABEL, first);
	
	UpLow:setPrecision(math.max(2, instance.source:getPrecision()));
	DownLow:setPrecision(math.max(2, instance.source:getPrecision()));
	UpHigh:setPrecision(math.max(2, instance.source:getPrecision()));
	DownHigh:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	instance:createChannelGroup("OB", "OB", UpLow, UpHigh, OB, Transparency);
	instance:createChannelGroup("OS", "OS", DownLow, DownHigh, OS, Transparency);
	else
    UpLow = instance:addInternalStream(0, 0);	
    DownLow = instance:addInternalStream(0, 0);	
    UpHigh = instance:addInternalStream(0, 0);	
    DownHigh = instance:addInternalStream(0, 0);		
	end
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


	
	RSIOpen:update(mode);
	RSIClose:update(mode);
	RSIHigh:update(mode);
	RSILow:update(mode);
	
    if period <= first or not  source:hasData(period) then
	return;
	end	
	
	UpLow[period] = 70;
    DownLow[period] = 0;
    UpHigh[period] = 100;
    DownHigh[period] = 30;
	
        Open[period] = RSIOpen.DATA[period];
        Close[period] = RSIClose.DATA[period];
		
		if wicks then
        High[period] = math.max(Open[period],Close[period],RSIHigh.DATA[period]) ;
        Low[period] = math.min(Open[period],Close[period],RSILow.DATA[period]) ;
		else
		  High[period] = math.max(RSIOpen.DATA[period],RSIClose.DATA[period]);
        Low[period] =  math.min(RSIOpen.DATA[period],RSIClose.DATA[period]);
		end
    
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
