-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60923

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

function Init()
    indicator:name("True Strength Index Convergence Divergence");
    indicator:description("Is a variation of the Relative Strength Indicator which uses a doubly-smoothed exponential moving average of price momentum to eliminate choppy price changes and spot trend changes.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Oscillators");

    indicator.parameters:addGroup("Calculation");
	
 
 
    local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1", "Chart"}
    indicator.parameters:addString("TF", "Time Frame", "", "Chart");
	for i = 1, 14, 1 do
	indicator.parameters:addStringAlternative("TF", TF[i], "",  TF[i]);
    end
	
	
    indicator.parameters:addInteger("N", "Long Term", "The number of periods to average the Price Momentum.", 7, 2, 1000);
    indicator.parameters:addInteger("M", "Short Term", "The number of periods to smooth the Average Momentum.", 14, 2, 1000);
	
	indicator.parameters:addString("Method1", "TSI MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("S", "Signal Line Period", "", 14, 2, 1000);
	indicator.parameters:addString("Method2", "Signal MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "TSI Line Color","The color of the True Strength Index line.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Signal Line Color","The color of the Signal line.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addBoolean("ShowHistogram", "Show Histogram", "", true);
	
	
	indicator.parameters:addColor("color3", "Histogram Line Color","The color of the Histogram line.", core.rgb(0, 0, 255));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local S;
local Method2;
local n;
local m;
local Method1;
local first;
local source = nil;
local delta = nil;
local absDelta = nil;
local ema_r1 = nil;
local ema_r2 = nil;
local ema_s1 = nil;
local ema_s2 = nil;
local deltaFirst = nil;
local Signal, Histogram;
local MA;
local ShowHistogram;
-- Streams block
local TSI = nil;
local TF;
-- Routine
function Prepare(nameOnly)

    source = instance.source;
    Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	TF = instance.parameters.TF;
	if TF=="Chart" then
	TF=source:barSize();
	end
	ShowHistogram = instance.parameters.ShowHistogram;
	S = instance.parameters.S;
    n = instance.parameters.N;
    m = instance.parameters.M;
	

	
    local name = profile:id() .. "(" .. source:name().. ", " .. TF .. ", " .. n .. ", " .. m.. ", " .. Method1 .. ", " .. S .. ", " .. Method2  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset"); 
	
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	

 

    TSI = instance:addStream("TSI", core.Line, name, "TSI", instance.parameters.color1, 0);
    TSI:setPrecision(math.max(2, instance.source:getPrecision()));
	TSI:setWidth(instance.parameters.width1);
    TSI:setStyle(instance.parameters.style1);
    TSI:addLevel(0);		
	
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA = core.indicators:create(Method2, TSI, S);
	
	Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2,  0);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
	
	if ShowHistogram then
	Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, 0);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	else
    Histogram = instance:addInternalStream(0, 0);	
	end
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;
	
 	assert(core.indicators:findIndicator("TSICD") ~= nil, "Please, download and install TSICD.LUA indicator"); 
 	Indicator= core.indicators:create("TSICD", Source.close, N, M, Method1, S, Method2);  	 
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


	Indicator:update(mode); 
	
    local p =  Initialization(period) 
     
	if not p 
	or not Indicator.Histogram:hasData(p)
	or not source:hasData(period)
	then
		return;
	end	
		
       
    TSI[period]=Indicator.TSI[p]
	Signal[period]=Indicator.Signal[p]
	Histogram[period]=Indicator.Histogram[p]
   
    
  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
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