-- Id: 1061

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1479

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
    indicator:name("Moving Averege Cloud");
    indicator:description("Moving Averege Cloud");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("SF", "Short Averege Period", "Short Averege  Period", 20);
    indicator.parameters:addInteger("LF", "Long Averege Period", "Long Averege Period", 100);
	
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	
	
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
local Method=nil;

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

-- Routine
function Prepare(nameOnly)
    ShortFrame = instance.parameters.SF;
    LongFrame = instance.parameters.LF;
	Method = instance.parameters.Method;
	
    source = instance.source;
 
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	LongDATA= core.indicators:create(Method, source, LongFrame);
	ShortDATA= core.indicators:create(Method, source, ShortFrame);
	
	 first = math.max(LongDATA.DATA:first(),ShortDATA.DATA:first());

    local name = profile:id() .. "(" .. source:name() .. ", " .. ShortFrame .. ", " .. LongFrame.. ", " .. Method .. ")";
    instance:name(name);
    
	if   (nameOnly) then
        return;
    end
	
   UUL=instance:addInternalStream(0, 0);
   UUS=instance:addInternalStream(0, 0);

   UDL=instance:addInternalStream(0, 0);
   UDS=instance:addInternalStream(0, 0);

   DUL=instance:addInternalStream(0, 0);
   DUS=instance:addInternalStream(0, 0);  
   
   DDL=instance:addInternalStream(0, 0);
   DDS=instance:addInternalStream(0, 0);
	
	
	instance:createChannelGroup("UpGroup","Up" , UUL, UUS, instance.parameters.Up, 40);
	instance:createChannelGroup("UpDownGroup","UpDown" , UDL, UDS, instance.parameters.UpDown, 40);
	instance:createChannelGroup ("DownUpGroup","DownUp" , DUL, DUS, instance.parameters.DownUp, 40);
	instance:createChannelGroup("DownGroup","Down" , DDL, DDS, instance.parameters.Down, 40);
	
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