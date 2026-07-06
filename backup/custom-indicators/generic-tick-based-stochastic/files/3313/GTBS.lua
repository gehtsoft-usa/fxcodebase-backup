-- Id: 1148

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1667

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Generic Tick Based Stochastic");
    indicator:description("Generic Tick Based Stochastic");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("T", "Data Source", "Data Source","Tick");
	indicator.parameters:addStringAlternative("T", "Tick", "Tick" , "Tick");
	indicator.parameters:addStringAlternative("T", "MACD", "MACD" , "MACD");
	indicator.parameters:addStringAlternative("T", "RSI", "RSI" , "RSI");
    indicator.parameters:addStringAlternative("T", "ROC", "ROC" , "ROC");
	
	
   -- indicator.parameters:addInteger("K", "Stochastic Period", "Stochastic Period", 5, 2,  math.abs(math.huge));
     indicator.parameters:addInteger("K", "Stochastic Period", "Stochastic Period", 5, 2,  100000);
    indicator.parameters:addInteger("SD", "Smoothing period for %K", "Smoothing period for %K", 3, 1, 100000);
    indicator.parameters:addInteger("D", "Smoothing period for %D", "Smoothing period for %D", 3, 2, 100000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT");
    
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", "%K line color", "The color of the %K line.", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrSecond", "%D line color", "The color of the %D line.", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local k;
local d;
local sd;
local Type;
local averageTypeK = nil;
local averageTypeD = nil;

local source = nil;
local mins = nil;
local maxes = nil;
local mva = nil;
local FastK = nil;
local fastkFirst = nil;
local kFirst = nil;
local dFirst = nil;
local isMT = nil;

-- Streams block
local K = nil;
local D = nil;

local DATA=nil; 

-- Routine
function Prepare(nameOnly)
    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
	Type = instance.parameters.T;
	
    source = instance.source;
	
   

   
    
    averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;

    local name = profile:id() .. "(" .. source:name().. ", "..Type .. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 mins = instance:addInternalStream(source:first() + k, 0);
    maxes = instance:addInternalStream(source:first() + k, 0);
    FastK = instance:addInternalStream(mins:first(), 0);
	
	 fastkFirst = FastK:first();
	
    if averageTypeK ~= "MT" then
    assert(core.indicators:findIndicator(averageTypeK) ~= nil, averageTypeK .. " indicator must be installed");
        mva = core.indicators:create(averageTypeK, FastK, sd);
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, mva.DATA:first());
        isMT = false;
    else
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, FastK:first() + sd);
        isMT = true;
    end
    K:setPrecision(math.max(2, instance.source:getPrecision()));
   
    kFirst = K:first();
    
    assert(core.indicators:findIndicator(averageTypeD) ~= nil, averageTypeD .. " indicator must be installed");
    signalLine = core.indicators:create(averageTypeD, K, d);
    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond, signalLine.DATA:first());
    D:setPrecision(math.max(2, instance.source:getPrecision()));
    dFirst = D:first();
	
	if Type ~= "Tick" then
	
		if  Type == "MACD" then
		DATA =  core.indicators:create("MACD", source, 12,26,9);
		end
		
		if  Type == "RSI" then
		DATA =  core.indicators:create("RSI", source, 14);
		end
		
		if  Type == "ROC" then
		DATA =  core.indicators:create("ROC", source, 14);
		end		
		
	end
	
    D:addLevel(20);
    D:addLevel(80);

end

-- Indicator calculation routine
function Update(period, mode)
 
 
    if period >= fastkFirst then
        local kRange = core.rangeTo(period, k);
		
		local minLow=nil;
		local maxHigh =nil;		
		
		if Type == "Tick" then
        minLow = core.min(source, kRange);
        maxHigh = core.max(source, kRange);
        mins[period] = source[period] - minLow;
		
		        maxes[period] = maxHigh - minLow;
				if maxes[period] > 0 then
					FastK[period] = mins[period] / maxes[period] * 100;
				else
					FastK[period] = 50;
				end
		
		
		
		else
		       
			   maxHigh=nil;
						DATA:update(mode);
						
						
								if Type == "MACD" and   period >DATA.MACD:first() +  k then 
								minLow = core.min(DATA.MACD, kRange);
								maxHigh = core.max(DATA.MACD, kRange);
								mins[period] = DATA.MACD[period] - minLow; 
								end
								
								if Type == "RSI"  and   period > DATA.RSI:first() + k then 
								minLow = core.min(DATA.RSI, kRange);
								maxHigh = core.max(DATA.RSI, kRange);
								mins[period] = DATA.RSI[period] - minLow; 
								end
								
								if Type == "ROC" and   period > DATA.ROC:first()  + k then 
								minLow = core.min(DATA.ROC, kRange);
								maxHigh = core.max(DATA.ROC, kRange);
								mins[period] = DATA.ROC[period] - minLow; 
								end
								
								if maxHigh == nil then
								return;
								end
								
								maxes[period] = maxHigh - minLow;
								if maxes[period] > 0 then
									FastK[period] = mins[period] / maxes[period] * 100;
								else
									FastK[period] = 50;
				                 end
								
						 
				 
				
				
		 end
				
    end
    if isMT == false then
        mva:update(mode);
        if period >= kFirst then
            K[period] = mva.DATA[period];
        end
    else
        if period >= kFirst then
            local dRange = core.rangeTo(period, sd);
            local sumMax = core.sum(maxes, dRange);
            if sumMax == 0 then
                K[period] = 50;
            else
                local sumMin = core.sum(mins, dRange);
                K[period] = sumMin / sumMax * 100;
            end
        end
    end
    signalLine:update(mode);
    if period >= dFirst then
        D[period] = signalLine.DATA[period];
    end
end

