-- Available @ http://fxcodebase.com/ 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
 


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("RSI of Stochastic");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Stochastic Calculation");
    indicator.parameters:addInteger("K", "%K Stochastic Periods", "", 14, 1, 200);
    indicator.parameters:addInteger("KS", "%K Slowing Periods", "", 5, 1, 200);
    indicator.parameters:addInteger("D", "%D Slowing Stochastic Periods", "", 3, 1, 200);
	
	indicator.parameters:addGroup("RSI Calculation");
    indicator.parameters:addInteger("N", "Number of periods for RSI", "", 14, 1, 200);	
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
 
end

-- Indicator instance initialization routine

-- Parameters block
local N;
local K;
local KS;
local D;

local firstSKI;
local firstK;
local firstD;
local source = nil;

-- Streams block
local SKI = nil;
local SK = nil;
local SD = nil;
local RSI = nil;
local MVA1 = nil;
local MVA2 = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    K = instance.parameters.K;
    KS = instance.parameters.KS;
    D = instance.parameters.D;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name()  .. ", " .. K .. ", " .. KS ..", " .. D .. ", " .. N.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

 
    SKI = instance:addInternalStream(0, 0);
    MVA = core.indicators:create("MVA", SKI, KS);
	Stochastic = instance:addInternalStream(0, 0);


    RSI = core.indicators:create("RSI", Stochastic, N);
	
    RSI_STOCHASTIC = instance:addStream("RSI_STOCHASTIC", core.Line, name .. ".RSI_STOCHASTIC", "RSI_STOCHASTIC", instance.parameters.color, MVA.DATA:first() + N);
    RSI_STOCHASTIC:setPrecision(math.max(2, instance.source:getPrecision()));
	RSI_STOCHASTIC:setWidth(instance.parameters.width);
    RSI_STOCHASTIC:setStyle(instance.parameters.style);
    RSI_STOCHASTIC:addLevel(30);
    RSI_STOCHASTIC:addLevel(50);
    RSI_STOCHASTIC:addLevel(70);	

 
  
end

-- Indicator calculation routine
function Update(period, mode)


    if (period < first+ K) then
	return; 
	end
	
        local min, max; 
        min,max = mathex.minmax(source, period-K+1, period);
 
        if (min == max) then
            SKI[period] = 100;
        else
            SKI[period] = (source[period] - min) / (max - min) * 100;
        end
  
    MVA:update(mode);

    if period < MVA.DATA:first() then
	return;
	end
	
        Stochastic[period] = MVA.DATA[period];
     
 
    RSI:update(mode);
	
    if period < RSI.DATA:first() then
	return;
	end	
	
	RSI_STOCHASTIC[period]=RSI.DATA[period];
	
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+