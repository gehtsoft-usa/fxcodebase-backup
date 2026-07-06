-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=139


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
    indicator:name("Gann Hi-lo Activator SSL");
    indicator:description("When red line is above the candle, sell.When red line is below the canle, buy.");    
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
    indicator.parameters:addGroup("Calculation");   
    indicator.parameters:addInteger("N", "Number of periods", "The number of periods.", 10, 2, 1000);
	
	indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");
	
	indicator.parameters:addGroup("Style");    
	
    indicator.parameters:addColor("Up", "Up Line Color", "Color of the Up line.", core.rgb(0, 255, 0));    
	indicator.parameters:addColor("Dn", "Up Line Color", "Color of the Up line.", core.rgb(255, 0, 0)); 
	
	indicator.parameters:addInteger("width", " Grid Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", " Grid Style", " ", core.LINE_SOLID);
	 indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams

-- Parameters block
local first;
local source = nil;
local pips;
local Method;
-- Streams block
local SSL = nil;

-- Internal streams and indicators
local maHigh = nil;
local maLow = nil;
local hlvStream = nil;

local Method, n;

-- Routine
function Prepare(nameOnly)
    source = instance.source;    
    n = instance.parameters.N;      
    Method = instance.parameters.Method;	
    first = n + source:first();
    
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. "," .. Method.. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
    maHigh = core.indicators:create("AVERAGES", source.high, Method, n  );
    maLow = core.indicators:create("AVERAGES", source.low,  Method, n);        
    
    SSL = instance:addStream("SSL", core.Line, name, "SSL", instance.parameters.Up, first);   
    SSL:setWidth(instance.parameters.width);
	SSL:setStyle(instance.parameters.style);	
    hlvStream = instance:addInternalStream(first - 1);    
end

         
-- Indicator calculation routine
function Update(period, mode)    
    maHigh:update(mode);
    maLow:update(mode);
    
    if period >= first then         
        local close = source.close[period];
        local maHighVal = maHigh.DATA[period - 1];
        local maLowVal = maLow.DATA[period - 1];
        local hld = 0;
        local hlv;
        
        if close > maHighVal then
            hld = 1;
        elseif close < maLowVal then
            hld = -1;        
        end
		
		 SSL:setColor(period, SSL:colorI(period-1));


        
        hlv = hlvStream[period - 1];
        if hld ~= 0 then
           hlv = hld;           
        end
        
        hlvStream[period] = hlv; 
        
        if hlv == -1 then
            SSL[period] = maHighVal; 
			 SSL:setColor(period, instance.parameters.Dn);
        elseif hlv == 1 then         
            SSL[period] = maLowVal;  
            SSL:setColor(period, instance.parameters.Up);  			
        end                    
    else
        hlvStream[period] = 0;          
    end
end
