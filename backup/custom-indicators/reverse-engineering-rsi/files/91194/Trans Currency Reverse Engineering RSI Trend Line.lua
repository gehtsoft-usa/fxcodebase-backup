-- Id: 13888
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60010

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
    indicator:name("Curved trend line");
    indicator:description("Curved trend line");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
	
	indicator.parameters:addGroup("RSI Calculation");	
    indicator.parameters:addInteger("Period", "RSI Period", "RSI Period", 14);
	indicator.parameters:addInteger("MA_Period", "MA Period", "MA Period", 45);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 
 
     indicator.parameters:addInteger("ID", "Unique Indicator ID", "ID", 1);

	indicator.parameters:addGroup("RSI Line Style");
    indicator.parameters:addColor("color1", "Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);	 
	
	indicator.parameters:addGroup("Trend Line Style");
	indicator.parameters:addColor("color2", "Line Color", "Line Color", core.rgb(0, 0, 255));
	indicator.parameters:addColor("color3", "Top Limes Color", "Line Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("color4", "Bottom Limes Color", "Line Color", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil; 
local pattern = "([^;]*);([^;]*)"; 
local db;
local Period;
local rsi, RSI; 
local Trend; 
 
local  ma;  
local ExpPeriod; 
local RevEngMA = nil;
local Method,MA_Period;
local auc, AUC;
local ADC, adc; 
local ID;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();	
	 
	Period=instance.parameters.Period;
	Method = instance.parameters.Method;
	MA_Period = instance.parameters.MA_Period;
	ID= instance.parameters.ID;
	
	ExpPeriod=2*Period-1;

    local name = profile:id() .. " " .. ID ;
	instance:name(name);
	if nameOnly then
		return;
	end
	
	require("storagedb");
    db = storagedb.get_db(name);
	
	rsi = core.indicators:create("RSI",source,Period);

    core.host:execute("addCommand", 1, "1. Point");
	core.host:execute("addCommand", 2, "2. Point");
    core.host:execute("addCommand", 3, "Reset");
	
	instance:ownerDrawn(true);
	
	RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.color1, rsi.DATA:first());
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.width1);
    RSI:setStyle(instance.parameters.style1);
	RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	Trend = instance:addStream("Trend", core.Line, name .. ".Trend", "Trend", instance.parameters.color2, source:first());
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
    Trend:setWidth(instance.parameters.width2);
    Trend:setStyle(instance.parameters.style2);
	core.host:execute ("attachOuputToChart", "Trend")
	 

    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	ma = core.indicators:create(Method, rsi.DATA, MA_Period);
	auc = instance:addInternalStream(0, 0);
	adc = instance:addInternalStream(0, 0);
	AUC = core.indicators:create("EMA", auc, ExpPeriod);
	ADC = core.indicators:create("EMA", adc, ExpPeriod);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


      if source[period]>source[period-1] then
	  auc[period]=source[period]-source[period-1];
	  adc[period]=0;
	  else
	  auc[period]=0;
	  adc[period]=source[period-1]-source[period];
	  end

    rsi:update(mode);
	ma:update(mode);
	AUC:update(mode);
	ADC:update(mode);
	
    if period < rsi.DATA:first() then
	return;
	end
	
	RSI[period]= rsi.DATA[period];
end

function AsyncOperationFinished(cookie, success, message)

    local iLevel, iDate = string.match(message, pattern, 0);
	
	if cookie== 1 then 
	db:put("Date1", iDate);  
	elseif cookie== 2 then 
	db:put("Date2", iDate);  	
	elseif cookie== 3 then	 
	db:put("Date1", 0);   
	db:put("Date2", 0);  
	core.drawLine(Trend, core.range(source:first(), source:size()-1), 0, source:first(),0, source:size()-1, instance.parameters.color2);
	end
	
end

local init= false;
function Draw(stage, context)
    if stage ~= 0 then
	return;
	end
	
	local First=math.max(first,context:firstBar ());
	local Last=math.min(source:size()-1, context:lastBar ());
  
	
	local Date1=  tonumber(db:get("Date1", 0));  
	local Date2=  tonumber(db:get("Date2", 0));  
	
	
	local index1 = core.findDate (source, Date1, false);
	local index2 = core.findDate (source, Date2, false);
	
	if index1== -1 or  index2== -1 then
	return;
	end

	

	if not rsi.DATA:hasData(index1) 
	or not rsi.DATA:hasData(index2) 	 
	then
	return;
	end
	
		
	local RSI1=rsi.DATA[index1];  
	local RSI2=rsi.DATA[index2]; 
	
	core.host:execute ("setStatus", "1. " .. RSI1.. " 2. " .. RSI2 )
	
	if not init then	
	context:createPen (1, context:convertPenStyle ( instance.parameters.style2), instance.parameters.width2, instance.parameters.color2);	
	init= true;
	end
	
	context:setClipRectangle (context:left (), context:top (), context:right (), context:bottom ())
	
	
	x1, x , x = context:positionOfBar (index1);
	x2, x , x  = context:positionOfBar (index2);
	
	visible, y1 = context:pointOfPrice (RSI1);
	visible, y2 = context:pointOfPrice (RSI2);
	
	context:drawLine (1, x1, y1, x2, y2 );
	
	local Slope =  (RSI2-RSI1)/math.abs(index2-index1);
	local Raw;
	local x;
	for period = source:first(), source:size()-1, 1 do 
	    Raw=  RSI1+ (  period-index1)*Slope;       
        if Raw>= 100 then
		Trend:setColor(period, instance.parameters.color3);
        Raw=100; 
        elseif  Raw <= 0 then
		Trend:setColor(period, instance.parameters.color4);
        Raw=0;
        else
	    Trend:setColor(period, instance.parameters.color2);
		end
		
		 
		 
			x=(Period-1)*(ADC.DATA[period]*Raw/(100-Raw)-AUC.DATA[period]);
		
			if x>=0  then	 
			Trend[period] =  source[period]+x;
			else
			 Trend[period] =  source[period]+x*(100-Raw)/Raw;
			end 
	end
	
  
end