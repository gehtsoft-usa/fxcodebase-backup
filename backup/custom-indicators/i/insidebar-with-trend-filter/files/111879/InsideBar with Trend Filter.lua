-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64575
-- Id: 17938

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
    indicator:name("InsideBar with Trend Filter");
    indicator:description("Inside Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	 indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period", "MA Period", "Period" , 34);
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
 
	 indicator.parameters:addDouble("HL_Range_Max", "High/Low Range Max", "Range" , 99.99, 0, 100);
	 indicator.parameters:addDouble("HL_Range_Min", "High/Low Range Min", "Range" , 50, 0, 100);
	 indicator.parameters:addDouble("OC_Range_Max", "Open/Close Range Max", "Range" , 99.99, 0, 100);
	 indicator.parameters:addDouble("OC_Range_Min", "Open/Close Range Min", "Range" , 50, 0, 100);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("Show", "Show Trend Lines", "", false);
	 indicator.parameters:addBoolean("Zone", "Show Trend Zone", "", true);
	indicator.parameters:addColor("UP", "Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DN", "Down Trend", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("Size", "Arrow Size", "", 15);
	indicator.parameters:addColor("cUP", "Confirmed Up Trend InsideBar", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("cDN", "Confirmed Down Trend InsideBar", "", core.rgb(255, 0, 0));
	--indicator.parameters:addColor("unconfirmed", "Unconfirmed InsideBar", "", core.rgb(0, 0, 255));
  
	
	indicator.parameters:addInteger("Transparency", "Transparency", "", 10,0,100);
	

 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local Method, Period,Top,Bottom, top, bottom;
local Show;
local Trend;
local UP, DN, NE;
local Transparency;
local Zone;
local cUP, cDN, uUP, uDN;
local font;
local Size;
 
 
local HL_Range_Max, HL_Range_Min, OC_Range_Max, OC_Range_Min;
 

-- Streams block
 

-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
	UP=instance.parameters.UP;
	DN=instance.parameters.DN;
	Size=instance.parameters.Size;
	
	HL_Range_Max=instance.parameters.HL_Range_Max;
	HL_Range_Min=instance.parameters.HL_Range_Min;
	OC_Range_Max=instance.parameters.OC_Range_Max;
	OC_Range_Min=instance.parameters.OC_Range_Min;
	
	cUP=instance.parameters.cUP;
	cDN=instance.parameters.cDN;
	
	
	Zone=instance.parameters.Zone;
	
    
	Method=instance.parameters.Method;
	Period=instance.parameters.Period;
    Show=instance.parameters.Show;
	Transparency=instance.parameters.Transparency;

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
		font = core.host:execute("createFont", "Wingdings", Size, false, false);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		top= core.indicators:create(Method, source.high, Period);
		bottom = core.indicators:create(Method, source.low, Period);
		Trend= core.indicators:create(Method, source.high, Period);
		first = top.DATA:first();
			if Show then
			Top = instance:addStream("Top", core.Line, name, "", UP, first);
			Bottom = instance:addStream("Bottom", core.Line, name, "",  UP, first);			
			else
			Top= instance:addInternalStream(first, 0);
			Bottom= instance:addInternalStream(first, 0);
			end
			
			if Zone then
			instance:createChannelGroup("Channel","Channel" , Top,Bottom,  UP, Transparency);
			end
			
	
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    top:update(mode);
	bottom:update(mode);
	
    if period < first   then
	return;
	end
	
	Top[period]= top.DATA[period];
	Bottom[period]= bottom.DATA[period];
	
 
--uptrend: 
--if price has crossed ema34 "high" and it is still above ema34 "low";
--downtrend: 
-- if price has crossed ema34 "low" and it is still below ema34 "high"
 
if source.close[period]> Top[period]  then
Trend[period]= 1;
elseif source.close[period]< Bottom[period]  then
Trend[period]= -1;
else
Trend[period]=Trend[period-1];
end


--inside-bar:
-- if "high-today" < "high-yesterday" 
--and "low-today" > "low-yesterday"
local it_is_inside_bar;

if source.high[period]< source.high[period-1]	
and source.low[period]> source.low[period-1]				
then
it_is_inside_bar=true;
else
it_is_inside_bar=false;
end


--signal is invalidated if:
-- the range of the current candles is < than 50% (customizable)

local HL= (source.high[period-1]-source.low[period-1])/100;
local OC= math.abs(source.open[period-1]-source.close[period-1])/100;

if it_is_inside_bar 
and ((source.high[period]-source.low[period])/HL) < HL_Range_Max
and ((source.high[period]-source.low[period])/HL) > HL_Range_Min
and (math.abs(source.open[period]-source.close[period])/OC) < OC_Range_Max
and (math.abs(source.open[period]-source.close[period])/OC) < OC_Range_Min
then
it_is_inside_bar=false;
end
 

-- ▲ (long) if donwtrend is confirmed and the current candle is bull and the yesterday-candle
--is bear
-- ▼ (short) if uptrend is confirmed and the current candle is bear and the yesterday-candle
--is bull

local bear;
local bull;

if source.close[period]>source.open[period] 
and source.close[period-1]<source.open[period-1]
and Trend[period]==-1
then
bear=true;
else
bear=false;
end

if source.close[period]<source.open[period] 
and source.close[period-1]>source.open[period-1]
and Trend[period]==1
then
bull=true;
else
bull=false;
end  

	if Zone then
			if Trend[period]== 1 then
			Top:setColor(period, UP);
			Bottom:setColor(period, UP);
			else
			 Top:setColor(period, DN);
			Bottom:setColor(period, DN);
			end
	end
	
 
	if it_is_inside_bar then
	
			if bull then			 
		     core.host:execute("drawLabel1", source:serial(period),  source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, cDN, "\226");
			elseif bear then
			 core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, cUP, "\225");
			else
			core.host:execute ("removeLabel", source:serial(period));			
			end
		   	  
    else
							 
			core.host:execute ("removeLabel", source:serial(period));				 
	end
   
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end