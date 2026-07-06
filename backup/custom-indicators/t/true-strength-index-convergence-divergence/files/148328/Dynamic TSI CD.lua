-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=60923

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
    indicator:name("Dynamic DTrue Strength Index Convergence Divergence");
    indicator:description("Is a variation of the Relative Strength Indicator which uses a doubly-smoothed exponential moving average of price momentum to eliminate choppy price changes and spot trend changes.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Oscillators");

    indicator.parameters:addGroup("Calculation");
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
	
	
	indicator.parameters:addColor("color3", "Histogram Line Color","The color of the Histogram line.", core.rgb(0, 0, 255));
		
		
    indicator.parameters:addGroup("OB Style");		
	indicator.parameters:addColor("color4", "Signal Line Color","The color of the Signal line.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_DASH );
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);


    indicator.parameters:addGroup("OS Style");		
	indicator.parameters:addColor("color5", "Signal Line Color","The color of the Signal line.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_DASH  );
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);	
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
-- Streams block
local TSI = nil;

-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	S = instance.parameters.S;
    n = instance.parameters.N;
    m = instance.parameters.M;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ", " .. m.. ", " .. Method1 .. ", " .. S .. ", " .. Method2  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    delta = instance:addInternalStream(source:first() + 1, 0);
    absDelta = instance:addInternalStream(source:first() + 1, 0);
    deltaFirst = delta:first();
    
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    ema_r1 = core.indicators:create(Method1, delta, n);
    ema_r2 = core.indicators:create(Method1, absDelta, n);
    ema_s1 = core.indicators:create(Method1, ema_r1.DATA, m);
    ema_s2 = core.indicators:create(Method1, ema_r2.DATA, m);
    
    first = ema_s1.DATA:first();
    TSI = instance:addStream("TSI", core.Line, name, "TSI", instance.parameters.color1, first);
    TSI:setPrecision(math.max(2, instance.source:getPrecision()));
	TSI:setWidth(instance.parameters.width1);
    TSI:setStyle(instance.parameters.style1);
	
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA = core.indicators:create(Method2, TSI, S);
	
	Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color2,  MA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
	
	Histogram = instance:addStream("Histogram", core.Bar, name, "Histogram", instance.parameters.color3, MA.DATA:first());
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	OB = instance:addStream("OB", core.Line, name, "OB", instance.parameters.color4, first);
    OB:setPrecision(math.max(2, instance.source:getPrecision()));
	OB:setWidth(instance.parameters.width4);
    OB:setStyle(instance.parameters.style4);


	OS = instance:addStream("OS", core.Line, name, "OS", instance.parameters.color5, first);
    OS:setPrecision(math.max(2, instance.source:getPrecision()));
	OS:setWidth(instance.parameters.width5);
    OS:setStyle(instance.parameters.style5);	 
end

-- Indicator calculation routine
function Update(period, mode)
    if period < deltaFirst then
	return;
	end
        delta[period] = source[period] - source[period - 1];
        absDelta[period] = math.abs(delta[period]);
   
    
    ema_r1:update(mode);
    ema_r2:update(mode);
    ema_s1:update(mode);
    ema_s2:update(mode);
    
    if period < first then
	return;
	end
        if ema_s2.DATA[period] == 0 then
            TSI[period] = 0;
        else
            TSI[period] = 100 * ema_s1.DATA[period] / ema_s2.DATA[period];
        end
	MA:update(mode);
     
	if period < MA.DATA:first() then
    return;
    end
	
	Signal[period]= MA.DATA[period];
	
	Histogram[period]= TSI[period]-Signal[period];
	
	
	local Level1 = FindTop(period);
	local Level2 = FindBottom(period);	

 
	OS[period]= OS[period-1];	
	OB[period]= OB[period-1];	
	
	if Level1 ~= false then	
	OB[period]= Level1; 
	end
	
	if Level2 ~= false then		
	OS[period]= Level2;
    end	
end

function FindTop(period)

local Return=false;


       if TSI[period] < Signal[period]
	   and  TSI[period-1] >= Signal[period-1]
	   then
	        
			
			for i= period-1, source:first(), -1 do
				if TSI[i]>TSI[i-1] then
				Return=TSI[i]
				break;
				end
			end
	   
	   end


return Return;

end


function FindBottom(period)


local Return=false;


       if TSI[period] > Signal[period]
	   and  TSI[period-1] <= Signal[period-1]
	   then
	        
			
			for i= period-1, source:first(), -1 do
				if TSI[i]<TSI[i-1] then
				Return=TSI[i]
				break;
				end
			end
	   
	   end


return Return;

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