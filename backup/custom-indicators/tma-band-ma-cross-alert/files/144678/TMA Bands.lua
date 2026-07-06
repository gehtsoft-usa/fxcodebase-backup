-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71781

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
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
function Init()
    indicator:name("TMA Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");	
	
    indicator.parameters:addInteger("HalfLength", "Half Length", "", 141);
    indicator.parameters:addInteger("AtrLength", "ATR Length", "", 141);
    indicator.parameters:addDouble("AtrMultiplier", "ATR Multiplier", "", 2.4);

    indicator.parameters:addGroup("Style");       
    indicator.parameters:addColor("middle_color", "Middl Color", "Middle Color", core.colors().Red);
    indicator.parameters:addInteger("middle_width", "Middl Width", "Middle Width", 1, 1, 5);
    indicator.parameters:addInteger("middle_style", "Middl Style", "Middle Style", core.LINE_SOLID);
    indicator.parameters:setFlag("middle_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("lower_color", "Lower Color", "Lower Color", core.colors().Blue);
    indicator.parameters:addInteger("lower_width", "Lower Width", "Lower Width", 1, 1, 5);
    indicator.parameters:addInteger("lower_style", "Lower Style", "Lower Style", core.LINE_SOLID);
    indicator.parameters:setFlag("lower_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("upper_color", "Upper Color", "Upper Color", core.colors().Green);
    indicator.parameters:addInteger("upper_width", "Upper Width", "Upper Width", 1, 1, 5);
    indicator.parameters:addInteger("upper_style", "Upper Style", "Upper Style", core.LINE_SOLID);
    indicator.parameters:setFlag("upper_style", core.FLAG_LINE_STYLE);
end

local source, middle, lower, upper, HalfLength, atr, AtrMultiplier;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    AtrMultiplier = instance.parameters.AtrMultiplier;
    HalfLength = instance.parameters.HalfLength;

    middle = instance:addStream("Middle", core.Line, "Middle", "Middle", instance.parameters.middle_color, 0);
    middle:setWidth(instance.parameters.middle_width);
    middle:setStyle(instance.parameters.middle_style);

    lower = instance:addStream("Lower", core.Line, "Lower", "Lower", instance.parameters.lower_color, 0);
    lower:setWidth(instance.parameters.lower_width);
    lower:setStyle(instance.parameters.lower_style);

    upper = instance:addStream("Upper", core.Line, "Upper", "Upper", instance.parameters.upper_color, 0);
    upper:setWidth(instance.parameters.upper_width);
    upper:setStyle(instance.parameters.upper_style);

    atr = core.indicators:create("ATR", source, instance.parameters.AtrLength)
end

function Update(period, mode)
    atr:update(mode);
    if period < HalfLength then
        return;
    end

    local sum = (HalfLength + 1) * source.close[period];
    local sumw = (HalfLength + 1);
    local k = HalfLength;
    for j = 1, HalfLength do
        k = k - 1;
        sum = sum + (k * source.close[period - j]);
        sumw = sumw + k;
    end
    local myrange = atr.DATA[period] * AtrMultiplier;
    middle[period] = sum / sumw;
	
    lower[period] = middle[period] - myrange;
    upper[period] = middle[period] + myrange;
end