--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Bigger timeframe Averages Cloud");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Time Frame");
    indicator.parameters:addString("BS", "Time frame to calculate", "", "D1");
	indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
 
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
	

	
	indicator.parameters:addString("Type1", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "weighted");
	
	
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
	
	indicator.parameters:addString("Type2", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Type2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Type2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Type2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Type2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Type2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Type2", "WEIGHTED", "", "weighted");
     
	
	indicator.parameters:addGroup("Style");	
	 indicator.parameters:addBoolean("Lines", "Show MA Lines", "" , false); 
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));
    indicator.parameters:addColor("UpDown", "Color of UpDown", "Color of UpDown", core.rgb(125, 255, 125));
	indicator.parameters:addColor("DownUp", "Color of DownUp", "Color of DownUp", core.rgb(255, 125, 125));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
 
 
end

-- Parameters block
local ShortFrame=nil;
local LongFrame=nil;
local Method1=nil;
local Method2=nil;
local Lines;


local source;                   -- the source
local BS;
local host;
local day_offset;
local week_offset;
 
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


local loading = false;
local Source;


function Prepare()


      Type1=instance.parameters.Type1;
	Type2=instance.parameters.Type2;
    Transparency= instance.parameters.Transparency;
    Lines = instance.parameters.Lines;
    ShortFrame = instance.parameters.SF;
    LongFrame = instance.parameters.LF;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	
	
	Transparency= 100-Transparency; 

     --  assert(LongFrame < ShortFrame,  "Long Period must be greater than Short Period");
    source = instance.source;
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    BS = instance.parameters.BS;
    
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");

    local s, e, s1, e1;

    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(BS, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be bigger than the chart time frame!");
   
    local name = profile:id() .. "(" .. source:name() .. "," .. BS ..", ".. ShortFrame .. ", " .. LongFrame.. ", " .. Method1.. ", ".. Method2 .. ")";
    instance:name(name);
	
	if Lines then
   
   UUL=instance:addStream("UUL", core.Line, name, "UUL", core.rgb( 128, 128, 128), 0);
   UUS=instance:addStream("UUS", core.Line, name, "UUS", core.rgb( 128, 128, 128),0);
   UDL=instance:addStream("UDL", core.Line, name, "UDL", core.rgb( 128, 128, 128), 0);
   UDS=instance:addStream("UDS", core.Line, name, "UDS", core.rgb( 128, 128, 128), 0);
   DUL=instance:addStream("DUL", core.Line, name, "DUL", core.rgb( 128, 128, 128), 0);
   DUS=instance:addStream("DUS", core.Line, name, "DUS", core.rgb( 128, 128, 128), 0);
   DDL=instance:addStream("DDL", core.Line, name, "DDL", core.rgb( 128, 128, 128), 0);
   DDS=instance:addStream("DDS", core.Line, name, "DDS", core.rgb( 128, 128, 128),0);
   else
   UUL=instance:addInternalStream(0, 0);
   UUS=instance:addInternalStream(0, 0);

   UDL=instance:addInternalStream(0, 0);
   UDS=instance:addInternalStream(0, 0);

   DUL=instance:addInternalStream(0, 0);
   DUS=instance:addInternalStream(0, 0);  
   
   DDL=instance:addInternalStream(0, 0);
   DDS=instance:addInternalStream(0, 0);
   end
	
	
	instance:createChannelGroup("UpGroup","Up" , UUL, UUS, instance.parameters.Up, Transparency);
	instance:createChannelGroup("UpDownGroup","UpDown" , UDL, UDS, instance.parameters.UpDown, Transparency);
	instance:createChannelGroup ("DownUpGroup","DownUp" , DUL, DUS, instance.parameters.DownUp, Transparency);
	instance:createChannelGroup("DownGroup","Down" , DDL, DDS, instance.parameters.Down, Transparency);

	
 
	   
	   Source = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), math.min(300, math.max(LongFrame, ShortFrame)), 100, 101);
	  loading=true;
	
       ShortDATA= core.indicators:create("AVERAGES", Source[Type1],  Method1, ShortFrame,false);	
	   LongDATA= core.indicators:create("AVERAGES", Source[Type2], Method2, LongFrame,false);
	
end




-- the function which is called to calculate the period
function Update(period, mode)

   local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		

    ShortDATA:update(mode);
	LongDATA:update(mode);
	
  
 
        
			if LongDATA.DATA[p] >= LongDATA.DATA[p-1]  and ShortDATA.DATA[p] >= ShortDATA.DATA[p-1]then
						UUL[period-1] = LongDATA.DATA[p-1];
						UUS[period-1] = ShortDATA.DATA[p-1];
						UUL[period] = LongDATA.DATA[p];
						UUS[period] = ShortDATA.DATA[p];
						end
						
						 if LongDATA.DATA[p] >= LongDATA.DATA[p-1]  and ShortDATA.DATA[p] < ShortDATA.DATA[p-1]then
						UDL[period-1] = LongDATA.DATA[p-1];
						UDS[period-1] = ShortDATA.DATA[p-1];
						UDL[period] = LongDATA.DATA[p];
						UDS[period] = ShortDATA.DATA[p];
						end
						
						if LongDATA.DATA[p] < LongDATA.DATA[p-1]  and ShortDATA.DATA[p] >= ShortDATA.DATA[p-1]then
						DUL[period-1] = LongDATA.DATA[p-1];
						DUS[period-1] = ShortDATA.DATA[p-1];
						DUL[period] = LongDATA.DATA[p];
						DUS[period] = ShortDATA.DATA[p];
						end
						
						if LongDATA.DATA[p] < LongDATA.DATA[p-1]  and ShortDATA.DATA[p] < ShortDATA.DATA[p-1]then
						DDL[period-1] = LongDATA.DATA[p-1];
						DDS[period-1] = ShortDATA.DATA[p-1];
						DDL[period] = LongDATA.DATA[p];
						DDS[period] = ShortDATA.DATA[p];
						end
	 

end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(BS, source:date(period), day_offset, week_offset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, true);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	
