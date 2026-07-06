-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=28048
-- Id: 8262

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("DMI Stochastic");
    indicator:description("DMI Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   	
	indicator.parameters:addGroup("DMI Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);	
	
	indicator.parameters:addGroup("Stochastic Calculation");		
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
	
	


    indicator.parameters:addGroup("K Line Style");
	
	indicator.parameters:addString("Out", "Show K/D/Both Lines", "", "K");
    indicator.parameters:addStringAlternative("Out", "K", "K", "K");
    indicator.parameters:addStringAlternative("Out", "D", "D", "D");	
	indicator.parameters:addStringAlternative("Out", "Both", "Both", "B");
	
    indicator.parameters:addColor("KUP", "Up %K line color", "The color of the %K line.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("KDN", "Down %K line color", "The color of the %K line.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger( "KType", "K Line Type", "", core.Line );
    indicator.parameters:addIntegerAlternative("KType", "Line", "", core.Line);
    indicator.parameters:addIntegerAlternative("KType", "Bar", "", core.Bar);
	indicator.parameters:addIntegerAlternative("KType", "Dot", "", core.Dot);
	
	indicator.parameters:addInteger("Kwidth", "K Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Kstyle", "K Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Kstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("D Line Style");
	
    indicator.parameters:addColor("DUP", "Up %D line color", "The color of the %D line.", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DDN", "Down %D line color", "The color of the %D line.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger( "DType", "D Line Type", "", core.Line );
    indicator.parameters:addIntegerAlternative("DType", "Line", "", core.Line);
    indicator.parameters:addIntegerAlternative("DType", "Bar", "", core.Bar);
	indicator.parameters:addIntegerAlternative("DType", "Dot", "", core.Dot);
	
	indicator.parameters:addInteger("Dwidth", "D Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Dstyle", "D Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Dstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 90);
    indicator.parameters:addDouble("oversold","Oversold Level","", 10);
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
local DType, KType;
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
local dmi, DMI;
local Period;
local first;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    Out = instance.parameters.Out
    source = instance.source;
	
	DType = instance.parameters.DType;
	KType = instance.parameters.KType;
	
    averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;

    local name = profile:id() .. "(" .. source:name().. ", " .. Period.. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	dmi = core.indicators:create("DMI", source, Period); 
	first=dmi.DATA:first();
	DMI = instance:addInternalStream(first, 0);
    mins = instance:addInternalStream(first + k, 0);
    maxes = instance:addInternalStream(first + k, 0);
    FastK = instance:addInternalStream(mins:first(), 0);

    fastkFirst = FastK:first();
    if averageTypeK ~= "MT" then
        mva = core.indicators:create(averageTypeK, FastK, sd);
		if Out == "D" then
		K = instance:addInternalStream(mva.DATA:first(), 0);
		else
        K = instance:addStream("K", KType, name .. ".K", "K", instance.parameters.KUP, mva.DATA:first());
		        if KType== core.Line then
				K:setWidth(instance.parameters.Kwidth);
				K:setStyle(instance.parameters.Kstyle);
				end
		end
        isMT = false;
		   K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	       K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    else
	    if Out == "D" then
		K = instance:addInternalStream(FastK:first() + sd, 0);
		else
        K = instance:addStream("K", KType, name .. ".K", "K", instance.parameters.KUP, FastK:first() + sd);
				if KType== core.Line then
				K:setWidth(instance.parameters.Kwidth);
				K:setStyle(instance.parameters.Kstyle);
				end
		end
        isMT = true;
		
		  K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	      K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    end

    kFirst = K:first();
    
    signalLine = core.indicators:create(averageTypeD, K, d);
	 if Out == "K" then
	D = instance:addInternalStream(signalLine.DATA:first(), 0);
	 else
    D = instance:addStream("D", DType, name .. ".D", "D", instance.parameters.DUP, signalLine.DATA:first());
			if DType== core.Line then
			D:setWidth(instance.parameters.Dwidth);
			D:setStyle(instance.parameters.Dstyle);
			end
	  D:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	  D:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    		
	end
    dFirst = D:first();
	
	K:setPrecision(math.max(2, instance.source:getPrecision()));
	D:setPrecision(math.max(2, instance.source:getPrecision()));
		

end

-- Indicator calculation routine
function Update(period, mode)


    dmi:update(mode);
	DMI[period]= dmi.DIP[period]-dmi.DIM[period];
 
     if period >= fastkFirst then
        local minLow, maxHigh = mathex.minmax(DMI, period - k + 1, period);
        mins[period] = DMI[period] - minLow;
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
	
                    	if K[period] > K[period-1] then
						  K:setColor(period, instance.parameters.KUP);
						 else
						   K:setColor(period, instance.parameters.KDN);
						 end
						 
    signalLine:update(mode);
    if period >= dFirst then
        D[period] = signalLine.DATA[period];
		                 if D[period] > D[period-1] then
						  D:setColor(period, instance.parameters.DUP);
						 else
						   D:setColor(period, instance.parameters.DDN);
						 end
    end
end

