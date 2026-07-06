-- Id: 17417
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64325

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MikesOSC");
    indicator:description("For use with MikesMVAStrategy");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	  indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period1", "1. MA Period", "", 1);
	 indicator.parameters:addInteger("Period2", "2. MA Period", "", 50);
	 indicator.parameters:addInteger("Period3", "3. MA Period", "", 100);
	 indicator.parameters:addInteger("Period4", "4. MA Period", "", 200);
	 indicator.parameters:addInteger("Period5", "5. MA Period", "", 500);
	 
	   indicator.parameters:addGroup("Levels");
	 indicator.parameters:addDouble("Level1", "1. Level", "", 1);
	 indicator.parameters:addDouble("Level2", "2. Level", "", 1.0025);
	 indicator.parameters:addDouble("Level3", "3. Level", "", 0.9975);
	 indicator.parameters:addDouble("Level4", "4. Level", "", 1.00125);
	 indicator.parameters:addDouble("Level5", "5. Level", "", 0.99875);
 
	    indicator.parameters:addGroup("Style");
        indicator.parameters:addColor("color", "Line Color ", "Line Color", core.rgb(0, 0, 255));
	    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
		indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
		indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

--local n;
local first;
local source = nil;
local mva1;                 -- the output stream of the MVA(2) indicator
local mva2;                 -- the output stream of the MVA(25) indicator
local mva3;                 -- the output stream of the MVA(50) indicator
local mva4;                 -- the output stream of the MVA(100) indicator
local mva5;                 -- the output stream of the MVA(200) indicator
local graceavg;
local gracebl1;
local gracebl2;
local gracebl3;
local gracebl4;
local gracebl5;
local gracedev;

-- Streams block
local S1 = nil;
local S2 = nil;
local S3 = nil;
local S4 = nil;
local S5 = nil;
local S6 = nil;
local Period1,Period2,Period3,Period4, Period5;
local Level1,Level2,Level3,Level4, Level5;
-- Routine
function Prepare(nameOnly)

    source = instance.source;
    first = source:first();
	
	
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Period4= instance.parameters.Period4;
	Period5= instance.parameters.Period5;
	Level1= instance.parameters.Level1;
	Level2= instance.parameters.Level2;
	Level3= instance.parameters.Level3;
	Level4= instance.parameters.Level4;
	Level5= instance.parameters.Level5;
 

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    mva1 = core.indicators:create("MVA", source, Period1);
    mva2 = core.indicators:create("MVA", source, Period2);
    mva3 = core.indicators:create("MVA", source, Period3);
    mva4 = core.indicators:create("MVA", source, Period4);
    mva5 = core.indicators:create("MVA", source, Period5);
    
	first = math.max(mva1.DATA:first(), mva2.DATA:first(), mva3.DATA:first(), mva4.DATA:first(), mva5.DATA:first());
    
    graceavg = instance:addInternalStream(source:first(), 0);
    gracebl1 = instance:addInternalStream(source:first(), 0);
    gracebl2 = instance:addInternalStream(source:first(), 0);
    gracebl3 = instance:addInternalStream(source:first(), 0);
    gracebl4 = instance:addInternalStream(source:first(), 0);
    gracebl5 = instance:addInternalStream(source:first(), 0);
    S1 = instance:addInternalStream(source:first(), 0);
    S2 = instance:addInternalStream(source:first(), 0);
    S3 = instance:addInternalStream(source:first(), 0);
    S4 = instance:addInternalStream(source:first(), 0);
    S5 = instance:addInternalStream(source:first(), 0);
    gracedev = instance:addInternalStream(source:first(), 0);


    if (not (nameOnly)) then

        S6 = instance:addStream("S6", core.Line, name .. ".S6", "S6", instance.parameters.color, first);
    S6:setPrecision(math.max(2, instance.source:getPrecision()));
        S6:addLevel(Level1, instance.parameters.level_baselinesold_style, instance.parameters.level_baselinesold_width, core.rgb(255, 0, 0));
        S6:addLevel(Level2, instance.parameters.level_baselinesold_style, instance.parameters.level_baselinesold_width, core.rgb(255, 255, 0));
        S6:addLevel(Level3, instance.parameters.level_baselinesold_style, instance.parameters.level_baselinesold_width, core.rgb(255, 255, 0));
        S6:addLevel(Level4, instance.parameters.level_baselinesold_style, instance.parameters.level_baselinesold_width, core.rgb(0, 255, 255));
        S6:addLevel(Level5, instance.parameters.level_baselinesold_style, instance.parameters.level_baselinesold_width, core.rgb(0, 255, 255));
		S6:setWidth(instance.parameters.width);
        S6:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    mva1:update(mode);
    mva2:update(mode);
    mva3:update(mode);
    mva4:update(mode);
    mva5:update(mode);
    
        -- Check that we have enough data
    if (mva1.DATA:first() > (period - 1)) then
        return
    end
    if (mva2.DATA:first() > (period - 1)) then
        return
    end
    if (mva3.DATA:first() > (period - 1)) then
        return
    end
    if (mva4.DATA:first() > (period - 1)) then
        return
    end
    if (mva5.DATA:first() > (period - 1)) then
        return
    end
   
    
    
    if period >= first and source:hasData(period) then
    --    graceavg[period] = ((mva1.DATA[period]/source[period]) +(mva2.DATA[period]/source[period]) + (mva3.DATA[period]/source[period])+ (mva4.DATA[period]/source[period]))/4;
        gracebl1[period] = mva1.DATA[period]/source[period];
        gracebl2[period] = mva2.DATA[period]/source[period];
        gracebl3[period] = mva3.DATA[period]/source[period];
        gracebl4[period] = mva4.DATA[period]/source[period];
        gracebl5[period] = mva5.DATA[period]/source[period];
    
        if gracebl1[period] >= 0 then
            S1[period] = gracebl1[period];
            else S1[period] = gracebl1[period]*-1;
            end
        if gracebl2[period] >= 0 then
            S2[period] = gracebl2[period];
            else S2[period] = gracebl2[period]*-1;
            end
        if gracebl3[period] >= 0 then    
            S3[period] = gracebl3[period];
            else S3[period] = gracebl3[period]*-1;
            end
        if gracebl4[period] >= 0 then
            S4[period] = gracebl4[period];
            else S4[period] = gracebl4[period]*-1;
            end
        if gracebl5[period] >= 0 then
            S5[period] = gracebl5[period];
            else S5[period] = gracebl5[period]*-1;
            end    
        gracedev[period] =((S1[period] + S2[period] + S3[period] + S4[period] + S5[period])/5);
        S6[period] = gracedev[period];
        
    end
end
