-- Id: 9130
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36625

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("FTLM");
    indicator:description("FTLM");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("FTLM_color", "Color of FTLM", "Color of FTLM", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local first;
local price = nil;

-- Streams block
local FTLM = nil;
local STLM = nil;

-- Routine
function Prepare(nameOnly)
    
    price = instance.source;
    first = price:first()+90;

    local name = profile:id() .. "(" .. price:name()   .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        FTLM = instance:addStream("FTLM", core.Line, name .. ".FTLM", "FTLM", instance.parameters.FTLM_color, first);
    FTLM:setPrecision(math.max(2, instance.source:getPrecision()));
		FTLM:setWidth(instance.parameters.width1);
        FTLM:setStyle(instance.parameters.style1);    
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
	

	local value3=0;
	local value4=0;
	local bar= period;
	
	   value3=value3
      +0.4360409450 * price[bar - 0]
      +0.3658689069 * price[bar - 1]
      +0.2460452079 * price[bar - 2]
      +0.1104506886 * price[bar - 3]
      -0.0054034585 * price[bar - 4]
      -0.0760367731 * price[bar - 5]
      -0.0933058722 * price[bar - 6]
      -0.0670110374 * price[bar - 7]
      -0.0190795053 * price[bar - 8]
      +0.0259609206 * price[bar - 9]
      +0.0502044896 * price[bar - 10]
      +0.0477818607 * price[bar - 11]
      +0.0249252327 * price[bar - 12]
      -0.0047706151 * price[bar - 13]
      -0.0272432537 * price[bar - 14]
      -0.0338917071 * price[bar - 15]
      -0.0244141482 * price[bar - 16]
      -0.0055774838 * price[bar - 17]
      +0.0128149838 * price[bar - 18]
      +0.0226522218 * price[bar - 19]
      +0.0208778257 * price[bar - 20]
      +0.0100299086 * price[bar - 21]
      -0.0036771622 * price[bar - 22]
      -0.0136744850 * price[bar - 23]
      -0.0160483392 * price[bar - 24]
      -0.0108597376 * price[bar - 25]
      -0.0016060704 * price[bar - 26]
      +0.0069480557 * price[bar - 27]
      +0.0110573605 * price[bar - 28]
      +0.0095711419 * price[bar - 29]
      +0.0040444064 * price[bar - 30]
      -0.0023824623 * price[bar - 31]
      -0.0067093714 * price[bar - 32]
      -0.0072003400 * price[bar - 33]
      -0.0047717710 * price[bar - 34]
      +0.0005541115 * price[bar - 35]
      +0.0007860160 * price[bar - 36]
      +0.0130129076 * price[bar - 37]
      +0.0040364019 * price[bar - 38];
 
      value4=value4
      -0.0025097319 * price[bar - 0]
      +0.0513007762 * price[bar - 1]
      +0.1142800493 * price[bar - 2]
      +0.1699342860 * price[bar - 3]
      +0.2025269304 * price[bar - 4]
      +0.2025269304 * price[bar - 5]
      +0.1699342860 * price[bar - 6]
      +0.1142800493 * price[bar - 7]
      +0.0513007762 * price[bar - 8]
      -0.0025097319 * price[bar - 9]
      -0.0353166244 * price[bar - 10]
      -0.0433375629 * price[bar - 11]
      -0.0311244617 * price[bar - 12]
      -0.0088618137 * price[bar - 13]
      +0.0120580088 * price[bar - 14]
      +0.0233183633 * price[bar - 15]
      +0.0221931304 * price[bar - 16]
      +0.0115769653 * price[bar - 17]
      -0.0022157966 * price[bar - 18]
      -0.0126536111 * price[bar - 19]
      -0.0157416029 * price[bar - 20]
      -0.0113395830 * price[bar - 21]
      -0.0025905610 * price[bar - 22]
      +0.0059521459 * price[bar - 23]
      +0.0105212252 * price[bar - 24]
      +0.0096970755 * price[bar - 25]
      +0.0046585685 * price[bar - 26]
      -0.0017079230 * price[bar - 27]
      -0.0063513565 * price[bar - 28]
      -0.0074539350 * price[bar - 29]
      -0.0050439973 * price[bar - 30]
      -0.0007459678 * price[bar - 31]
      +0.0032271474 * price[bar - 32]
      +0.0051357867 * price[bar - 33]
      +0.0044454862 * price[bar - 34]
      +0.0018784961 * price[bar - 35]
      -0.0011065767 * price[bar - 36]
      -0.0031162862 * price[bar - 37]
      -0.0033443253 * price[bar - 38]
      -0.0022163335 * price[bar - 39]
      +0.0002573669 * price[bar - 40]
      +0.0003650790 * price[bar - 41]
      +0.0060440751 * price[bar - 42]
      +0.0018747783 * price[bar - 43];
	
	 
        FTLM[period]= value3-value4;
       
end




