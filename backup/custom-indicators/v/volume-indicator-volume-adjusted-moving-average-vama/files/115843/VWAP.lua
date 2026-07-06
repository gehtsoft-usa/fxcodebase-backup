-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2349

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volume Weighted Average Price (VWAP)");
    indicator:description("Volume Weighted Average Price (VWAP)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Volume Indicators");
   
    indicator.parameters:addGroup("Band Parameters");
    indicator.parameters:addBoolean("BAND", "Show Bands", "" , true);   
    indicator.parameters:addDouble("ONE", "First Multiplier", "" , 1);
    indicator.parameters:addDouble("TWO", "Second Multiplier", "" , 2);
    indicator.parameters:addDouble("THREE", "Third Multiplier", "" , 3);
    indicator.parameters:addGroup("Price Type");
    indicator.parameters:addString("Type", "CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("Type", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("Type", "LOW", "", "L");
    indicator.parameters:addStringAlternative("Type","CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type", "MEDIAN", "", "M");
    indicator.parameters:addStringAlternative("Type", "TYPICAL", "", "T");
    indicator.parameters:addStringAlternative("Type", "WEIGHTED", "", "W");
   
   
    indicator.parameters:addInteger("width","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("VAMA_color", "Color of VWAP Line", "", core.rgb(0, 0, 255));
   
    indicator.parameters:addGroup("First band Line Style");
    indicator.parameters:addInteger("widthONE","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleONE", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleONE", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("ONE_color", "Band Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addBoolean("paint_first_second_channel", "Paint first-second channel", "", false);
    indicator.parameters:addColor("first_second_channel_color", "First-second channel color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("first_second_channel_transp", "First-second channel transparency", "", 80, 0, 100);

    indicator.parameters:addGroup("Second band Line Style");
    indicator.parameters:addInteger("widthTWO","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleTWO", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTWO", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("TWO_color", "Band Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addBoolean("paint_second_third_channel", "Paint second-third channgel", "", false);
    indicator.parameters:addColor("second_third_channel_color", "First-second channel color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("second_third_channel_transp", "First-second channel transparency", "", 80, 0, 100);

    indicator.parameters:addGroup("Third band Line Style");
    indicator.parameters:addInteger("widthTHREE","Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleTHREE", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTHREE", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("THREE_color", "Band Color", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries

local first;
local source = nil;
local PriceTimesVolume;
local VAMA = nil;
local host;
local offset;
local weekoffset;
local s=nil
local e=nil;
local START=nil;
local Type;
local p;
local RAW;
local DEV;
local UP={};
local DOWN={};
local BAND;
local ONE;
local TWO;
local THREE;

function Prepare(nameOnly)  
    ONE=instance.parameters.ONE;
    TWO=instance.parameters.TWO;
    THREE=instance.parameters.THREE
    Type=instance.parameters.Type;
    BAND=instance.parameters.BAND;
    source = instance.source;
    first = source:first();
	
	  local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    if Type == "O" then
        p = source.open;
    elseif Type == "H" then
        p = source.high;
    elseif Type == "L" then
        p = source.low;
    elseif Type == "M" then
        p = source.median;
    elseif Type == "T" then
        p = source.typical;
    elseif Type == "W" then
        p = source.weighted;
    else
        p = source.close;
    end
   
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    PriceTimesVolume = instance:addInternalStream(first,0);   

  
    VAMA = instance:addStream("VAMA", core.Line, name, "VAMA", instance.parameters.VAMA_color, first);
    VAMA:setWidth(instance.parameters.width);
    VAMA:setStyle(instance.parameters.style);

    if BAND then
        RAW=instance:addInternalStream (first, 0)
        UP[1] = instance:addStream("UP"..1, core.Line, name, "UP 1", instance.parameters.ONE_color, first);
        UP[1]:setWidth(instance.parameters.widthONE);
        UP[1]:setStyle(instance.parameters.styleONE);
        DOWN[1] = instance:addStream("DOWN"..1, core.Line, name, "DOWN 1", instance.parameters.ONE_color, first);
        DOWN[1]:setWidth(instance.parameters.widthONE);
        DOWN[1]:setStyle(instance.parameters.styleONE);
        UP[2] = instance:addStream("UP"..2, core.Line, name, "UP 2", instance.parameters.TWO_color, first);
        UP[2]:setWidth(instance.parameters.widthTWO);
        UP[2]:setStyle(instance.parameters.styleTWO);
        DOWN[2] = instance:addStream("DOWN"..2, core.Line, name, "DOWN 2", instance.parameters.TWO_color, first);
        DOWN[2]:setWidth(instance.parameters.widthTWO);
        DOWN[2]:setStyle(instance.parameters.styleTWO);
        UP[3] = instance:addStream("UP"..3, core.Line, name, "UP 3", instance.parameters.THREE_color, first);
        UP[3]:setWidth(instance.parameters.widthTHREE);
        UP[3]:setStyle(instance.parameters.styleTHREE);
        DOWN[3] = instance:addStream("DOWN"..3, core.Line, name, "DOWN 3", instance.parameters.THREE_color, first);
        DOWN[3]:setWidth(instance.parameters.widthTHREE);
        DOWN[3]:setStyle(instance.parameters.styleTHREE);

        if instance.parameters.paint_first_second_channel then
            instance:createChannelGroup("up1-up2", "up1-up2", UP[1], UP[2], instance.parameters.first_second_channel_color, 100 - instance.parameters.first_second_channel_transp);
            instance:createChannelGroup("dn1-dn2", "dn1-dn2", DOWN[1], DOWN[2], instance.parameters.first_second_channel_color, 100 - instance.parameters.first_second_channel_transp);
        end
        if instance.parameters.paint_second_third_channel then
            instance:createChannelGroup("up2-up3", "up2-up3", UP[2], UP[3], instance.parameters.second_third_channel_color, 100 - instance.parameters.second_third_channel_transp);
            instance:createChannelGroup("dn2-dn3", "dn2-dn3", DOWN[2], DOWN[3], instance.parameters.second_third_channel_color, 100 - instance.parameters.second_third_channel_transp);
        end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then
        if core.getcandle("D1", source:date(period),0, 0) ~= s then
            s, e = core.getcandle("D1", source:date(period),0, 0);
            START = core.findDate (source, s, false);    
        end

        PriceTimesVolume[period]=p[period] *source.volume[period];
      
        if START ~= -1 then      
            VAMA[period] = core.sum(PriceTimesVolume,core.range(START,period))/core.sum(source.volume,core.range(START, period));   
            
            if BAND then
                RAW[period] = p[period]-VAMA[period];
                DEV=core.stdev(RAW, core.range(START, period));
                UP[1][period]=  VAMA[period] + DEV*ONE;
                DOWN[1][period]=VAMA[period] - DEV*ONE;
                UP[2][period]=  VAMA[period] + DEV*TWO;
                DOWN[2][period]=VAMA[period] - DEV*TWO;
                UP[3][period]=  VAMA[period] + DEV*THREE;
                DOWN[3][period]=VAMA[period] - DEV*THREE;
            end
        end
    end
end 