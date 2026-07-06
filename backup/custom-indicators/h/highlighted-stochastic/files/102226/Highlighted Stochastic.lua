-- Id: 14789
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62636

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

function Init()
    indicator:name("Highlighted Stochastic");
    indicator:description("Highlighted Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");
 
		
    indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT");
	indicator.parameters:addStringAlternative("MVAT_K" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "WMA", "", "WMA");	
    
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MVAT_D" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "WMA", "", "WMA");	

    indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("UpColor", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DownColor", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);

	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local k;
local d;
local sd;
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
local UpColor,DownColor;
-- Streams block
local K = nil;
local D = nil; 
local DATA=nil; 

-- Routine
function Prepare(nameOnly)
    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD; 
    source = instance.source;
	UpColor = instance.parameters.UpColor;
	DownColor = instance.parameters.DownColor;
    averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;
    local name = profile:id() .. "(" .. source:name().. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    mins = instance:addInternalStream(source:first() + k, 0);
    maxes = instance:addInternalStream(source:first() + k, 0);
    FastK = instance:addInternalStream(mins:first(), 0);

    fastkFirst = FastK:first();
    

    if averageTypeK ~= "MT" then
    assert(core.indicators:findIndicator(averageTypeK) ~= nil, averageTypeK .. " indicator must be installed");
        mva = core.indicators:create(averageTypeK, FastK, sd);
	 
        K = instance:addStream("K", core.Line, name .. ".K", "K", UpColor, mva.DATA:first()); 
        isMT = false;
		   K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	       K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    else
	    
        K = instance:addStream("K", core.Line, name .. ".K", "K", UpColor, FastK:first() + sd); 
        isMT = true;
		
		  K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	      K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    end
    K:setPrecision(math.max(2, instance.source:getPrecision()));
    
    kFirst = K:first();
    
    assert(core.indicators:findIndicator(averageTypeD) ~= nil, averageTypeD .. " indicator must be installed");
    signalLine = core.indicators:create(averageTypeD, K, d);
 
    D = instance:addStream("D", core.Line, name .. ".D", "D", UpColor, signalLine.DATA:first()); 
    D:setPrecision(math.max(2, instance.source:getPrecision()));
	 
    dFirst = D:first();
	
	
		
     instance:createChannelGroup("ch", "ch", K, D, UpColor, 100 - instance.parameters.transparency);

end

-- Indicator calculation routine
function Update(period, mode)
 
     if period >= fastkFirst then
        local minLow, maxHigh = mathex.minmax(source, period - k + 1, period);
        mins[period] = source.close[period] - minLow;
        maxes[period] = maxHigh - minLow;
        if maxes[period] > 0 then
            FastK[period] = mins[period] / maxes[period] * 100;
        else
            FastK[period] = 50;
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
	
    if period < dFirst then
	return;
	end
	
                          D[period] = signalLine.DATA[period];
						  
		                  if K[period] > D[period] then
						  D:setColor(period, UpColor);
						  K:setColor(period, UpColor);
						 else
						    D:setColor(period, DownColor);
						  K:setColor(period, DownColor);
						 end 
    
end

