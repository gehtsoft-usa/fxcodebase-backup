-- Id: 12174

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9566

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bar Based Stochastic");
    indicator:description("Bar Based Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addString("Out", "Show K/D/Both Lines", "", "B");
    indicator.parameters:addStringAlternative("Out", "K", "K", "K");
    indicator.parameters:addStringAlternative("Out", "D", "D", "D");	
	 indicator.parameters:addStringAlternative("Out", "Both", "Both", "B");
	 
		
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", "%K line color", "The color of the %K line.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Kwidth", "K Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Kstyle", "K Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Kstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrSecond", "%D line color", "The color of the %D line.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Dwidth", "D Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Dstyle", "D Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Dstyle", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addColor("clrUp", "Histogram Up Color","", core.rgb(0, 255, 0));
     indicator.parameters:addColor("clrDown", "Histogram Down Color","", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","",30);
    indicator.parameters:addDouble("oversold","Oversold Level","",  -30);
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

-- Streams block
local K = nil;
local D = nil;
local Out;
local DATA=nil; 
local Histogram;
-- Routine
function Prepare(nameOnly)
    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    Out= instance.parameters.Out
    source = instance.source;
	
    
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
        mva = core.indicators:create(averageTypeK, FastK, sd);
		if Out == "D" then
		K = instance:addInternalStream(mva.DATA:first(), 0);
		else
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, mva.DATA:first());
		K:setWidth(instance.parameters.Kwidth);
        K:setStyle(instance.parameters.Kstyle);
		end
        isMT = false;
    else
	    if Out == "D" then
		K = instance:addInternalStream(FastK:first() + sd, 0);
		else
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, FastK:first() + sd);
		K:setWidth(instance.parameters.Kwidth);
        K:setStyle(instance.parameters.Kstyle);
		end
        isMT = true;
    end

    kFirst = K:first();
    
    signalLine = core.indicators:create(averageTypeD, K, d);
	 if Out == "K" then
	D = instance:addInternalStream(signalLine.DATA:first(), 0);
	 else
    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond, signalLine.DATA:first());
	D:setWidth(instance.parameters.Dwidth);
    D:setStyle(instance.parameters.Dstyle);
	end
    dFirst = D:first();
	
	K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
   K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
    	
   D:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
   D:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
  
  
   Histogram= instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.clrUp, K:first() + d - 1);
   
   K:setPrecision(math.max(2, instance.source:getPrecision()));
   D:setPrecision(math.max(2, instance.source:getPrecision()));
   Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
 
      if period >= fastkFirst then
        local minLow, maxHigh = mathex.minmax(source, period - k + 1, period);
        mins[period] = source.close[period] - minLow;
        maxes[period] = maxHigh - minLow;
        if maxes[period] > 0 then
            FastK[period] = mins[period] / maxes[period] * 100-50;
        else
            FastK[period] = 0;
        end
    end
	
	
    if isMT == false then
        mva:update(mode);
        if period >= kFirst then
            K[period] = mva.DATA[period];
        end
    else
        if period >= kFirst then
           -- local dRange = core.rangeTo(period, sd);
           local sumMax = mathex.sum(maxes, period-sd+1,period);
            if sumMax == 0 then
                K[period] = 50;
            else
                local sumMin= mathex.sum(mins, period-sd+1,period); 
                K[period] = sumMin / sumMax * 100-50;
            end
        end
    end
    signalLine:update(mode);
    if period >= dFirst then
        D[period] = signalLine.DATA[period];
    end
	
	Histogram[period]=K[period]-D[period];
		
		if Histogram[period] >Histogram[period-1] then
		Color = instance.parameters.clrUp;
		else
		Color = instance.parameters.clrDown;
		end
		
		Histogram:setColor(period, Color);

end