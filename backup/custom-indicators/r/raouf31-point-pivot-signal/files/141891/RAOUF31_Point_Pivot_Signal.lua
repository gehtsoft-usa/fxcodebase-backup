-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71171

--+------------------------------------------------------------------------+
--|                                    Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                 http://fxcodebase.com  |
--+------------------------------------------------------------------------+
--|                                      Support our efforts by donating   | 
--|                                         Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------+
--|                                           Developed by : Mario Jemic   |                    
--|                                               mario.jemic@gmail.com    |
--|                                https://AppliedMachineLearning.systems  |
--|                                     Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------+

--+------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
--|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
--|Binance MEMO (BEP2 only)   : 107152697                                  |   
--|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
--+------------------------------------------------------------------------+

function Init()
    indicator:name("RAOUF31 Point Pivot Signal");
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addString("tf1", "Timeframe 1", "", "H1");
    indicator.parameters:setFlag("tf1", core.FLAG_PERIODS);
    indicator.parameters:addString("tf2", "Timeframe 2", "", "H4");
    indicator.parameters:setFlag("tf2", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("up_color", "Up Color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addColor("down_color", "Down Color", "", core.COLOR_DOWNCANDLE)
end

local source;
local signal;
local pivot1;
local pivot2;
local up_color, down_color;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    pivot1 = core.indicators:create("PIVOT", source, instance.parameters.tf1, "Pivot", "HIST");
    pivot2 = core.indicators:create("PIVOT", source, instance.parameters.tf2, "Pivot", "HIST");
    signal = instance:addStream("signal", core.Bar, "Signal", "Signal", instance.parameters.up_color, 0, 0);
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;
    core.host:execute("setTimer", 1, 1);
end

function ReleaseInstance()
end
local needRecalc = false;

function AsyncOperationFinished(cookie)
    if cookie == 1 and needRecalc then
        instance:updateFrom(0);
    end
end

function Update(period, mode)
    pivot1:update(mode);
    pivot2:update(mode);
    if source:size() - 1 == period and not pivot1.P:hasData(period) then
        needRecalc = true;
        return;
    end
    if period < 1 then
        return;
    end
    if pivot1.P[period] < pivot2.P[period] and core.crossesOver(source.close, pivot1.P, period) then
        signal[period] = 1;
    elseif pivot1.P[period] > pivot2.P[period] and core.crossesUnder(source.close, pivot1.P, period) then
        signal[period] = -1;
    elseif period > 0 then
        signal[period] = signal[period - 1];
    end
    if signal[period] > 0 then
        signal:setColor(period, up_color);
    else
        signal:setColor(period, down_color);
    end
end
