-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4037

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Better Volume Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "GSL");
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("N", "Average Period", "No description", 20);
    indicator.parameters:addInteger("Back", "Analyse Period Back", "No description", 20);
    indicator.parameters:addBoolean("TwoBars", "Use TwoBars", "No description", false);
    
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("LowVol_color", "Color of LowVol_color", "Color of LowVol_color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("ClimaxUp_color", "Color of ClimaxUp", "Color of ClimaxUp", core.rgb(255, 0, 0));
    indicator.parameters:addColor("ClimaxDn_color", "Color of ClimaxDn", "Color of ClimaxDn", core.rgb(255, 255, 255));
    indicator.parameters:addColor("DensityUp_color", "Color of Churn", "Color of DensityUp", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DensityDn_color", "Color of ClimaxChurn", "Color of DensityDn", core.rgb(255, 0, 128));
    indicator.parameters:addColor("VolumeBar_color", "Color of VolumeBar", "Color of VolumeBar", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local Back;

local first;
local source = nil;

-- Streams block
local ClimaxUp = nil;
local ClimaxDn = nil;
local DensityUp = nil;
local DensityDn = nil;   
-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    Back = instance.parameters.Back; 
    source = instance.source;
    first = source:first() + N + Back -1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(N) .. ", " .. tostring(Back) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	
        Value1 = instance:addInternalStream(0,0);
        Value2 = instance:addInternalStream(0,0);
        Value3 = instance:addInternalStream(0,0);
        Value4 = instance:addInternalStream(0,0);
        Value5 = instance:addInternalStream(0,0);
        Value6 = instance:addInternalStream(0,0);
        Value7 = instance:addInternalStream(0,0);
        Value8 = instance:addInternalStream(0,0);
        Value9 = instance:addInternalStream(0,0);
        Value10 = instance:addInternalStream(0,0);
        Value11 = instance:addInternalStream(0,0);
        Value12 = instance:addInternalStream(0,0);
        Value13 = instance:addInternalStream(0,0);
        Value14 = instance:addInternalStream(0,0);
        Value15 = instance:addInternalStream(0,0);
        Value16 = instance:addInternalStream(0,0);
        Value17 = instance:addInternalStream(0,0);
        Value18 = instance:addInternalStream(0,0);
        Value19 = instance:addInternalStream(0,0);
        Value20 = instance:addInternalStream(0,0);
        Value21 = instance:addInternalStream(0,0);
        Value22 = instance:addInternalStream(0,0);
        
		
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
       local p = period;
        local HIGH = source.high[period];
        local LOW = source.low[period];
        local OPEN = source.open[period];
        local CLOSE = source.close[period];
        local VOLUME = source.volume[period];
  
  
    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	open:setColor(period, instance.parameters.VolumeBar_color); -- Fix to ensure default bar colour is correct
 
    
    if period < first   then
	
	    Value1[p] = 0;
        Value2[p] = 0;
        Value3[p] = 0;
        Value4[p] = 0;
        Value5[p] = 0;
        Value6[p] = 0;
        Value7[p] = 0;
        Value8[p] = 0;
        Value9[p] = 0;
        Value10[p] = 0;
        Value11[p] = 0;
        Value12[p] = 0;
        Value13[p] = 0;
        Value14[p] = 0;
        Value15[p] = 0;
        Value16[p] = 0;
        Value17[p] = 0;
        Value18[p] = 0;
        Value19[p] = 0;
        Value20[p] = 0;
        Value21[p] = 0;
        Value22[p] = 0;
		
		
	return;
	end
      
   
            Range = HIGH-LOW;
         

        if  CLOSE > OPEN then
            Value1[p] = VOLUME*(Range/(2*Range + OPEN - CLOSE));
        elseif CLOSE < OPEN then
            Value1[p] = VOLUME*((Range + CLOSE-OPEN)/(2*Range + CLOSE-OPEN));
        end
        if CLOSE == OPEN then
            Value1[p] = 0.5*VOLUME;
        end
        Value2[p] =     VOLUME - Value1[p];
        Value3[p] =     Value1[p] + Value2[p];
        Value4[p] =     Value1[p] * Range;
        Value5[p] = (   Value1[p]-Value2[p])*Range
        Value6[p] =     Value2[p]*Range;
        Value7[p] = (   Value2[p]-Value1[p])*Range;
        if Range ~= 0 then
            Value8[p]  =    Value1[p]/Range;
            Value9[p]  = (  Value1[p]-Value2[p])/Range;
            Value10[p] =    Value2[p]/Range;
            Value11[p] = (  Value2[p]-Value1[p])/Range;
            Value12[p] =    Value3[p]/Range;
        end

        Value13[p] = Value3[p] + Value3[p-1];
        Value14[p] = (Value1[p]+Value1[p-1])*(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value15[p] = (Value1[p]+Value1[p-1] - Value2[p] - Value2[p-1]) * (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value16[p] = (Value2[p]+Value2[p-1])*(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value17[p] = (Value2[p]+Value2[p-1] - Value1[p] - Value1[p-1]) * (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        if mathex.max(source.high,p-2+1,p) ~= mathex.min(source.low,p-2+1,p) then
            Value18[p] = (Value1[p] + Value1[p-1])/(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        end
        Value19[p] = (Value1[p]+Value1[p-1] - Value2[p] - Value2[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value20[p] = (Value2[p]+Value2[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value21[p] = (Value2[p]+Value2[p-1] - Value1[p] - Value1[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value22[p] = Value13[p]/(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));

        open:setColor(period, instance.parameters.VolumeBar_color); -- Fix to ensure default bar colour is correct
        
        if not instance.parameters.TwoBars then
            --Con 1 or Con 11
            if (Value3[p] == mathex.min(Value3,p-Back+1,p)) then  -- Yellow -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                open:setColor(period,instance.parameters.LowVol_color);
            end
            --Con 2 or Con 3 or Con 8 or Con 9 or Con 12 or Con 13 or Con 18 or con 19
            if (Value4[p] == mathex.max(Value4,p-Back+1,p) and CLOSE > OPEN) or
               (Value5[p] == mathex.max(Value5,p-Back+1,p) and CLOSE > OPEN) or
               (Value10[p] == mathex.min(Value10,p-Back+1,p) and CLOSE > OPEN) or 
               (Value11[p] == mathex.min(Value11,p-Back+1,p) and CLOSE > OPEN) then  --RED -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                open:setColor(period,instance.parameters.ClimaxUp_color);
            end
            --Con 4 or Con 5 or Con 6 or Con 7 or Con 14 or Con 15 or Con 16 or con 17
            if (Value6[p] == mathex.max(Value6,p-Back+1,p) and CLOSE < OPEN) or
               (Value7[p] == mathex.max(Value7,p-Back+1,p) and CLOSE < OPEN) or
               (Value8[p] == mathex.min(Value8,p-Back+1,p) and CLOSE < OPEN) or 
               (Value9[p] == mathex.min(Value9,p-Back+1,p) and CLOSE < OPEN) then -- White
                open:setColor(period,instance.parameters.ClimaxDn_color);
            end
            -- Churn Con 10
            if Value12[p] == mathex.max(Value12,p-Back+1,p) then -- Green
                open:setColor(period,instance.parameters.DensityUp_color);
            end
            --ClimaxChurn
            if (Value12[p] == mathex.max(Value12,p-Back+1,p) ) and 
               (    (Value4[p] == mathex.max(Value4,p-Back+1,p) and CLOSE > OPEN) or
                    (Value5[p] == mathex.max(Value5,p-Back+1,p) and CLOSE > OPEN) or
                    (Value10[p] == mathex.min(Value10,p-Back+1,p) and CLOSE > OPEN) or 
                    (Value11[p] == mathex.min(Value11,p-Back+1,p) and CLOSE > OPEN) or
                    (Value6[p] == mathex.max(Value6,p-Back+1,p) and CLOSE < OPEN) or
                    (Value7[p] == mathex.max(Value7,p-Back+1,p) and CLOSE < OPEN) or
                    (Value8[p] == mathex.min(Value8,p-Back+1,p) and CLOSE < OPEN) or 
                    (Value9[p] == mathex.min(Value9,p-Back+1,p) and CLOSE < OPEN) ) then
                open:setColor(period,instance.parameters.DensityDn_color);
            end
        else
            --Con 1 or Con 11
            if (Value13[p] == mathex.min(Value13,p-Back+1,p)) then  -- Yellow -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                open:setColor(period,instance.parameters.LowVol_color);
            end
            --Con 2 or Con 3 or Con 8 or Con 9 or Con 12 or Con 13 or Con 18 or con 19
            if ((Value14[p] == mathex.max(Value14,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
               ((Value15[p] == mathex.max(Value15,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
               ((Value20[p] == mathex.min(Value20,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or 
               ((Value21[p] == mathex.min(Value21,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) then  --RED -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
                open:setColor(period,instance.parameters.ClimaxUp_color);
            end
            --Con 4 or Con 5 or Con 6 or Con 7 or Con 14 or Con 15 or Con 16 or con 17
            if ((Value16[p] == mathex.max(Value16,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
               ((Value17[p] == mathex.max(Value17,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
               ((Value18[p] == mathex.min(Value18,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or 
               ((Value19[p] == mathex.min(Value19,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) then -- White
                open:setColor(period,instance.parameters.ClimaxDn_color);
            end
            -- Churn Con 10
            if Value22[p] == mathex.max(Value22,p-Back+1,p) then -- Green
                open:setColor(period,instance.parameters.DensityUp_color);
            end
            --ClimaxChurn
            if (Value22[p] == mathex.max(Value22,p-Back+1,p) ) and 
               (    ((Value14[p] == mathex.max(Value14,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
                    ((Value15[p] == mathex.max(Value15,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
                    ((Value20[p] == mathex.min(Value20,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or 
                    ((Value21[p] == mathex.min(Value21,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
                    ((Value16[p] == mathex.max(Value16,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
                    ((Value17[p] == mathex.max(Value17,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
                    ((Value18[p] == mathex.min(Value18,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or 
                    ((Value19[p] == mathex.min(Value19,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) ) then
                open:setColor(period,instance.parameters.DensityDn_color);
            end
        end
   
end



