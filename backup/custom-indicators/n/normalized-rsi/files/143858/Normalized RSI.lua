-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71548

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

-- The indicator corresponds to the Relative Strength Index indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 133-134)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Normalized RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period","", 14, 2, 1000);
    indicator.parameters:addInteger("NP", "Normalization period","", 100, 2, 1000);	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", " Up Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", " Down Line Color","", core.rgb(255, 0, 0));	
    indicator.parameters:addInteger("widthRSI", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleRSI", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleRSI", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "OB Level","", 70, 0, 100);
    indicator.parameters:addInteger("oversold", "OS Level","", 30, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style","Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n,np;

local first;
local source = nil;
local pos = nil;
local neg = nil;

-- Streams block
local RSI = nil;

local Up, Down;

-- Routine
function Prepare()
   
   
   Up= instance.parameters.Up;
   Down= instance.parameters.Down;

    n = instance.parameters.N;
	np = instance.parameters.NP;
    source = instance.source;
    first = source:first() + n;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ", " .. np .. ")";
    instance:name(name);

    pos = instance:addInternalStream(0, 0);
    neg = instance:addInternalStream(0, 0);
	
	
	rsi = instance:addInternalStream(0, 0);

    RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.Up, first+np);
    RSI:setWidth(instance.parameters.widthRSI);
    RSI:setStyle(instance.parameters.styleRSI);
    RSI:setPrecision(2);
    
    RSI:addLevel(0);
    RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RSI:addLevel(50);
    RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    RSI:addLevel(100);
	
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local i = 0;
        local sump = 0;
        local sumn = 0;
        local positive = 0;
        local negative = 0;
        local diff = 0;
        if (period == first) then
            for i = period - n + 1, period do
                diff = source[i] - source[i - 1];
                if (diff >= 0) then
                    sump = sump + diff;
                else
                    sumn = sumn - diff;
                end
            end
            positive = sump / n;
            negative = sumn / n;
        else
            diff = source[period] - source[period - 1];
            if (diff > 0) then 
                sump = diff;
            else
                sumn = -diff;
            end
            positive = (pos[period - 1] * (n - 1) + sump) / n;
            negative = (neg[period - 1] * (n - 1) + sumn) / n;
        end
        pos[period] = positive;
        neg[period] = negative;
        if (negative == 0) then
            rsi[period] = 0;
        else
            rsi[period] = 100 - (100 / (1 + positive / negative));
        end
    end
	
	
	if period <  first +np then
	return;
	end
	
	
	local min,max=mathex.minmax(rsi, period-np+1, period);
	
	
    RSI[period]=(rsi[period]-min) /((max-min)/100); 
	
	
	if RSI[period] > RSI[period-1] then
	RSI:setColor(period, Up);
	else
	RSI:setColor(period,Down);
	end
end

 