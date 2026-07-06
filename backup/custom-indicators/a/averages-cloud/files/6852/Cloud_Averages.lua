-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2982
-- Id: 2671

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Averages Cloud");
    indicator:description("Averages Cloud");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Method One");	
	indicator.parameters:addString("Method1", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
 
    indicator.parameters:addInteger("SF", "Period", "", 20);
	

	
	indicator.parameters:addString("Type1", "CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "L");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "M");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "T");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "W");
	
	
	indicator.parameters:addGroup("Method Two");
	
	indicator.parameters:addString("Method2", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
	
	indicator.parameters:addInteger("LF", "Second Averege Period", "Second Averege Period", 100);
	
	indicator.parameters:addString("Type2", "CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type2", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("Type2", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("Type2", "LOW", "", "L");
    indicator.parameters:addStringAlternative("Type2","CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type2", "MEDIAN", "", "M");
    indicator.parameters:addStringAlternative("Type2", "TYPICAL", "", "T");
    indicator.parameters:addStringAlternative("Type2", "WEIGHTED", "", "W");
     
	
	indicator.parameters:addGroup("Style");	
	 indicator.parameters:addBoolean("Lines", "Show MA Lines", "" , false); 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));
    indicator.parameters:addColor("UpDown", "Color of UpDown", "Color of UpDown", core.rgb(125, 255, 125));
	indicator.parameters:addColor("DownUp", "Color of DownUp", "Color of DownUp", core.rgb(255, 125, 125));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ShortFrame=nil;
local LongFrame=nil;
local Method1=nil;
local Method2=nil;
local Lines;


local first;
local source = nil;

-- Streams block
local LongDATA = nil;
local ShortDATA = nil;

local UUL=nil;
local UUS=nil;

local UDL=nil;
local UDS=nil;

local DUL=nil;
local DUS=nil;

local DDL=nil;
local DDS=nil;

local Transparency;
local Type1;
local Type2;
local P1,P1;


-- Routine
function Prepare(nameOnly)
	
	Type1=instance.parameters.Type1;
	Type2=instance.parameters.Type2;
    Transparency= instance.parameters.Transparency;
    Lines = instance.parameters.Lines;
    ShortFrame = instance.parameters.SF;
    LongFrame = instance.parameters.LF;
	Method = instance.parameters.Method;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	
	
	Transparency= 100-Transparency;
	
    source = instance.source;
   
	
	if Type1 == "O" then
        P1 = source.open;
    elseif Type1 == "H" then
        P1 = source.high;
    elseif Type1 == "L" then
        P1 = source.low;
    elseif Type1 == "M" then
        P1 = source.median;
    elseif Type1 == "T" then
        P1 = source.typical;
    elseif Type1 == "W" then
        P1 = source.weighted;
    else
        P1 = source.close;
    end
	
	if Type2 == "O" then
        P2 = source.open;
    elseif Type2 == "H" then
        P2 = source.high;
    elseif Type2 == "L" then
        P2 = source.low;
    elseif Type2 == "M" then
        P2 = source.median;
    elseif Type2 == "T" then
        P2 = source.typical;
    elseif Type2 == "W" then
        P2 = source.weighted;
    else
        P2 = source.close;
    end
    local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame.. ", " .. Method1.. ", ".. Method2  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
	ShortDATA= core.indicators:create("AVERAGES", P1,  Method1, ShortFrame,false);	
	LongDATA= core.indicators:create("AVERAGES", P2, Method2, LongFrame,false);
	
     first = math.max(ShortDATA.DATA:first(),LongDATA.DATA:first());
    
   if Lines then
   
   UUL=instance:addStream("UUL", core.Line, name, "UUL", core.rgb( 128, 128, 128), first);
   UUS=instance:addStream("UUS", core.Line, name, "UUS", core.rgb( 128, 128, 128), first);
   UDL=instance:addStream("UDL", core.Line, name, "UDL", core.rgb( 128, 128, 128), first);
   UDS=instance:addStream("UDS", core.Line, name, "UDS", core.rgb( 128, 128, 128), first);
   DUL=instance:addStream("DUL", core.Line, name, "DUL", core.rgb( 128, 128, 128), first);
   DUS=instance:addStream("DUS", core.Line, name, "DUS", core.rgb( 128, 128, 128), first);
   DDL=instance:addStream("DDL", core.Line, name, "DDL", core.rgb( 128, 128, 128), first);
   DDS=instance:addStream("DDS", core.Line, name, "DDS", core.rgb( 128, 128, 128), first);
   else
   UUL=instance:addInternalStream(first, 0);
   UUS=instance:addInternalStream(first, 0);

   UDL=instance:addInternalStream(first, 0);
   UDS=instance:addInternalStream(first, 0);

   DUL=instance:addInternalStream(first, 0);
   DUS=instance:addInternalStream(first, 0);  
   
   DDL=instance:addInternalStream(first, 0);
   DDS=instance:addInternalStream(first, 0);
   end
	
	
	instance:createChannelGroup("UpGroup","Up" , UUL, UUS, instance.parameters.Up, Transparency);
	instance:createChannelGroup("UpDownGroup","UpDown" , UDL, UDS, instance.parameters.UpDown, Transparency);
	instance:createChannelGroup ("DownUpGroup","DownUp" , DUL, DUS, instance.parameters.DownUp, Transparency);
	instance:createChannelGroup("DownGroup","Down" , DDL, DDS, instance.parameters.Down, Transparency);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	    LongDATA:update(mode);
		ShortDATA:update(mode);
		
 
						
						
						if LongDATA.DATA[period] >= LongDATA.DATA[period-1]  and ShortDATA.DATA[period] >= ShortDATA.DATA[period-1]then
						UUL[period-1] = LongDATA.DATA[period-1];
						UUS[period-1] = ShortDATA.DATA[period-1];
						UUL[period] = LongDATA.DATA[period];
						UUS[period] = ShortDATA.DATA[period];
						end
						
						 if LongDATA.DATA[period] >= LongDATA.DATA[period-1]  and ShortDATA.DATA[period] < ShortDATA.DATA[period-1]then
						UDL[period-1] = LongDATA.DATA[period-1];
						UDS[period-1] = ShortDATA.DATA[period-1];
						UDL[period] = LongDATA.DATA[period];
						UDS[period] = ShortDATA.DATA[period];
						end
						
						if LongDATA.DATA[period] < LongDATA.DATA[period-1]  and ShortDATA.DATA[period] >= ShortDATA.DATA[period-1]then
						DUL[period-1] = LongDATA.DATA[period-1];
						DUS[period-1] = ShortDATA.DATA[period-1];
						DUL[period] = LongDATA.DATA[period];
						DUS[period] = ShortDATA.DATA[period];
						end
						
						if LongDATA.DATA[period] < LongDATA.DATA[period-1]  and ShortDATA.DATA[period] < ShortDATA.DATA[period-1]then
						DDL[period-1] = LongDATA.DATA[period-1];
						DDS[period-1] = ShortDATA.DATA[period-1];
						DDL[period] = LongDATA.DATA[period];
						DDS[period] = ShortDATA.DATA[period];
						end
		
		
 end