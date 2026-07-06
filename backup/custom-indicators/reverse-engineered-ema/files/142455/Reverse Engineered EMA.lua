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

-- initializes the indicator
function Init()
    indicator:name("Reverse Engineered EMA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Moving Averages");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period" ,"", 10, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrEMA", "Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthEMA", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleEMA", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleEMA", core.FLAG_LEVEL_STYLE);
end

 
local first = 0;
local n = 0;
local k = 0;
local source = nil;
local out = nil;
local internal;
local EMA; 

-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
    n = instance.parameters.N;
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    EMA = core.indicators:create("EMA", source, N);

    k = 2.0 / (n + 1.0);
    first=EMA.DATA:first()+1;
	
	

    internal = instance:addInternalStream(0, 0);
    out = instance:addStream("Source", core.Line, name, "Source", instance.parameters.clrEMA,  first)
    out:setWidth(instance.parameters.widthEMA);
    out:setStyle(instance.parameters.styleEMA);

 
end

 
function Update(period)


    EMA:update(mode);
  
    if period < first then
	return;
	end
	
        out[period] =  (EMA.DATA[period]-(1 - k) * EMA.DATA[period-1])/k
   
end