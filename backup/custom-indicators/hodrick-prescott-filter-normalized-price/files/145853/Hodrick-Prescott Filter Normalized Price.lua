-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72137

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
    indicator:name("Hodrick-Prescott Filter Normalized Price.lua");
    indicator:description("Hodrick-Prescott Filter Normalized Price.lua");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Filter", "HP Filter Period", "", 50);
    indicator.parameters:addInteger("Bars", "Max Bars to calculate", "", 300, 100, 1000);
    indicator.parameters:addBoolean("Ignore", "Ignore Last Candle", "", true);	

 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local bars;

local first;
local source = nil;

local HPF = nil;
local lambda;
local Ignore;
-- Routine
function Prepare(nameOnly)
    Filter = instance.parameters.Filter;
    bars = instance.parameters.Bars;
	Ignore = instance.parameters.Ignore;
    source = instance.source;
    first = source:first();

    lambda = 0.0625 / (math.sin(3.14159265 / Filter) ^ 4);

    local name = profile:id() .. "(" .. source:name() .. "," .. Filter .. "," .. bars .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    assert(source:first() == 0, "The indicator can be applied on the price data only");

    HPF = instance:addInternalStream(0, 0);
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);	
end

local last = nil;
local last_period = 0;

function Update(period, mode)
    if last_period > period then
        last = nil;
    end
    last_period = period;

    -- update only on the last period and only once per bar
    if period == source:size() - 1 and period > 6 and (last == nil or last ~= source:serial(period)) then
	    if Ignore then
        HPFF(period-1 , math.min(period - 1, bars));		
		else
        HPFF(period , math.min(period, bars));
		end
        last = source:serial(period); 
    end
end

function HPFF(N, max)
    local i;
    local h1 = 0;
    local h2 = 0;
    local h3 = 0;
    local h4 = 0;
    local h5 = 0;
    local hh1 = 0;
    local hh2 = 0;
    local hh3 = 0;
    local hh5 = 0;
    local hb = 0;
    local hc = 0;
    local z = 0;
    local a, b, c;
 

    local ifirst;

    ifirst = N - max + 1;

    a = {};
    b = {};
    c = {};

    a[1] = 1 + lambda;
    b[1] = -2 * lambda;
    c[1] = lambda;

    for i = 2, max - 2, 1 do
        a[i] = 6 * lambda + 1;
        b[i] = -4 * lambda;
        c[i] = lambda;
    end

    a[2] = 5 * lambda + 1;
    a[max - 1] = 5 * lambda + 1;
    a[max] = 1 + lambda;

    b[max - 1] = -2 * lambda;
    b[max] = 0;

    c[max - 1] = 0;
    c[max] = 0;

    for i = 1, max, 1 do
        z = a[i] - h4 * h1 - hh5 * hh2;
        hb = b[i];
        hh1 = h1;

        if z ~= 0 then
            h1 = (hb - h4 * h2) / z;
        end

        b[i] = h1;
        hc = c[i];
        hh2 = h2;

        if z ~= 0 then
            h2 = hc / z;
        end

        c[i] = h2;

        if z ~= 0 then
            a[i] = (source.close[ifirst + i - 1] - hh3 * hh5 - h3 * h4) / z;
        end

        hh3 = h3;
        h3 = a[i];
        h4 = hb - h5 * hh1;
        hh5 = h5;
        h5 = hc;
    end

    h2 = 0;
    h1 = a[1];
    local j;
    for i = max, 1, -1 do
      j = ifirst + i - 1;
      HPF[j] = a[i] - b[i] * h1 - c[i] * h2;
	  
	open[j] = source.open[j]-HPF[j];
	close[j] = source.close[j]-HPF[j];
	high[j] = source.high[j]-HPF[j];
	low[j] = source.low[j]-HPF[j];
	  
      h2 = h1;
      h1 = HPF[j];
    end

    core.eraseStream(HPF, core.range(0, ifirst - 1));
    core.eraseStream(open, core.range(0, ifirst - 1));
    core.eraseStream(close, core.range(0, ifirst - 1));
    core.eraseStream(high, core.range(0, ifirst - 1));	
    core.eraseStream(low, core.range(0, ifirst - 1));		
end
