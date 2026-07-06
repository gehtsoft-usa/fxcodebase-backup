-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73785

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
    indicator:name("Custom Chande Momentum Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

  
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P", "Period", "", 9);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("CMO_color", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("CMO_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("CMO_style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("CMO_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Oversold/Overbought levels");
	indicator.parameters:addInteger("Oversold", "Oversold", "", 100);
	 indicator.parameters:addInteger("Overbought", "Overbought", "", -100);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local  P;
local sc;

local first;
local first_cm;
local source = nil;

local cmo1 = nil;
local cmo2 = nil;
local CMO = nil;
	
-- Routine
 function Prepare(nameOnly)   
 
 
    P = instance.parameters.P;
    source = instance.source;
    first_cm = source:first() + 1;
    first = first_cm + P;
    sc = 2 / (P + 1);
    local  name = profile:id() .."(" .. source:name() .. ", " .. P .. ")";
    instance:name(name);
    cmo1 = instance:addInternalStream(first_cm, 0);
    cmo2 = instance:addInternalStream(first_cm, 0);
    CMO = instance:addStream("CMO", core.Line, name, "CMO", instance.parameters.CMO_color, first);
    CMO:setWidth(instance.parameters.CMO_width);
    CMO:setStyle(instance.parameters.CMO_style);
    CMO:addLevel(instance.parameters.Oversold);
    CMO:addLevel(0);
    CMO:addLevel(instance.parameters.Overbought);
	
 
 
end


function Update(period, mode)

    cmo1[period] = 0;
    cmo2[period] = 0;

    if (period >= first_cm) then
  
        local  diff;
        diff = source[period] - source[period - 1];
        if (diff > 0) then
      
            cmo1[period] = diff;
         
        elseif (diff < 0) then
        
            cmo2[period] = -diff;
        end
    end

    if (period >= first)  then
    
        local p, cmo, s1, s2;
        p = period - P + 1;
        s1 = mathex.sum(cmo1, p, period);
        s2 = mathex.sum(cmo2, p, period);
        CMO[period] = (s1 - s2) / (s1 + s2) * 100;
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